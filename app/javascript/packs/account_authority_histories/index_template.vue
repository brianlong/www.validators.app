<template>
  <div>
    <div v-if="is_loading" class="col-12 text-center my-5">
      <img v-bind:src="loading_image" width="100">
    </div>
    <div v-else>
      <div v-if="authorized_withdrawers.length" class="card mb-4">
        <div class="card-content pb-0">
          <h2 class="h2 card-heading">Withdrawers History</h2>
          <AuthorizedWithdrawers :withdrawers="authorized_withdrawers" />
        </div>
      </div>
      <div v-if="authorized_voters.length" class="card mb-4">
        <div class="card-content pb-0">
          <h2 class="h2 card-heading">Voters History</h2>
          <AuthorizedVoters :voters="authorized_voters" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'
  import AuthorizedWithdrawers from './authorized_withdrawers'
  import AuthorizedVoters from './authorized_voters'
  import loadingImage from 'loading.gif'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  const unique = require('array-unique')

  export default {
    props: {
      vote_account: {
        type: String,
        required: true
      }
    },

    data() {
      return {
        authorized_voters: [],
        authorized_withdrawers: [],
        is_loading: true,
        loading_image: loadingImage
      }
    },

    mounted() {
      const ctx = this

      axios.get(ctx.account_authorities_path())
        .then(response => {
          // Sort by ascending order
          const histories = response.data.sort((a, b) => a.created_at < b.created_at ? -1 : 1)

          this.set_unique_authorized_withdrawers(histories)
          this.set_unique_authorized_voters(histories)

          // Sort by descending order in order to display the latest records
          ctx.authorized_withdrawers = ctx.authorized_withdrawers.sort((a, b) => a.created_at < b.created_at ? 1 : -1)
          ctx.authorized_voters = ctx.authorized_voters.sort((a, b) => a.created_at < b.created_at ? 1 : -1)

          ctx.is_loading = false
        })
    },

    methods: {
      account_authorities_path() {
        return "/api/v1/account-authorities/" + this.network  + "?vote_account=" + this.vote_account
      },

      set_unique_authorized_withdrawers(histories) {
        const authorized_withdrawers_vals = histories.map(function (history) {
          return JSON.stringify(history.authorized_withdrawer_after)
        })
        unique(authorized_withdrawers_vals).forEach(voter => {
          this.authorized_withdrawers.push(
            histories.find(history => JSON.stringify(history.authorized_withdrawer_after) === voter)
          )
        })
      },
      set_unique_authorized_voters(histories) {
        const authorized_voters_vals = histories.map(function (history) {
          return JSON.stringify(history.authorized_voters_after)
        })
        unique(authorized_voters_vals).forEach(voter => {
          this.authorized_voters.push(
            histories.find(history => JSON.stringify(history.authorized_voters_after) === voter)
          )
        })
      }
    },

    computed: mapGetters([
      'network'
    ]),

    components: {
      "AuthorizedWithdrawers": AuthorizedWithdrawers,
      "AuthorizedVoters": AuthorizedVoters
    }
  }
</script>
