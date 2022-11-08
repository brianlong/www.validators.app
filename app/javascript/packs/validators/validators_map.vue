<template>
  <div class="card map mb-4">
    <section class="map-background">
      <div class="map-points">
        <!-- orientation points - TODO to remove after all map-related tasks are done -->
        <!--
                <div class="map-point map-point-sm map-point-green" title="Map Center" style="left: 50%; bottom: 50%">X</div>
                <div class="map-point map-point-md map-point-green" title="Point 0,0"
                     :style="{ left: position_horizontal(0),
                               bottom: position_vertical(-0) }">00</div>
                <div class="map-point map-point-sm map-point-purple" title="Sydney"
                     :style="{ left: position_horizontal(147.1201174),
                               bottom: position_vertical(-33.0996337) }">S</div>
                <div class="map-point map-point-lg map-point-purple" title="Sth America End"
                     :style="{ left: position_horizontal(22.674129),
                               bottom: position_vertical(-34.166060) }">SAF</div>
                <div class="map-point map-point-md map-point-purple" title="Mexico City"
                     :style="{ left: position_horizontal(-99.201635),
                               bottom: position_vertical(19.4962828) }">Mex</div>
                <div class="map-point map-point-md map-point-purple" title="Madagascar"
                     :style="{ left: position_horizontal(46.2817152),
                               bottom: position_vertical(-19.5849402) }">Ma</div>
                <div class="map-point map-point-md map-point-purple" title="Tokyo"
                     :style="{ left: position_horizontal(139.7025779),
                               bottom: position_vertical(35.7050326) }">To</div>
                <div class="map-point map-point-md map-point-purple" title="London"
                     :style="{ left: position_horizontal(-0.4963255),
                               bottom: position_vertical(51.52103) }">Lon</div>
                <div class="map-point map-point-md map-point-purple" title="Florida"
                     :style="{ left: position_horizontal(-81.769220),
                               bottom: position_vertical(28.0079028) }">Fl</div>
                <div class="map-point map-point-md map-point-purple" title="Papua"
                     :style="{ left: position_horizontal(141.1372805),
                               bottom: position_vertical(-5.6746548) }">Pap</div>
                <div class="map-point map-point-md map-point-purple" title="Madrid"
                     :style="{ left: position_horizontal(-3.8651348),
                               bottom: position_vertical(40.522122) }">Md</div>
                <div class="map-point map-point-md map-point-purple" title="Ireland"
                     :style="{ left: position_horizontal(-7.8912691),
                               bottom: position_vertical(53.2252519) }">Ir</div>
                <div class="map-point map-point-md map-point-purple" title="Trondheim Norway"
                     :style="{ left: position_horizontal(10.327793),
                               bottom: position_vertical(63.4340453) }">Tro</div>
                <div class="map-point map-point-md map-point-purple" title="Oslo Norway"
                     :style="{ left: position_horizontal(10.701824),
                               bottom: position_vertical(59.924618) }">No</div>
                <div class="map-point map-point-md map-point-purple" title="Rome"
                     :style="{ left: position_horizontal(11.9616935),
                               bottom: position_vertical(41.9091516) }">Rom</div>
                <div class="map-point map-point-md map-point-purple" title="Rio"
                     :style="{ left: position_horizontal(-43.242874),
                               bottom: position_vertical(-22.7893) }">Rio</div>
                <div class="map-point map-point-md map-point-purple" title="Singapore"
                     :style="{ left: position_horizontal(103.832760),
                               bottom: position_vertical(1.351746) }">Sig</div>
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


        <div v-if="current_leader"
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
        show_gossip_nodes: true,
        current_leader: null,
      }
    },
    created () {
      this.api_url = "/api/v1/data-centers-with-nodes/" + this.network;
      let ctx = this;
      let url = ctx.api_url;

      axios.get(url).then(function (response) {
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
    computed: mapGetters([
      'network'
    ]),
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
        if(longitude < 0) {
          return 46 + ((longitude / 142) * 50) + '%';
        } else {
          return 46 + ((longitude / 145) * 50) + '%';
        }
      },

      position_vertical: function(latitude) {
        if(latitude < 0){
          return 32 + ((latitude / 65) * 50) + '%';
        } else {
          return 32 + ((latitude / 59) * 50) + '%';
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
