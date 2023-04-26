import Vue from 'vue'

Vue.mixin({
  methods: {
    skipped_vote_percent(validator, batch) {
      if (validator['skipped_vote_history'] && batch['best_skipped_vote']) {
        const history_array = validator['skipped_vote_history']
        const skipped_votes_percent = history_array[history_array.length - 1]

        return skipped_votes_percent ? ((batch['best_skipped_vote'] - skipped_votes_percent) * 100.0).toFixed(2) : null
      } else {
        return null
      }
    },

    skipped_vote_percent_string(skipped_vote_value) {
      return skipped_vote_value ? skipped_vote_value + "%" : "N / A"
    },
  }
})
