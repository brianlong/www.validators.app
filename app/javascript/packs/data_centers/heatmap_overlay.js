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

  HeatmapOverlay.prototype.onAdd = function() {
    // Appended directly to the map's own div rather than one of
    // getPanes()'s layers: those panes pan with the map using the DivPixel
    // coordinate system, which would double up with the ContainerPixel
    // coordinates used below.
    //
    // z-index: 0 on the container (set in initialize()) keeps this below
    // Google's own marker/control panes without having to guess where in
    // the DOM Google's base tile layer ends and the marker panes begin.
    this.getMap().getDiv().appendChild(this.container);
    this.boundsListener = google.maps.event.addListener(this.getMap(), 'bounds_changed', () => this.update());
    if (!this.heatmap) {
      this.heatmap = h337.create(this.cfg);
    }
    this.update();
  };

  HeatmapOverlay.prototype.onRemove = function() {
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
