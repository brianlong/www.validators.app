import Vue from 'vue/dist/vue.esm'

var ValidatorsMapDataCenterDetails = Vue.component('ValidatorsMapDataCenterDetails', {
  props: {
    data_center: {
      type: Object,
      required: true
    }
  },
  data() {
    return {}
  },
  template: `
    <div>
      <strong class="text-purple">{{ data_center.data_center_key }}</strong>
      <div class="small text-muted">
        {{ data_center.validators_count }} validator(s)
      </div>
      <div class="small text-muted">
        {{ data_center.gossip_nodes_count }} node(s)
      </div>
    </div>
  `
})

export default ValidatorsMapDataCenterDetails