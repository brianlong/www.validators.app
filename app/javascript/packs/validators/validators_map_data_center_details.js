import Vue from 'vue/dist/vue.esm'

var ValidatorsMapDataCenterDetails = Vue.component('ValidatorsMapDataCenterDetails', {
  props: {
    data_centers_group: {
      type: Object,
      required: true
    },
  },
  data() {
    return {}
  },
  methods: {
    text_color: function(validators_count, nodes_count) {
      if(typeof(nodes_count) != 'number') {
        return "text-success";
      } else if(nodes_count == 0) {
        return "text-success";
      } else if(nodes_count > 0 && validators_count > 0) {
        return "text-green-purple";
      } else {
        return "text-purple";
      }
    },
  },
  template: `
    <div class="map-legend-details mb-3 text-sm-end">
      <strong :class="text_color(data_centers_group.active_validators_count, data_centers_group.active_gossip_nodes_count)">
        {{ data_centers_group.identifier }}, 
        {{ data_centers_group.data_centers.length }} Data Center(s)
      </strong>
      
      <div class="small" v-if="data_centers_group.active_validators_count > 0">
        <strong :class="text_color(data_centers_group.active_validators_count, data_centers_group.active_gossip_nodes_count)">
          {{ data_centers_group.active_validators_count }}
        </strong>
        <span class="text-muted">validator(s)</span>
      </div>
      
      <div class="small" v-if="data_centers_group.active_gossip_nodes_count > 0">
        <strong :class="text_color(data_centers_group.active_validators_count, data_centers_group.active_gossip_nodes_count)">
          {{ data_centers_group.active_gossip_nodes_count }}
        </strong>
        <span class="text-muted">RPC node(s)</span>
      </div>
    </div>
  `
})

export default ValidatorsMapDataCenterDetails
