<template>
  <div class="card map mb-4">
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

        <div v-for="dc_group in data_centers_groups"
             :class="set_map_point_class(dc_group.active_validators_count, dc_group.active_gossip_nodes_count)"
             :style="{ left: position_horizontal(dc_group.longitude),
                       bottom: position_vertical(dc_group.latitude) }"
             v-on:click="select_data_centers_group(dc_group)"
             :key="dc_group.identifier">
          <span v-if="show_gossip_nodes">
            {{ dc_group.active_validators_count + dc_group.active_gossip_nodes_count }}
          </span>
          <span v-else>
            {{ dc_group.active_validators_count }}
          </span>
        </div>

        <div v-if="is_leader_valid"
             :style="{ left: position_horizontal(current_leader.location_longitude),
                       bottom: position_vertical(current_leader.location_latitude) }"
             class="map-point map-point-leader">
          <img :src="avatar_link()" alt="avatar">
        </div>
      </div>
    </section>

    <section class="map-legend">
      <div class="map-legend-col">
        <div class="btn-group btn-group-toggle switch-button" v-if="show_gossip_nodes">
          <span class="btn btn-xs btn-secondary active">
            <i class="fas fa-eye"></i>
          </span>
          <span class="btn btn-xs btn-secondary" v-on:click="set_nodes_visibility(false)">
            <i class="fas fa-eye-slash me-2"></i>RPC nodes
          </span>
        </div>
        <div class="btn-group btn-group-toggle switch-button" v-else>
          <span class="btn btn-xs btn-secondary" v-on:click="set_nodes_visibility(true)">
            <i class="fas fa-eye me-2"></i>RPC nodes
          </span>
          <span class="btn btn-xs btn-secondary active">
            <i class="fas fa-eye-slash"></i>
          </span>
        </div>

        <div class="d-none mt-3">
          <div class="small text-muted">Current Leader:</div>
          <div>
            <strong class="text-success">Block Logic | BL</strong>
            <span class="text-muted">(DDnA...oshdp)</span>
          </div>
        </div>
      </div>

      <div class="map-legend-col" v-if="selected_data_centers_group">
        <validators-map-data-center-details :data_centers_group="selected_data_centers_group"/>
      </div>
    </section>
  </div>

</template>

<script>
  import debounce from 'lodash/debounce';
  import axios from 'axios';
  import { mapGetters } from 'vuex';

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  export default {
    data () {
      return {
        api_url: null,
        data_centers_groups: [],
        selected_data_centers_group: null,
        show_gossip_nodes: false,
        current_leader: null,
      }
    },
    created () {
      this.api_url = "/api/v1/data-centers-with-nodes/" + this.network;
      let ctx = this;
      let query_params = {
          params: {
            show_gossip_nodes: this.show_gossip_nodes
          }
        }

      axios.get(this.api_url, query_params).then(function (response) {
        ctx.data_centers_groups = response.data.data_centers_groups;
      })
    },
    mounted() {
      this.$cable.subscribe({
        channel: 'LeadersChannel',
        room: "public"
      });
    },
    watch: {
    },
    computed: {
      is_leader_valid(){
        return this.current_leader && this.current_leader.location_latitude && this.current_leader.location_longitude
      },
      ...mapGetters([
        'network'
      ])
    },
    channels: {
      LeadersChannel: {
        connected() { },
        rejected() { },
        received(data) {
          data = data[this.network];
          this.current_leader = data.current_leader;
        },
        disconnected() { }
      }
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
      avatar_link() {
        if (this.current_leader.avatar_url) {
          return this.current_leader.avatar_url
        } else {
          return "https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png"
        }
      },
      set_map_point_size: function(validators_and_nodes_count) {
        if(typeof(validators_and_nodes_count) != 'number') {
          return "map-point-sm";
        } else if(validators_and_nodes_count < 10) {
          return "map-point-sm";
        } else if(validators_and_nodes_count < 100) {
          return "map-point-md";
        } else if(validators_and_nodes_count < 1000) {
          return "map-point-lg";
        } else {
          return "map-point-xl";
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
        let point_size = this.set_map_point_size(validators_count + nodes_count);
        let point_color = this.set_map_point_color(validators_count, nodes_count);

        return `map-point ${point_size} ${point_color}`;
      },

      select_data_centers_group: function(dc_group) {
        this.selected_data_centers_group = dc_group;
      },

      set_nodes_visibility: function(value) {
        this.show_gossip_nodes = value;
        this.refresh_results();
      },

      refresh_results: debounce(function() {
        let ctx = this;
        let query_params = {
          params: {
            show_gossip_nodes: this.show_gossip_nodes
          }
        }
        axios.get(ctx.api_url, query_params).then(function (response) {
          ctx.data_centers_groups = response.data.data_centers_groups;
        })
      }, 2000),

    }
  }
</script>
