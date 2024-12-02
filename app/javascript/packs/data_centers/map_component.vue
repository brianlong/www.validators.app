<template>
  <div class="container">
    <!-- <div id="floating-panel">
      <button id="toggle-heatmap">Toggle Heatmap</button>
      <button id="change-gradient">Change gradient</button>
      <button id="change-radius">Change radius</button>
      <button id="change-opacity">Change opacity</button>
    </div> -->
    <div id="map"></div>
  </div>
</template>

<script>
  import axios from 'axios';
  import { mapGetters } from 'vuex';

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  (g=>{var h,a,k,p="The Google Maps JavaScript API",c="google",l="importLibrary",q="__ib__",m=document,b=window;b=b[c]||(b[c]={});var d=b.maps||(b.maps={}),r=new Set,e=new URLSearchParams,u=()=>h||(h=new Promise(async(f,n)=>{await (a=m.createElement("script"));e.set("libraries",[...r]+"");for(k in g)e.set(k.replace(/[A-Z]/g,t=>"_"+t[0].toLowerCase()),g[k]);e.set("callback",c+".maps."+q);a.src=`https://maps.${c}apis.com/maps/api/js?`+e;d[q]=f;a.onerror=()=>h=n(Error(p+" could not load."));a.nonce=m.querySelector("script[nonce]")?.nonce||"";m.head.append(a)}));d[l]?console.warn(p+" only loads once. Ignoring:",g):d[l]=(f,...n)=>r.add(f)&&u().then(()=>d[l](f,...n))})({
    key: "AIzaSyDgZS-lkCg_dKPRU-oRTSM6ZY0mXwiznEk",
    libraries: "visualization",
    v: "weekly",
  });

  export default {
    data() {
      return {
        data_centers: [],
        heat_points: [],
        map: null
      }
    },

    created() {
        this.initMap();
        this.add_markers();
    },

    computed: mapGetters([
      'network'
    ]),

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
          const { AdvancedMarkerElement } = await google.maps.importLibrary("marker");
          const infoWindow = new google.maps.InfoWindow();
          axios.get('/api/v1/data-centers-for-map')
               .then(response => {
                 this.data_centers = response.data['data_centers'];
                 this.data_centers.forEach(data_center => {
                    let position = { lat: parseFloat(data_center.location_latitude), lng: parseFloat(data_center.location_longitude) };
                    this.heat_points.push(new google.maps.LatLng(position['lat'], position['lng']));
                    let map = this.map;
                    const marker = new AdvancedMarkerElement({
                      position,
                      map,
                      title: data_center.data_center_key,
                      // content: pin.element,
                      gmpClickable: true,
                    });

                    marker.addListener("click", ({ domEvent, latLng }) => {
                      const { target } = domEvent;

                      infoWindow.close();
                      infoWindow.setContent(marker.title);
                      infoWindow.open(marker.map, marker);
                    });
                });
          const heatmap = new google.maps.visualization.HeatmapLayer({
            data: this.heat_points,
            map: this.map,
          });
          });
        }
    }
  }
</script>