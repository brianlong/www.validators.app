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
             :class="set_map_point_class(data_center.active_validators_count, data_center.active_gossip_nodes_count)"
             :style="{ left: position_horizontal(data_center.longitude),
                       bottom: position_vertical(data_center.latitude) }"
             :title="data_center.data_center_key"
             v-on:click="select_data_center(data_center)">
          <span v-if="data_center.active_gossip_nodes_count">
            {{ data_center.active_validators_count + data_center.active_gossip_nodes_count }}
          </span>
          <span v-else>{{ data_center.active_validators_count }}</span>
        </div>
      </div>
    </section>

    <section class="map-legend">
      <div class="map-legend-col">
        <div class="btn-group btn-group-toggle switch-button mb-3" v-if="show_gossip_nodes">
          <span class="btn btn-xs btn-secondary active">
            <i class="fas fa-eye"></i>
          </span>
          <span class="btn btn-xs btn-secondary"
                v-on:click="set_nodes_visibility(false)">
            <i class="fas fa-eye-slash me-2"></i>nodes
          </span>
        </div>
        <div class="btn-group btn-group-toggle switch-button mb-3" v-else>
          <span class="btn btn-xs btn-secondary"
                v-on:click="set_nodes_visibility(true)">
            <i class="fas fa-eye me-2"></i>nodes
          </span>
          <span class="btn btn-xs btn-secondary active">
            <i class="fas fa-eye-slash"></i>
          </span>
        </div>

        <div class="">
          <div class="small text-muted">Current Leader:</div>
          <div>
            <strong class="text-success">Block Logic | BL</strong>
            <span class="text-muted">(DDnA...oshdp)</span>
          </div>
        </div>
      </div>

      <div class="map-legend-col" v-if="selected_data_center">
        <validators-map-data-center-details :data_center="selected_data_center"/>
      </div>
    </section>
  </div>

</template>

<script>
  import debounce from 'lodash/debounce';
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
        selected_data_center: null,
        show_gossip_nodes: true,
      }
    },
    created () {
      var ctx = this;
      var url = ctx.api_url;

      axios.get(url).then(function (response) {
        ctx.data_centers = response.data.data_centers;
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

      set_map_point_size: function(validators_and_nodes_count) {
        if(typeof(validators_and_nodes_count) != 'number') {
          return "map-point-sm";
        } else if(validators_and_nodes_count < 10) {
          return "map-point-sm";
        } else if(validators_and_nodes_count < 100) {
          return "map-point-md";
        } else {
          return "map-point-lg";
        }
      },

      set_map_point_color: function(validators_count, nodes_count) {
        if(typeof(validators_count) != 'number') {
          return "map-point-mixed";
        } else if(typeof(nodes_count) != 'number') {
          return "map-point-mixed";
        } else if(validators_count > 0 && nodes_count > 0) {
          return "map-point-mixed";
        } else if(validators_count > 0) {
          return "map-point-green";
        } else if(nodes_count > 0) {
          return "map-point-purple";
        } else {
          return "map-point-mixed";
        }
      },

      set_map_point_class: function(validators_count, nodes_count) {
        nodes_count = nodes_count == undefined ? 0 : nodes_count;
        validators_count = validators_count == undefined ? 0 : validators_count;

        var point_size = this.set_map_point_size(validators_count + nodes_count);
        var point_color = this.set_map_point_color(validators_count, nodes_count);

        return "map-point " + point_size + " " + point_color;
      },

      select_data_center: function(data_center) {
        this.selected_data_center = data_center;
      },

      set_nodes_visibility: function(value) {
        this.show_gossip_nodes = value;
        this.refresh_results();
      },

      refresh_results: debounce(function() {
        var ctx = this;
        var query_params = {
          params: {
            show_gossip_nodes: this.show_gossip_nodes
          }
        }
        axios.get(ctx.api_url, query_params).then(function (response) {
          ctx.data_centers = response.data.data_centers;
        })
      }, 2000),

    }
  }
</script>
