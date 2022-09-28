<template>
  <div class="card map">
    <section class="map-background">
      <div class="map-points">
        <!-- orientation points - TODO to remove after all map-related tasks are done -->
        <!--
        <div class="map-point map-point-sm" title="Map Center" style="left: 50%; bottom: 50%">X</div>
        <div class="map-point map-point-md" title="Point 0,0"
             :style="{ left: position_horizontal(0),
                       bottom: position_vertical(-0) }">00</div>
        <div class="map-point map-point-sm" title="Sydney"
             :style="{ left: position_horizontal(147.1201174),
                       bottom: position_vertical(-33.0996337) }">S</div>
        <div class="map-point map-point-lg" title="Sth America End"
             :style="{ left: position_horizontal(22.674129),
                       bottom: position_vertical(-34.166060) }">SAF</div>
        -->

        <div v-for="data_center in data_centers"
             :class="set_map_point_class(data_center.validators_count)"
             :style="{ left: position_horizontal(data_center.longitude),
                       bottom: position_vertical(data_center.latitude) }"
             :title="data_center.data_center_key"
             v-on:click="select_data_center(data_center)">
          {{ data_center.validators_count }}
        </div>
      </div>
    </section>

    <section class="map-legend">
      <div class="map-legend-col">
        <small class="text-muted">Total in {{ network }}</small>
        <div class="small">
          <strong class="text-success">{{ total_validators_count }}</strong> Validators
        </div>
        <div class="small">
          <strong class="text-success">{{ total_nodes_count }}</strong> Nodes
        </div>
      </div>

      <div class="map-legend-col" v-if="selected_data_center">
        <validators-map-data-center-details :data_center="selected_data_center"/>
      </div>
    </section>
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
    },
    data () {
      var api_url = "/api/v1/data-centers-with-nodes/" + this.network
      return {
        api_url: api_url,
        data_centers: [],
        total_validators_count: 0,
        total_nodes_count: 0,
        selected_data_center: null,
      }
    },
    created () {
      var ctx = this;
      var url = ctx.api_url;

      axios.get(url).then(function (response) {
        ctx.data_centers = response.data.data_centers;
        ctx.total_validators_count = response.data.total_validators_count;
        ctx.total_nodes_count = response.data.total_nodes_count;
      })
    },
    watch: {
      // TODO
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

      select_data_center: function(data_center) {
        this.selected_data_center = data_center;
      }
    }
  }
</script>
