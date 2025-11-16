<template>
  <div>
    <!-- Search Field above card -->
    <div class="d-flex justify-content-between flex-wrap flex-column flex-md-row gap-3 mb-4">
      <div class="d-flex flex-wrap flex-column flex-sm-row gap-3">
        <form @submit.prevent>
          <input
              type="text"
              ref="searchInput"
              v-model="search_query"
              @keydown.enter.prevent
              @input="debounced_search"
              class="form-control"
              style="min-width: 330px"
              placeholder="Search by validator name or account..."
              :disabled="loading"
          />
        </form>
        <div class="d-flex gap-3">
          <button
              :class="commission_change_filter === 'increase' ? 'btn btn-sm btn-primary w-50' : 'btn btn-sm btn-secondary w-50'"
              type="button"
              @click="filter_by_increase"
              :disabled="loading"
              title="Show only commission increases">
            <i class="fa-solid fa-up-long text-danger"></i>
          </button>
          <button
              :class="commission_change_filter === 'decrease' ? 'btn btn-sm btn-primary w-50' : 'btn btn-sm btn-secondary w-50'"
              type="button"
              @click="filter_by_decrease"
              :disabled="loading"
              title="Show only commission decreases">
            <i class="fa-solid fa-down-long"></i>
          </button>
        </div>
      </div>
      <button
          class="btn btn-sm btn-tertiary"
          type="button"
          @click="clear_search"
          :disabled="loading"
          v-if="search_query || commission_change_filter"
          title="Clear all filters">
        Reset filters
      </button>
    </div>

    <div class="card mb-4">
    <div class="table-responsive-lg">
      <table class='table'>
        <thead>
          <tr>
            <th class="column-xl">
              <a href="#" @click.prevent="sort_by_validator">Validator</a>
            </th>
            <th class="column-md">
              <a href="#" @click.prevent="sort_by_epoch">Epoch</a><br />
              <small class="text-muted">(completion %)</small>
            </th>
            <th class="column-sm">Source</th>
            <th class="column-lg text-center px-2">
              Before<i class="fa-solid fa-right-long px-2"></i>After
            </th>
            <th class="column-md">
              <a href="#" @click.prevent="sort_by_timestamp">Timestamp</a>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="5" class="text-center">
              <i class="fa-solid fa-spinner fa-spin"></i> Loading...
            </td>
          </tr>
          <commission-history-row 
            v-else
            @filter_by_query="filter_by_query" 
            v-for="ch in commission_histories" 
            :key="ch.id" 
            :comm_history="ch">
          </commission-history-row>
        </tbody>
      </table>
    </div>
  </div>
