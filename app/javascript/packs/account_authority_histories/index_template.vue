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

        <div class="table-responsive-md">
          <table class="table mb-0">
            <thead>
              <tr>
                <th class="column-md">
                  Authorized Withdrawer Before
                </th>
                <th class="column-md">
                  Authorized Withdrawer After
                </th>
                <th class="column-md">
                  Authorized Voters Before
                </th>
                <th class="column-md">
                  Authorized Voters After
                </th>
                <th class="column-md">
                  Timestamp
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="history in histories" class="word-break small">
                <td :class="!is_withdrawer_changed(history) ? 'text-muted' : null">
                  {{ history.authorized_withdrawer_before }}
                </td>
                <td :class="!is_withdrawer_changed(history) ? 'text-muted' : null">
                  {{ history.authorized_withdrawer_after }}
                </td>
                <td :class="!is_voters_changed(history) ? 'text-muted' : null">
                  {{ history.authorized_voters_before }}
                </td>
                <td :class="!is_voters_changed(history) ? 'text-muted' : null">
                  {{ history.authorized_voters_after }}
                </td>
                <td>
                  {{ date_time_with_timezone(history.created_at) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="card-footer d-flex justify-content-between flex-wrap gap-2">
          <b-pagination
            v-model="page"
            :total-rows="total_count"
            :per-page="25"
            first-text="« First"
            last-text="Last »"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'
  import loadingImage from 'loading.gif'
  import '../mixins/dates_mixins'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  const PER_SIZE = 25

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
        loading_image: loadingImage,
        page: 1,
        total_count: 0
      }
    },

    mounted() {
      this.send_request()
    },

    methods: {
      account_authorities_path() {
        return "/api/v1/account-authorities/" + this.network + "?vote_account=" + this.vote_account + "&per=" + PER_SIZE + '&page=' + this.page
      },

      is_withdrawer_changed(history) {
        return JSON.stringify(history.authorized_withdrawer_before) !== JSON.stringify(history.authorized_withdrawer_after)
      },

      is_voters_changed(history) {
        return JSON.stringify(history.authorized_voters_before) !== JSON.stringify(history.authorized_voters_after)
      },

      paginate() {
        this.send_request()
      },

      send_request() {
        const ctx = this
        axios.get(ctx.account_authorities_path())
          .then(response => {
            const histories = response.data.authority_changes.sort((a, b) => a.created_at < b.created_at ? 1 : -1)
            ctx.histories = histories
            ctx.total_count = response.data.total_count
            ctx.is_loading = false
          })
      }
    },

    watch: {
      page() {
        this.paginate()
      }
    },

    computed: mapGetters([
      'network'
    ])
  }
</script>
