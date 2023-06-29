<template>
  <div>
    <div v-if="is_loading" class="col-12 text-center my-5">
      <img v-bind:src="loading_image" width="100">
    </div>
    <div v-else>
      <div v-if="histories.length" class="card mb-4">
        <div class="card-content pb-0" v-if="!standalone">
          <h2 class="h2 card-heading">Authorities Changes</h2>
        </div>

        <div class="table-responsive-md">
          <table class="table mb-0">
            <thead>
              <tr>
                <th class="column-xl" v-if="standalone">Validator</th>
                <th class="column-sm">Authority</th>
                <th class="column-xl">Before</th>
                <th class="column-xl">After</th>
                <th class="column-md">Timestamp</th>
              </tr>
            </thead>
            <tbody v-for="history in histories">
              <tr v-if="is_withdrawer_changed(history)">
                <td v-if="standalone">{{ history.validator_identity }}</td>
                <td>Authorized Withdrawer</td>
                <td class="word-break small">
                  {{ history.authorized_withdrawer_before }}
                </td>
                <td class="word-break small">
                  {{ history.authorized_withdrawer_after }}
                </td>
                <td>
                  {{ date_time_with_timezone(history.created_at) }}
                </td>
              </tr>
              <tr v-if="is_voters_changed(history)">
                <td v-if="standalone">{{ history.validator_identity }}</td>
                <td>Authorized Voters</td>
                <td class="word-break small">
                  {{ history.authorized_voters_before }}
                </td>
                <td class="word-break small">
                  {{ history.authorized_voters_after }}
                </td>
                <td>
                  {{ date_time_with_timezone(history.created_at) }}
                </td>
              </tr>
            </tbody>
          </table>
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
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'
  import loadingImage from 'loading.gif'
  import '../mixins/dates_mixins'
  import '../mixins/arrays_mixins'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  const PER_SIZE = 20

  export default {
    props: {
      vote_account: {
        type: String,
        required: false
      },
      standalone: {
        type: Boolean,
        required: false,
        default: false
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
        if(this.vote_account) {
          return "/api/v1/account-authorities/" + this.network + "?vote_account=" + this.vote_account + "&per=" + PER_SIZE + '&page=' + this.page
        } else {
          return "/api/v1/account-authorities/" + this.network + "?per=" + PER_SIZE + '&page=' + this.page
        }
      },

      is_withdrawer_changed(history) {
        return JSON.stringify(history.authorized_withdrawer_before) !== JSON.stringify(history.authorized_withdrawer_after)
      },

      is_voters_changed(history) {
        let voters_before = Object.values(history.authorized_voters_before || [""])
        let voters_after = Object.values(history.authorized_voters_after || [""])
        return !this.arrays_equal(voters_before, voters_after)
      },

      paginate() {
        this.send_request()
      },

      send_request() {
        const ctx = this
        console.log(ctx.account_authorities_path())
        axios.get(ctx.account_authorities_path())
             .then(response => {
               ctx.histories = response.data.authority_changes
               ctx.total_count = response.data.total_count
               ctx.is_loading = false
               console.log(ctx.histories)
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
