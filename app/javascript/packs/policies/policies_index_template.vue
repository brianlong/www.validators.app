<template>
  <div>
    <section class="page-header">
      <h1>Yellowstone Shield Policies</h1>
      <p class="lead">
        Yellowstone Shield is a Solana program that manages on-chain allowlists and blocklists of identities. 
        An identity can be any addressable account in Solana, such as a validator, wallet, or program. 
        This program allows transaction senders, like Triton's Jet, Agave STS, Helius' Atlas, Jito's blockEngine
        to effectively control transaction forwarding policies.</p>
    </section>

    <div class="search-row d-flex justify-content-between flex-wrap gap-3 mb-4">
      <div class="input-group">
        <input v-model="searchQuery"
               type="text"
               class="form-control"
               placeholder="Policy name, pubkey or validator identity"/>
        <button type="button" class="btn btn-primary btn-sm" @click="filterPolicies">Search</button>
      </div>
      <a href="#" class="btn btn-sm btn-tertiary">Reset filters</a>
    </div>

    <div class="card" v-if="total_count > 0">
      <div class="table-responsive-lg">
        <table class="table">
          <thead>
            <tr>
              <th class="column-xl">
                Policy Name and Pubkey
                <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                   data-bs-toggle="tooltip"
                   data-bs-placement="top"
                   title="Onchain address of the program.">
                </i>
              </th>
              <th class="column-xl">
                Owner
                <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                   data-bs-toggle="tooltip"
                   data-bs-placement="top"
                   title="Address of the lists creator.">
                </i>
              </th>
              <th class="column-sm text-center text-nowrap">
                Strategy
                <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                   data-bs-toggle="tooltip"
                   data-bs-placement="top"
                   title="Allow or deny.">
                </i>
              </th>
              <th class="column-xs text-center">
                Count
                <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                   data-bs-toggle="tooltip"
                   data-bs-placement="top"
                   title="Number of validators.">
                </i>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="policy in policies" :key="policy.policy_id">
              <td class="d-flex">
                <div class="d-none d-lg-flex me-4">
                  <img :src="policy.image" class='img-circle-large' v-if="policy.image" />
                  <img src="https://uploader.irys.xyz/Hhdy76nXVpNBCg1pVLtpctaZXbpnSufWggbyiMFUoCTh" class='img-circle-large' v-else />
                </div>
                <div class="d-flex flex-column justify-content-center">
                  <a :href="`/yellowstone-shield/` + policy.pubkey" data-turbolinks="false" class="column-info-link no-watchlist fw-bold">
                    {{ policy.name }} <span v-if="policy.symbol">({{ policy.symbol }})</span>
                  </a>
                  <div class="word-break mt-1 small">
                    <a :href="`/yellowstone-shield/` + policy.pubkey" data-turbolinks="false">{{ policy.pubkey }}</a>
                  </div>
                </div>
              </td>
              <td class="word-break small">{{ policy.owner }}</td>
              <td class="text-center">
                <span v-if="policy.strategy" class="text-success">Allow</span>
                <span v-else class="text-danger">Deny</span>
              </td>
              <td class="text-center">{{ policy.identities_count }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="total_count > 0">
      <b-pagination
        v-model="page"
        :total-rows="total_count"
        :per-page="25"
        first-text="« First"
        last-text="Last »" />
    </div>

    <div class="card" v-if="total_count === 0">
      <div class="card-content">No policies found.</div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'


  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    data() {
      return {
        policies: [],
        searchQuery: '',
        page: 1,
        total_count: 0,
      }
    },

    created() {
      this.get_policies();
    },

    methods: {
      get_policies: function() {
        let policies_url = "/api/v1/policies/" + this.network + "?query=" + encodeURIComponent(this.searchQuery) + "&page=" + this.page + "&limit=25";
        var ctx = this
        axios.get(policies_url)
          .then(function (response) {
            console.log("Policies response:", response.data);
            ctx.policies = response.data['policies'] || [];
            ctx.total_count = response.data['total_count'] || 0;
          })
          .catch(function (error) {
            console.error("Error fetching policies:", error);
          });
      },
      filterPolicies() {
        this.get_policies();
      }
    },

    computed: {
      ...mapGetters([
        'network'
      ])
    },

    watch: {
      page: function() {
        this.get_policies();
      }
    }
  }
</script>
