import Vue from 'vue'

Vue.mixin({
  methods: {
    fails_count_percentage: function(fails_count, num_of_records) {
      if (!fails_count || !num_of_records || num_of_records === 0) {
        return ''
      }
      const percentage = ((fails_count / num_of_records) * 100).toLocaleString('en-US', {maximumFractionDigits: 1})
      return `(${percentage}%)`
    }
  }
})
