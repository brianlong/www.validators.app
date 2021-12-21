import Vue from 'vue/dist/vue.esm'


var StakePoolStats = Vue.component('StakePoolStats', {
  props: {
    pool: {
      type: Object,
      required: true
    }
  },
  data() {
    return {

    }
  },
  methods: {

  },
  template: `
    <div class="card">
      <div class="card-content">
        <h2> {{ pool.name }} stats </h2>
      </div>
    </div>
  `
})

export default StakePoolStats
