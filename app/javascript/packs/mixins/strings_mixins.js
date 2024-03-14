import Vue from 'vue'

Vue.mixin({
  methods: {
    capitalize(word) {
      return word[0].toUpperCase() + word.slice(1)
    },

    pluralize(number, word) {
      if (typeof number !== 'number') return word;
      if(number > 1) {
        return ' ' + word + "s"
      } else {
        return ' ' + word
      }
    }
  }
})
