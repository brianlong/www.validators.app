import Vue from 'vue'
import defaultAvatar from 'default-avatar.png'

Vue.mixin({
  methods: {
    skipped_vote_percent(validator, batch) {
      if(validator['skipped_vote_history'] && batch['best_skipped_vote']) {
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

    shortened_validator_name(name, account) {
      if(name) {
        return name
      } else {
        return this.shorten_key(account)
      }
    },

    shorten_key(key) {
      return key.substring(0, 6) + "..." + key.substring(key.length - 4)
    },

    validator_url(validator_account, network) {
      return "/validators/" + validator_account + "?network=" + network
    },

    vote_account_url(validator_account, vote_account, network) {
      return "/validators/" + validator_account + "/vote_accounts/" + vote_account + "?network=" + network
    },

    avatar_url(validator) {
      if(validator['avatar_file_url']) {
        return validator['avatar_file_url']
      } else if (validator['avatar_url']) {
        return validator['avatar_url']
      } else {
        return defaultAvatar
      }
    }
  }
})
