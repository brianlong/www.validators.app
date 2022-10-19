import Vue from 'vue/dist/vue.esm'

var ValidatorsMapDataCenterDetails = Vue.component('ValidatorsMapDataCenterDetails', {
  props: {
    data_center_group: {
      type: Object,
      required: true
    },
  },
  data() {
    return {}
  },
  methods: {
    sum_validators: function(array, key) {
      return this.$parent.sum_validators(array, key);
    },
  },
  template: `
    <div>
      <strong class="text-purple">
        {{ data_center_group.key }}, {{ data_center_group.values.length }} Data Center(s)
      </strong>
      
      <div class="small" v-if="sum_validators(data_center_group, 'active_validators_count') > 0">
        <strong class="text-purple">
          {{ this.$parent.sum_validators(data_center_group, "active_validators_count") }}
        </strong>
        <span class="text-muted">validator(s)</span>
      </div>
      
      <div class="small" v-if="sum_validators(data_center_group, 'active_gossip_nodes_count') > 0">
        <strong class="text-purple">
          {{ this.$parent.sum_validators(data_center_group, "active_gossip_nodes_count") }}
        </strong>
        <span class="text-muted">node(s)</span>
      </div>
    </div>
  `
})

export default ValidatorsMapDataCenterDetails
