import h337 from 'heatmap.js';

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

    this.detachObserver = new MutationObserver(() => {
      if (!this.container.isConnected) {
        this.placeInMarkerPane();
      }
    });
    this.detachObserver.observe(this.getMap().getDiv(), { childList: true, subtree: true });

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
