import Vue from 'vue'

Vue.mixin({
  methods: {
    capitalize(word) {
      return word[0].toUpperCase() + word.slice(1)
    }
  }
})