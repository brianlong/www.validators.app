<template>
  <div>
    <div v-if="is_loading" class="col-12 text-center my-5">
      <img v-bind:src="loading_image" width="100">
    </div>
    <div v-else>
      <div v-if="histories.length" class="card mb-4">
        <div class="card-content pb-0">
          <h2 class="h2 card-heading">Authorities Changes</h2>


        </div>
      </div>

      <div class="card-footer">
        <b-pagination
          v-model="page"
          :total-rows="total_count"
          :per-page="20"
          first-text="« First"
          last-text="Last »"/>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'
  import loadingImage from 'loading.gif'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  const PER_SIZE = 20

  export default {
    props: {
      vote_account: {
        type: String,
        required: true
      }
    },

    data() {
      return {
        histories: [],
        is_loading: true,
        loading_image: loadingImage
      }
    },

    mounted() {
      const ctx = this

      axios.get(ctx.account_authorities_path())
        .then(response => {
          const histories = response.data.sort((a, b) => a.created_at < b.created_at ? 1 : -1)
          this.histories = histories

          ctx.is_loading = false
        })
    },

    methods: {
      account_authorities_path() {
        return "/api/v1/account-authorities/" + this.network + "?vote_account=" + this.vote_account + "&per" + PER_SIZE
      }
    },

    computed: mapGetters([
      'network'
    ])
  }
</script>
