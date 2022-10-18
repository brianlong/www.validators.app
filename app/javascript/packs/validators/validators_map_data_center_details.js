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
      <strong class="text-purple">{{ data_center_group.key }}</strong>
      <div class="small text-muted" v-if="sum_validators(data_center_group, 'active_validators_count') > 0">
        {{ this.$parent.sum_validators(data_center_group, "active_validators_count") }} validator(s)
      </div>
      <div class="small text-muted" v-if="sum_validators(data_center_group, 'active_gossip_nodes_count') > 0">
        {{ this.$parent.sum_validators(data_center_group, "active_gossip_nodes_count") }} node(s)
      </div>
    </div>
  `
})

export default ValidatorsMapDataCenterDetails
