import Vue from 'vue'

Vue.mixin({
  methods: {
    capitalize: function (word) {
      return word[0].toUpperCase() + word.slice(1)
    }
  }
})
