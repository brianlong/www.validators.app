<template>
  <div>
    <section class="page-header">
      <h1>Yellowstone Shield Policies</h1>
      <p class="lead">
        Yellowstone Shield is a Solana program that manages on-chain allowlists and blocklists of identities. 
        An identity can be any addressable account in Solana, such as a validator, wallet, or program. 
        This program allows transaction senders, like Agave STS, Helius' Atlas, Mango's lite-rpc, Jito's blockEngine, and Triton's Jet, 
        to effectively control transaction forwarding policies.</p>
    </section>
    <div class="col-12">
      <div class="card">
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
              <td><a :href="`/yellowstone-shield/` + policy.pubkey">{{ policy.pubkey }}</a></td>
              <td>{{ policy.owner }}</td>
              <td>{{ policy.identities_count }}</td>
            </tr>
          </tbody>
        </table>
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
      }
    },

    created() {
      this.get_policies();
    },

    methods: {
      get_policies: function() {
        let policies_url = "/api/v1/policies/mainnet"
        var ctx = this
        axios.get(policies_url)
          .then(function (response) {
            ctx.policies = response.data;
            console.log(response.data);
          })
          .catch(function (error) {
            console.error("Error fetching policies:", error);
          });

      }
    }
  }
</script>
