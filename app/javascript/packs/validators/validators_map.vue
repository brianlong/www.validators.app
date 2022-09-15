<template>
  <div class="card map">
    <div class="map-background">
      <div class="map-points">
        <!-- orientation points -->
        <div class="map-point map-point-sm" title="Map Center" style="left: 50%; bottom: 50%">X</div>
        <div class="map-point map-point-sm" title="Point 0,0"
             :style="{ left: position_horizontal(0),
                       bottom: position_vertical(-0) }">00</div>
        <div class="map-point map-point-sm" title="Sydney"
             :style="{ left: position_horizontal(147.1201174),
                       bottom: position_vertical(-33.0996337) }">S</div>
        <div class="map-point map-point-sm" title="Sth America End"
             :style="{ left: position_horizontal(22.674129),
                       bottom: position_vertical(-34.166060) }">SA</div>


        <div v-for="(data_center) in data_centers"
             :class="set_map_point_class(data_center.validators_count)"
             :style="{ left: position_horizontal(data_center.longitude),
                       bottom: position_vertical(data_center.latitude) }"
             :title="data_center.data_center_key + ' - ' + data_center.latitude">
          {{ data_center.validators_count }}
        </div>
      </div>
    </div>

    <div class="map-legend">
      <div class="map-legend-col">
        <small class="text-muted">Total in {{ network }}</small>
        <div class="small fw-bold">
          <strong class="text-success">{{ total_validators_count }}</strong> Validators
        </div>
        <div class="small">
          <strong class="text-success">{{ total_nodes_count }}</strong> RPC Nodes
        </div>
      </div>
      <div class="map-legend-col">
        <strong id="dataCenterName" class="text-purple">24940-DE-Falkenstein</strong>
        <div id="dataCenterValidatorsCount" class="small text-muted">302 validators</div>
        <div id="dataCenterNodesCount" class="small text-muted">301 nodes</div>
      </div>
    </div>
  </div>

</template>

<script>
  import axios from 'axios';
  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  export default {
    props: {
      network: {
        default: "mainnet"
      },
      titleVisible: {
        default: false
      }
    },
    data () {
      var api_url = "/api/v1/data-centers-with-nodes/" + this.network + "?group_by_country=true"
      return {
        api_url: api_url,
        data_centers: [],
        total_validators_count: 0,
        total_nodes_count: 0,
      }
    },
    created () {
      var ctx = this
      var url = ctx.api_url

      axios.get(url).then(function (response) {
        console.log(response.data.data_centers);
        ctx.data_centers = response.data.data_centers;
        ctx.total_validators_count = response.data.total_validators_count;
        ctx.total_nodes_count = response.data.total_nodes_count;
      })
    },
    watch: {
    },
    methods: {
      position_horizontal: function(longitude) {
        return 50 + (longitude / 160 * 50) + '%';
      },

      position_vertical: function(latitude) {
        if(latitude < 0){
          return 42 + ((latitude / 78) * 50) + '%';
        } else {
          return 42 + ((latitude / 70) * 50) + '%';
        }
      },

      set_map_point_class: function(validators_count) {
        if(typeof(validators_count) != 'number') {
          return "map-point map-point-sm";
        } else if(validators_count < 10) {
          return "map-point map-point-sm";
        } else if(validators_count < 100) {
          return "map-point map-point-md";
        } else {
          return "map-point map-point-lg";
        }
      },
    }
  }
</script>
