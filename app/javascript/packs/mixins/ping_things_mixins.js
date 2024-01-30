import Vue from 'vue'

Vue.mixin({
  methods: {
    fails_count_percentage: function(fails_count, num_of_records) {
      return fails_count ? '(' + (fails_count / num_of_records * 100).toLocaleString('en-US', {maximumFractionDigits: 1}) + '%)' : ''
    }
  }
})
