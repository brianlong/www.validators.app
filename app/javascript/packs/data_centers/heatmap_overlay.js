import h337 from 'heatmap.js';

// Loosely based on heatmap.js's official gmaps-heatmap plugin
// (plugins/gmaps-heatmap/gmaps-heatmap.js in the heatmap.js package), rewritten
// as an ES module against the `google` global the rest of this app already
// relies on (instead of the plugin's UMD wrapper, which `require()`s an
// unrelated `google-maps` npm package we don't have and don't need).
//
// Renders on a plain canvas 2D surface via heatmap.js instead of deck.gl's
// WebGL, multi-pass GPU-aggregated HeatmapLayer — trading a slightly less
// polished gradient for a synchronous, single-pass draw that isn't sensitive
// to the map's WebGL rendering mode (vector vs raster) or to how many
// animation frames a GPU aggregation pass needs to finish.
//
// One deviation from the original plugin: point positions are computed with
// fromLatLngToContainerPixel (viewport-relative) instead of the plugin's
// fromLatLngToDivPixel + manual topLeft-offset technique. That technique
// silently breaks at very low zoom levels — like this map's whole-world
// default view — where the map can show the world wrapped/repeated and the
// naive offset math ends up placing every point far outside the canvas.
// ContainerPixel coordinates are already relative to the visible viewport,
// so they don't need that offset and don't have the wraparound problem.
export function createHeatmapOverlay(map, cfg) {
  function HeatmapOverlay() {
    this.setMap(map);
    this.initialize(cfg || {});
  }

  HeatmapOverlay.prototype = new google.maps.OverlayView();

  HeatmapOverlay.prototype.initialize = function(cfg) {
    this.cfg = cfg;
    const mapDiv = this.getMap().getDiv();
    const container = document.createElement('div');
    this.width = mapDiv.clientWidth;
    this.height = mapDiv.clientHeight;
    container.style.cssText = `position:absolute;top:0;left:0;width:${this.width}px;height:${this.height}px;pointer-events:none;z-index:0;`;
    this.container = container;
    this.data = [];
    this.max = 1;
    cfg.container = container;
  };

  // AdvancedMarkerElement renders into its own internal Google pane, nested
  // several levels inside the map div — it isn't a plain sibling the way a
  // simple DOM node would be, and it doesn't share a stacking context with
  // one either. Neither z-index nor DOM order at the map-div level can beat
  // it: a sibling of that pane's ancestor always paints as a single unit,
  // regardless of z-index values *inside* that ancestor. So instead of
  // guessing where in the tree "above tiles, below markers" is, this finds
  // the actual pane Google renders markers into (by walking up from a real
  // marker element already in the DOM to the first ancestor that's roughly
  // map-sized) and inserts the heatmap container as its first child.
  //
  // This used to also look for a separate pane for the numbered cluster
  // badges (classic google.maps.Marker, from set_up_clusterer's renderer),
  // keyed off their display:table-cell label wrapper, and inserted into
  // whichever of the two panes came first in the document. In production
  // that walk-up stopped too early, at a per-marker wrapper that happened to
  // pass the "roughly map-sized" check (it carries an inline z-index that
  // looks instance-specific, e.g. `z-index: 103`, not a shared pane's) — and
  // that wrapper sat *below* the base tile layer. The map's tiles fade in
  // over about a second on load, so the heatmap was briefly visible through
  // them and then completely hidden once they reached full opacity. The
  // AdvancedMarkerElement pane alone doesn't have this problem, so cluster
  // badges being visible over the heatmap is a smaller, separate issue to
  // solve without touching this.
  HeatmapOverlay.prototype.findMarkerPane = function() {
    const mapDiv = this.getMap().getDiv();
    const markerEl = mapDiv.querySelector('gmp-advanced-marker');
    if (!markerEl) {
      return null;
    }

    const mapRect = mapDiv.getBoundingClientRect();
    let el = markerEl.parentElement;
    while (el && el !== mapDiv) {
      const rect = el.getBoundingClientRect();
      if (rect.width >= mapRect.width * 0.9 && rect.height >= mapRect.height * 0.9) {
        return el;
      }
      el = el.parentElement;
    }
    return null;
  };

  // The pane markers live in may be transformed/offset relative to the map
  // div in ways we don't control or need to understand — measuring both
  // elements' actual on-screen position and compensating lets the container
  // line up correctly no matter what that transform is.
  HeatmapOverlay.prototype.alignContainer = function() {
    const parent = this.container.parentElement;
    if (!parent) {
      return;
    }
    const mapRect = this.getMap().getDiv().getBoundingClientRect();
    const parentRect = parent.getBoundingClientRect();
    const offsetX = Math.round(mapRect.left - parentRect.left);
    const offsetY = Math.round(mapRect.top - parentRect.top);
    this.container.style.transform = `translate(${offsetX}px, ${offsetY}px)`;
  };

  // Marker rendering can lag behind map/overlay setup (clustering libraries
  // commonly defer their initial layout), so a marker may not exist in the
  // DOM yet the first time this runs. Retry for a bit, falling back to a
  // plain sibling of the map div in the meantime so the heatmap is visible
  // rather than missing, then relocate into the real marker pane once one
  // shows up.
  HeatmapOverlay.prototype.placeInMarkerPane = function(attempt) {
    attempt = attempt || 0;
    const pane = this.findMarkerPane();
    if (pane) {
      pane.insertBefore(this.container, pane.firstChild);
      this.alignContainer();
      return;
    }
    if (!this.container.parentElement) {
      this.getMap().getDiv().appendChild(this.container);
      this.alignContainer();
    }
    if (attempt < 20) {
      requestAnimationFrame(() => this.placeInMarkerPane(attempt + 1));
    }
  };

  HeatmapOverlay.prototype.onAdd = function() {
    this.placeInMarkerPane();
    this.boundsListener = google.maps.event.addListener(this.getMap(), 'bounds_changed', () => this.update());

    // MarkerClusterer periodically tears down and rebuilds the DOM nodes for
    // its cluster badges as clustering recomputes, even without a bounds
    // change (e.g. once marker data settles after load). If the container
    // ended up nested inside one of those ephemeral per-cluster wrappers —
    // the pane-detection heuristic above can only make its best guess about
    // which ancestor is the real, persistent pane versus a per-marker one —
    // it gets removed along with it, and the heatmap silently vanishes.
    // Watching for that and re-placing it immediately, rather than only on
    // the next bounds_changed, is what actually makes this reliable.
    this.detachObserver = new MutationObserver(() => {
      if (!this.container.isConnected) {
        this.placeInMarkerPane();
      }
    });
    this.detachObserver.observe(this.getMap().getDiv(), { childList: true, subtree: true });

    // Belt and braces on top of the observer above: whatever the exact
    // mechanism turns out to be — detached container, a pane that resets
    // size, a canvas that loses its drawn content — periodically reasserting
    // placement, position, and redrawing the current data self-corrects it
    // within a couple of seconds without needing to chase down the precise
    // cause, which has proven to differ between environments.
    this.healInterval = setInterval(() => {
      if (!this.container.isConnected) {
        this.placeInMarkerPane();
      }
      this.update();
    }, 2000);

    if (!this.heatmap) {
      this.heatmap = h337.create(this.cfg);
    }
    this.update();
  };

  HeatmapOverlay.prototype.onRemove = function() {
    if (this.healInterval) {
      clearInterval(this.healInterval);
      this.healInterval = null;
    }
    if (this.detachObserver) {
      this.detachObserver.disconnect();
      this.detachObserver = null;
    }
    if (this.container.parentElement) {
      this.container.parentElement.removeChild(this.container);
    }
    if (this.boundsListener) {
      google.maps.event.removeListener(this.boundsListener);
      this.boundsListener = null;
    }
  };

  HeatmapOverlay.prototype.draw = function() {
    this.update();
  };

  HeatmapOverlay.prototype.resize = function() {
    const div = this.getMap().getDiv();
    const width = div.clientWidth;
    const height = div.clientHeight;
    if (width === this.width && height === this.height) {
      return;
    }
    this.width = width;
    this.height = height;
    this.container.style.width = `${width}px`;
    this.container.style.height = `${height}px`;
    this.heatmap._renderer.setDimensions(width, height);
  };

  HeatmapOverlay.prototype.update = function() {
    const projection = this.getProjection();
    if (!projection) {
      return;
    }

    this.resize();
    this.alignContainer();

    const points = this.data.map(entry => {
      const point = projection.fromLatLngToContainerPixel(entry.latlng);
      return {
        x: Math.round(point.x),
        y: Math.round(point.y),
        value: entry.value,
        radius: entry.radius || this.cfg.radius || 40,
      };
    });

    this.heatmap.setData({ max: this.max, data: points });
  };

  HeatmapOverlay.prototype.setData = function(points, max) {
    this.max = max || 1;
    this.data = points.map(p => ({
      latlng: new google.maps.LatLng(p.lat, p.lng),
      value: p.value,
      radius: p.radius,
    }));
    this.update();
  };

  return new HeatmapOverlay();
}
