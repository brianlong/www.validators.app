import Vue from 'vue'

Vue.mixin({
  methods: {
    lamports_to_sol(lamports) {
      return lamports / 1000000000
    }
  }
})
