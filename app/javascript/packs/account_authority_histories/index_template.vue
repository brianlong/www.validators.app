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
          const histories = response.data.sort((a, b) => a.created_at < b.created_at ? 1 : -1)
          ctx.authorized_withdrawers = histories.filter(h => h.authorized_withdrawer_after)
          ctx.authorized_voters = histories.filter(h => h.authorized_voters_after)

          ctx.is_loading = false
        })
    },

    methods: {
      account_authorities_path() {
        return "/api/v1/account-authorities/" + this.network  + "?vote_account=" + this.vote_account
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