</div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex';

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['query'],
    data () {
      return {
        commission_histories: [],
        page: 1,
        total_count: 0,
        sort_by: 'created_at_desc',
        api_url: null,
        account_name: this.query,
        search_query: this.query || '',
        loading: false,
        search_timeout: null,
        commission_change_filter: null // 'increase', 'decrease', or null
      }
    },

    created () {
      if (this.query) {
        this.api_url = '/api/v1/commission-changes/' + this.network + '?query=' + this.query + '&'
      } else {
        this.api_url = '/api/v1/commission-changes/' + this.network + '?'
      }
      var ctx = this
      var url = ctx.api_url + 'sort_by=' + ctx.sort_by

      axios.get(url)
      .then(function (response) {
        ctx.commission_histories = response.data.commission_histories;
        ctx.total_count = response.data.total_count;
      })
    },

    watch: {
      sort_by: function() {
        var ctx = this
        var url = ctx.api_url + 'sort_by=' + ctx.sort_by + '&page=' + ctx.page

        if (ctx.checkAccountNamePresence())  {
          url = url + '&query=' + ctx.account_name
        }

        axios.get(url)
             .then(function (response) {
               ctx.commission_histories = response.data.commission_histories;
               ctx.total_count = response.data.total_count;
             })
      },
      page: function() {
        this.paginate()
      },
      account_name: function() {
        var ctx = this
        var url = ctx.build_api_url();

        axios.get(url)
             .then(function (response) {
                ctx.commission_histories = response.data.commission_histories;
                ctx.total_count = response.data.total_count;
                ctx.loading = false;
                // Restore focus after search completes
                ctx.$nextTick(() => {
                  if (ctx.$refs.searchInput && ctx.search_query) {
                    ctx.$refs.searchInput.focus();
                  }
                });
              })
             .catch(function() {
                ctx.loading = false;
                // Restore focus after error
                ctx.$nextTick(() => {
                  if (ctx.$refs.searchInput && ctx.search_query) {
                    ctx.$refs.searchInput.focus();
                  }
                });
              })
      }
    },

    computed: mapGetters([
      'network'
    ]),

    methods: {
      paginate: function() {
        this.loading = true;
        var ctx = this
        var url = ctx.api_url + 'sort_by=' + ctx.sort_by + '&page=' + ctx.page

        if (ctx.checkAccountNamePresence())  {
          url = url + '&query=' + ctx.account_name
        }

        axios.get(url)
             .then(response => {
               ctx.commission_histories = response.data.commission_histories;
               ctx.loading = false;
               // Restore focus after data loads if search was performed
               ctx.$nextTick(() => {
                 if (ctx.$refs.searchInput && ctx.search_query) {
                   ctx.$refs.searchInput.focus();
                 }
               });
             })
             .catch(() => {
               ctx.loading = false;
               // Restore focus after error if search was performed
               ctx.$nextTick(() => {
                 if (ctx.$refs.searchInput && ctx.search_query) {
                   ctx.$refs.searchInput.focus();
                 }
               });
             });
      },
      sort_by_epoch: function() {
        this.sort_by = this.sort_by == 'epoch_desc' ? 'epoch_asc' : 'epoch_desc'
      },
      sort_by_timestamp: function() {
        this.sort_by = this.sort_by == 'timestamp_asc' ? 'timestamp_desc' : 'timestamp_asc'
      },
      sort_by_validator: function() {
        this.sort_by = this.sort_by == 'validator_desc' ? 'validator_asc' : 'validator_desc'
      },
      filter_by_query: function(query) {
        this.account_name = query;
      },
      reset_filters: function() {
        this.account_name = '';
        this.search_query = '';
        this.commission_change_filter = null;
      },
      resetFilterVisibility: function() {
        // This checks if there is a account id in the link.
        var props_query = this.$options.propsData['query']

        if (this.checkAccountNamePresence() && props_query == null) {
          return true
        } else {
          return false
        }
      },
      checkAccountNamePresence: function() {
        if (this.account_name !== '' && this.account_name != undefined && this.account_name != null) {
          return true
        } else {
          return false
        }
      },
      debounced_search: function() {
        // Clear previous timeout
        if (this.search_timeout) {
          clearTimeout(this.search_timeout);
        }
        
        // Set new timeout for 500ms delay
        this.search_timeout = setTimeout(() => {
          this.perform_search();
        }, 500);
      },
      perform_search: function() {
        // Only set loading if we actually have a search query or if we're clearing it
        if (this.search_query !== this.account_name) {
          this.loading = true;
        }
        this.page = 1; // Reset to first page on new search
        this.account_name = this.search_query;
        // Loading will be set to false in the watch for account_name
      },
      clear_search: function() {
        this.search_query = '';
        this.account_name = '';
        this.commission_change_filter = null;
        // Restore focus after clearing
        this.$nextTick(() => {
          if (this.$refs.searchInput) {
            this.$refs.searchInput.focus();
          }
        });
      },
      filter_by_increase: function() {
        if (this.commission_change_filter === 'increase') {
          // If already filtering by increase, clear the filter
          this.commission_change_filter = null;
        } else {
          this.commission_change_filter = 'increase';
        }
        this.refresh_data();
      },
      filter_by_decrease: function() {
        if (this.commission_change_filter === 'decrease') {
          // If already filtering by decrease, clear the filter
          this.commission_change_filter = null;
        } else {
          this.commission_change_filter = 'decrease';
        }
        this.refresh_data();
      },
      refresh_data: function() {
        this.loading = true;
        this.page = 1;
        // Trigger data refresh by updating account_name or calling API directly
        var ctx = this;
        var url = ctx.build_api_url();
        
        axios.get(url)
             .then(function (response) {
               ctx.commission_histories = response.data.commission_histories;
               ctx.total_count = response.data.total_count;
               ctx.loading = false;
             })
             .catch(function() {
               ctx.loading = false;
             });
      },
      build_api_url: function() {
        var url = this.api_url + 'sort_by=' + this.sort_by + '&page=' + this.page;
        
        if (this.account_name) {
          url += '&query=' + this.account_name;
        }
        
        if (this.commission_change_filter) {
          url += '&change_type=' + this.commission_change_filter;
        }
        
        return url;
      }
    }
  }
</script>
