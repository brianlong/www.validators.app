<template>
  <div class="container">
    <div id="floating-panel" class="d-flex justify-content-between flex-wrap gap-3 mb-1 mb-sm-4">
      <input id="search-asn" class="form-control" style="width: 180px;" v-model="asn_search" placeholder="Search by ASN"></input>
      <div>
        <div class="btn-group me-2 mb-3 mb-sm-0">
          <button id="toggle-heatmap" class="btn btn-sm btn-secondary" :class="heatmap_type == 'off' ? 'active' : null" v-on:click="toggleHeatmap('off')">Heatmap Off</button>
          <button id="toggle-heatmap_type" class="btn btn-sm btn-secondary" :class="heatmap_type == 'stake' ? 'active' : null" v-on:click="toggleHeatmap('stake')">Stake</button>
          <button id="toggle-heatmap_type" class="btn btn-sm btn-secondary" :class="heatmap_type == 'validators' ? 'active' : null" v-on:click="toggleHeatmap('validators')">Validators</button>
        </div>
        <button id="toggle-markers" class="btn btn-sm btn-secondary mb-3 mb-sm-0" v-on:click="toggleMarkers()">Toggle Markers</button>
      </div>
    </div>

    <div id="map"></div>
  </div>
</template>

<script>
  import axios from 'axios';
  import { mapGetters } from 'vuex';
  import '../mixins/numbers_mixins'
  import { MarkerClusterer } from "@googlemaps/markerclusterer";
  import { h } from 'vue'

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  (g=>{var h,a,k,p="The Google Maps JavaScript API",c="google",l="importLibrary",q="__ib__",m=document,b=window;b=b[c]||(b[c]={});var d=b.maps||(b.maps={}),r=new Set,e=new URLSearchParams,u=()=>h||(h=new Promise(async(f,n)=>{await (a=m.createElement("script"));e.set("libraries",[...r]+"");for(k in g)e.set(k.replace(/[A-Z]/g,t=>"_"+t[0].toLowerCase()),g[k]);e.set("callback",c+".maps."+q);a.src=`https://maps.${c}apis.com/maps/api/js?`+e;d[q]=f;a.onerror=()=>h=n(Error(p+" could not load."));a.nonce=m.querySelector("script[nonce]")?.nonce||"";m.head.append(a)}));d[l]?console.warn(p+" only loads once. Ignoring:",g):d[l]=(f,...n)=>r.add(f)&&u().then(()=>d[l](f,...n))})({
    key: 'AIzaSyBZVM-i2uawXovm2pIQCBsJpc8rVlRwFHk',
    libraries: "visualization",
    v: "weekly",
  });

  export default {
    data() {
      return {
        data_centers: [],
        heat_points: [],
        map: null,
        heatmap: null,
        asn_search: null,
        markerClusterer: null,
        markers_visible: true,
        heatmap_type: 'stake'
      }
    },

    created() {
        this.initMap();
        this.add_markers();
    },

    computed: {
      ...mapGetters([
        'network'
      ]),
      marker_list: function() {
        if(this.markers_visible) {
          return this.data_centers.map(data_center => data_center.marker);
        } else {
          return [];
        }
      }
    },

    watch: {
      asn_search: function(new_asn, old_asn) {
        if(new_asn.length > 4) {
          this.data_centers.forEach(data_center => {
            if (data_center.traits_autonomous_system_number == new_asn) {
              data_center.marker.map = this.map;
            } else {
              data_center.marker.map = null;
            }
            this.markerClusterer.clearMarkers();
          });
        } else {
          this.data_centers.forEach(data_center => {
            data_center.marker.map = this.map;
          });
          this.set_up_clusterer(this.marker_list, this.map);
        }
      }
    },

    methods: {
      initMap: async function() {
        const position = { lat: 49.9936, lng: 19.9835 };

        const { Map } = await google.maps.importLibrary("maps")

        this.map = new Map(document.getElementById("map"), {
            zoom: 2,
            center: new google.maps.LatLng(49.9936, 19.9835),
            mapId: "DEMO_MAP_ID",
        });
        },

        add_markers: async function() {
          const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");
          const infoWindow = new google.maps.InfoWindow();
          axios.get('/api/v1/data-centers-for-map?network=' + this.network)
               .then(response => {
                let valid_data_centers = response.data['data_centers'].filter(data_center => data_center.location_latitude && data_center.location_longitude);
                valid_data_centers.forEach(data_center => {
                  let checked_data_center = this.test_unique_data_center(data_center);
                  this.data_centers.push(checked_data_center);
                })
                 this.data_centers.forEach(data_center => {
                    let position = { lat: parseFloat(data_center.location_latitude), lng: parseFloat(data_center.location_longitude) };
                    this.heat_points.push({
                      location: new google.maps.LatLng(position['lat'], position['lng']),
                      weight: Math.ceil(this.lamports_to_sol(data_center.active_validators_stake) / 10)
                    })

                    data_center.marker = new AdvancedMarkerElement({
                      position,
                      title: data_center.traits_organization,
                      content: this.buildContent(data_center),
                      gmpClickable: true,
                    });

                    data_center.marker.addListener("click", () => {
                      this.toggleHighlight(data_center.marker, data_center);
                    });
                });
                this.heatmap = new google.maps.visualization.HeatmapLayer({
                  data: this.heat_points,
                  map: this.map,
                });
                this.heatmap.set("radius", 40);

                this.set_up_clusterer(this.marker_list, this.map);
          });
        },

        test_unique_data_center: function(data_center, lv = 0) {
          lv = lv + 1;
          if (this.data_centers.length == 0) {
            return data_center;
          }
          this.data_centers.forEach(data_center_added => {
            if(data_center_added.location_latitude == data_center.location_latitude && data_center_added.location_longitude == data_center.location_longitude) {
              data_center.location_longitude = parseFloat(data_center.location_longitude) + 0.0003;
              return this.test_unique_data_center(data_center, lv);
            }
          });
          return data_center;
        },

        set_up_clusterer: function(marker_list, map) {
          this.markerClusterer && this.markerClusterer.clearMarkers();
          this.markerClusterer = new MarkerClusterer( {
            map: map,
            markers: marker_list,
            renderer: {
              render: ({ markers, _position: position }) => {
                const count = markers.length;

                const svg = window.btoa(`
                <svg fill="#17132a" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240">
                  <circle cx="120" cy="120" opacity=".6" r="70" />
                  <circle cx="120" cy="120" opacity=".3" r="90" />
                  <circle cx="120" cy="120" opacity=".2" r="110" />
                  <circle cx="120" cy="120" opacity=".1" r="130" />
                </svg>`);
                return new google.maps.Marker({
                  position,
                  icon: {
                    url: `data:image/svg+xml;base64,${svg}`,
                    scaledSize: new google.maps.Size(45, 45),
                  },
                  label: {
                    text: String(count),
                    color: "rgba(255,255,255,0.9)",
                    fontSize: "12px",
                  },
                  zIndex: count,
                });
              }
            }
          });
        },

        build_stake_heatmap: function() {
          this.heat_points = [];
          this.data_centers.forEach(data_center => {
            let position = { lat: parseFloat(data_center.location_latitude), lng: parseFloat(data_center.location_longitude) };
            this.heat_points.push({
              location: new google.maps.LatLng(position['lat'], position['lng']),
              weight: Math.ceil(this.lamports_to_sol(data_center.active_validators_stake) / 10)
            })
          });
          this.heatmap.setData(this.heat_points);
          this.heatmap.setMap(this.map);
        },

        build_validators_count_heatmap: function() {
          this.heat_points = [];
          this.data_centers.forEach(data_center => {
            let position = { lat: parseFloat(data_center.location_latitude), lng: parseFloat(data_center.location_longitude) };
            this.heat_points.push({
              location: new google.maps.LatLng(position['lat'], position['lng']),
              weight: data_center.active_validators_count
            })
          });
          this.heatmap.setData(this.heat_points);
          this.heatmap.setMap(this.map);
        },

        toggleHighlight: function(marker, data_center) {
          if (marker.content.classList.contains("highlight")) {
            marker.content.classList.remove("highlight");
            marker.zIndex = null;
          } else {
            marker.content.classList.add("highlight");
            marker.zIndex = 1;
          }
        },

        buildContent: function(data_center) {
          const content = document.createElement("div");
          content.classList.add("data-center");
          content.innerHTML = `
            <div class="icon">
                <i class="fa-solid fa-database" aria-hidden="true"></i>
            </div>
            <div class="data-center-details">
                <p class="h5">${data_center.traits_organization}</p>
                <div class="mb-1">
                  <span>${data_center.data_center_key}</span>
                  <span class="text-muted">(${data_center.traits_autonomous_system_number})</span>
                </div>
                <div class="mb-1">
                  <span class="me-1">active stake: ${this.lamports_to_sol(data_center.active_validators_stake)} SOL</span>
                </div>
                <div class="mb-1">
                  <span class="me-1">active validators: ${data_center.active_validators_count}</span>
                </div>
            </div>
            `;
          return content;
        },

        toggleHeatmap: function(h_type) {
          this.heatmap_type = h_type;
          if(h_type == 'stake') {
            this.build_stake_heatmap();
          } else if(h_type == 'validators') {
            this.build_validators_count_heatmap();
          } else {
            this.heatmap.setMap(null);
          }
        },

        toggleMarkers: function() {
          if(this.markers_visible) {
            this.asn_search = null;
            this.markers_visible = false;
            this.data_centers.forEach(data_center => {
              data_center.marker.map = null;
            });
          } else {
            this.markers_visible = true;
            this.data_centers.forEach(data_center => {
              data_center.marker.map = this.map;
            });
          }
          this.set_up_clusterer(this.marker_list, this.map);
        }
    }
  }
</script>
