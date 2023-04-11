<template>
  <div class="card map mb-4">
    <section class="map-background">
      <div class="map-points">
        <div v-for="dc_group in data_centers_groups"
             :class="set_map_point_class(dc_group.active_validators_count, dc_group.active_gossip_nodes_count)"
             :style="{ left: position_horizontal(dc_group.longitude),
                       bottom: position_vertical(dc_group.latitude) }"
             v-on:click="select_data_centers_group(dc_group)"
             :key="dc_group.identifier"
             title="See details">
          <span v-if="show_gossip_nodes">
            {{ dc_group.active_validators_count + dc_group.active_gossip_nodes_count }}
          </span>
          <span v-else>
            {{ dc_group.active_validators_count }}
          </span>
        </div>

        <a :href="validator_details_link(current_leader.account)"
           title="Go to validator details" target="_blank"
           v-if="is_leader_valid"
           :style="{ left: position_horizontal(current_leader.location_longitude),
                     bottom: position_vertical(current_leader.location_latitude) }"
           class="map-point map-point-leader">
          <img :src="avatar_link(current_leader)" alt="avatar" />
        </a>
      </div>
    </section>

    <section class="map-legend">
      <validators-map-leaders :current_leader="current_leader"
                              :next_leaders="next_leaders" />

      <div class="map-legend-col text-sm-end">
        <validators-map-data-center-details :data_centers_group="selected_data_centers_group"
                                            v-if="selected_data_centers_group" />

        <div class="d-flex flex-wrap gap-3">
          <div class="btn-group btn-group-toggle switch-button" v-if="show_gossip_nodes">
            <span class="btn btn-xs btn-secondary active">
              <i class="fa-solid fa-eye"></i>
            </span>
            <span class="btn btn-xs btn-secondary" v-on:click="set_nodes_visibility(false)">
              <i class="fa-solid fa-eye-slash me-2"></i>RPC nodes
            </span>
          </div>
          <div class="btn-group btn-group-toggle switch-button" v-else>
            <span class="btn btn-xs btn-secondary" v-on:click="set_nodes_visibility(true)">
              <i class="fa-solid fa-eye me-2"></i>RPC nodes
            </span>
            <span class="btn btn-xs btn-secondary active">
              <i class="fa-solid fa-eye-slash"></i>
            </span>
          </div>
          <a :href="data_centers_link()" target="_blank" class="btn btn-xs btn-secondary">
            Data Centers
            <i class="fa-solid fa-arrow-up-right-from-square ms-1"></i>
          </a>
        </div>
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
    data() {
      return {
        api_url: null,
        data_centers_groups: [],
        selected_data_centers_group: null,
        show_gossip_nodes: false,
        current_leader: null,
        next_leaders: [],
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

    computed: {
      is_leader_valid() {
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
          if(data) {
            this.current_leader = data.current_leader;
            this.next_leaders = data.next_leaders;
          }
        },
        disconnected() { }
      }
    },

    methods: {
      position_horizontal: function(longitude) {
        let division_factor = longitude < 0 ? 142 : 145
        let start_position = 46
        return start_position + ((longitude / division_factor) * 50) + '%';
      },

      position_vertical: function(latitude) {
        let division_factor = latitude < 0 ? 64 : 58
        let start_position = 32
        return start_position + ((latitude / division_factor) * 50) + '%';
      },

      avatar_link(leader) {
        if (leader.avatar_url) {
          return leader.avatar_url
        } else {
          return "https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png"
        }
      },

      validator_details_link(account) {
        return `/validators/${account}?network=${this.network}`;
      },

      data_centers_link() {
        return `/data-centers?network=${this.network}`;
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
        this.selected_data_centers_group = null;
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
