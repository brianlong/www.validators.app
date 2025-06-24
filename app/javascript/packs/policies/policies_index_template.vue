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
    <div class="col-12 mb-4">
      <div class="d-flex col-lg-6 offset-lg-6">
        <div class="input-group">
          <input
            v-model="searchQuery"
            type="text"
            class="form-control"
            placeholder="Search policies by name, pubkey or validator identity..."
          />
          <button type="button" class="btn btn-primary btn-sm" @click="filterPolicies">Search</button>
        </div>
      </div>
    </div>
    <div class="col-12">
      <div class="card">
        <div class="table-responsive-lg">
          <table class="table">
            <thead>
              <tr>
                <th>Policy Name</th>
                <th>pubkey</th>
                <th>owner</th>
                <th>identities count</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="policy in policies" :key="policy.policy_id">
                <td>{{ policy.policy_name }}</td>
                <td><a :href="`/yellowstone-shield/` + policy.pubkey" data-turbolinks="false">{{ policy.pubkey }}</a></td>
                <td>{{ policy.owner }}</td>
                <td>{{ policy.identities_count }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="d-flex justify-content-end mt-3">
        <p v-if="total_count === 0">No policies found.</p>
        <b-pagination
          v-model="page"
          :total-rows="total_count"
          :per-page="25"
          first-text="« First"
          last-text="Last »" />
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'

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
        let policies_url = "/api/v1/policies/mainnet?query=" + encodeURIComponent(this.searchQuery) + "&page=" + this.page + "&limit=25";
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

    watch: {
      page: function() {
        this.get_policies();
      }
    }
  }
</script>
