<template>
  <div>
    <div class="card mb-4">
      <div class="card-content pb-0">
        <h2 class="h2 card-heading">Withdrawers History</h2>
        <AuthorizedWithdrawer authorized_withdrawer />
      </div>
    </div>
    <div class="card mb-4">
      <div class="card-content pb-0">
        <h2 class="h2 card-heading">Voters History</h2>
        <AuthorizedVoters authorized_voters />
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'

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
        authorized_voters: null,
        authorized_withdrawer: null
      }
    },

    mounted() {
      const ctx = this

      axios.get(ctx.account_authorities_path())
        .then(response => {
          const histories = response.data.sort((a, b) => a.created_at - b.created_at)
          ctx.authorized_voters = histories.filter(h => h.authorized_voters_after)
          ctx.authorized_withdrawer = histories.filter(h => h.authorized_withdrawer_after)  
        })
    },

    methods: {
      account_authorities_path() {
        return "/api/v1/account-authorities/" + this.network  + "?vote_account=" + this.vote_account
      }
    },

    computed: mapGetters([
      'network'
    ])
  }
</script>
