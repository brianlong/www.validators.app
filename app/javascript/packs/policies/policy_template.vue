<template>
  <div>
    <section class="page-header">
      <div class='page-header-name'>
        <img :src="policy.image" class='img-circle-medium' v-if="policy.image" />
        <img src="https://uploader.irys.xyz/Hhdy76nXVpNBCg1pVLtpctaZXbpnSufWggbyiMFUoCTh" class='img-circle-medium' v-else />
        <div class="img-circle-medium-private" v-else>
          <span class='fas fa-users-slash' title="Private Validator"></span>
        </div>

        <h1>
          {{ policy.name || 'Unknown Policy' }}
          <span v-if="policy.symbol">({{ policy.symbol }})</span>
        </h1>
      </div>

      <h2 class="word-break text-muted h5">{{ policy.pubkey }}</h2>
      <p class="lead">{{ policy.description }}</p>
    </section>


    <div class="row">
      <div class="col-lg-6 mb-4">
        <div class="card h-100">
          <div class="card-content pb-0">
            <h2 class="h4 card-heading">Policy details</h2>
          </div>
          <table class="table table-block-sm mb-0">
            <tbody>
              <tr>
                <td><strong>Owner:</strong></td>
                <td class="small word-break">{{ policy.owner || 'Unknown' }}</td>
              </tr>
              <tr>
                <td><strong>Mint:</strong></td>
                <td class="small word-break">{{ policy.mint || 'Unknown' }}</td>
              </tr>
              <tr>
                <td><strong>Strategy:</strong></td>
                <td>
                  <span v-if="policy.strategy == 'Allow'" class="text-success">Allow</span>
                  <span v-else class="text-danger">Deny</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="col-lg-6 mb-4">
        <div class="card h-100 mb-4">
          <div class="card-content pb-0">
            <h2 class="h4 card-heading">Policy details</h2>
          </div>
          <table class="table table-block-sm mb-0">
            <tbody>
              <tr>
                <td class="column-xl"><strong>Validators / Other:</strong></td>
                <td>{{ policy.total_validators ? policy.total_validators : 0 }} / {{ policy.total_other_identities ? policy.total_other_identities : 0 }}</td>
              </tr>
              <tr>
                <td><strong>Metadata URL:</strong></td>
                <td class="small word-break"><a :href="policy.url">{{ policy.url || 'Unknown' }}</a></td>
              </tr>
              <tr>
                <td><strong>Additional attributes:</strong></td>
                <td><span v-if="policy.additional_metadata && policy.additional_metadata.length > 0">{{ policy.additional_metadata }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="d-flex justify-content-between flex-wrap gap-3 mb-4">
      <div class="btn-group btn-group-toggle switch-button">
        <span class="btn btn-secondary btn-sm" @click="show_validators = true" :class="{ active: show_validators }">Validators</span>
        <span class="btn btn-secondary btn-sm" @click="show_validators = false" :class="{ active: !show_validators }">Other identities</span>
      </div>
    </div>


    <div class="card mb-4">
      <table class="table table-block-sm validators-table" v-if="policy && policy.validators && policy.validators.length && show_validators">
        <thead>
          <tr>
            <th class="column-info">
              <div class="column-info-row">
                <div class="column-info-name">
                  Name <small class="text-muted">(Commission)</small>
                  <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                     data-bs-toggle="tooltip"
                     data-bs-placement="top"
                     title="Commission is the percent of network rewards earned by a validator that are deposited into the validator's vote account.">
                  </i>
                  <br />
                  Scores <small class="text-muted">(total)</small>
                  <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                     data-bs-toggle="tooltip"
                     data-bs-placement="top"
                     title="Our score system.">
                  </i>
                </div>
              </div>
            </th>

            <th class='column-chart py-3'>
              Root Distance
              <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                 data-bs-toggle="tooltip"
                 data-bs-placement="top"
                 title="Root distance measures the median & average distance in block height between the validator and the tower's highest block. Smaller numbers mean that the validator is near the top of the tower.">
              </i>
              <br />
              <small class="text-muted">Last 60 Observations</small>
            </th>

            <th class='column-chart py-3'>
              Vote Distance
              <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                 data-bs-toggle="tooltip"
                 data-bs-placement="top"
                 title="Vote distance is very similar to the Root Distance. Lower numbers mean that the node is voting near the front of the group.">
              </i>
              <br />
              <small class="text-muted">Last 60 Observations</small>
            </th>

            <th class='column-chart py-3'>
              Skipped Slot&nbsp;&percnt;
              <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                 data-bs-toggle="tooltip"
                 data-bs-placement="top"
                 title="Skipped slot measures the percent of the time that a leader fails to produce a block during their allocated slots. A lower number means that the leader is making blocks at a very high rate.">
              </i>
              <br />
              <small class="text-muted">Last 60 Observations</small>
            </th>

            <th class='column-chart py-3'>
              Vote Latency
              <i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                 data-bs-toggle="tooltip"
                 data-bs-placement="top"
                 title="Vote latency shows the average number of slots a validator needs to confirm a block. A lower number means that the validator is confirming blocks at a very high rate.">
              </i>
              <br />
              <small class="text-muted">Last 60 Observations</small>
            </th>
          </tr>
        </thead>
        <tbody v-for="(validator, idx) in validators" :key="validator.account">
          <validator-row :validator="validator" :idx="idx" :batch="{}" />
        </tbody>
      </table>

      <div class="card-content" v-if="policy && !policy.validators.length && show_validators">No validators.</div>

      <table class="table" v-if="policy && policy.other_identities && policy.other_identities.length && !show_validators">
        <tbody>
          <tr v-for="(identity, idx) in policy.other_identities" :key="identity">
            <td class="word-break">{{ identity }}</td>
          </tr>
        </tbody>
      </table>

      <div class="card-content" v-if="policy && !policy.other_identities.length && !show_validators">No other identities.</div>
    </div>

    <b-pagination v-model="page"
                  :total-rows="total_count"
                  :per-page="limit"
                  first-text="« First"
                  last-text="Last »" />

  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: {
      pubkey: {
        type: String,
        required: true
      }
    },

    data() {
      return {
        policy: {},
        validators: [],
        show_validators: true,
        page: 1,
        total_count: 0,
        limit: 25
      }
    },

    created() {
      this.get_policy();
    },

    methods: {
      get_policy: function() {
        let policy_url = "/api/v1/policies/" + this.network + "/" + this.pubkey + "?page=" + this.page + "&limit=" + this.limit;
        var ctx = this
        axios.get(policy_url)
          .then(function (response) {
            ctx.policy = response.data;

            ctx.total_count = ctx.show_validators ? ctx.policy.total_validators : ctx.policy.total_other_identities;
            ctx.get_validators();
          })
          .catch(function (error) {
            console.error("Error fetching policy:", error);
          });
      },

      get_validators: function() {
        this.validators = [];
        if (!this.policy || !this.policy.validators) {
          return [];
        }
        this.policy.validators.map((validator, idx) => {
          let ctx = this;
          axios.get('/api/v1/validators/mainnet/' + validator + '?with_history=true')
               .then(function (response) {
                 ctx.validators.push(response.data);
               })
        })
      }
    },

    computed: {
      ...mapGetters([
        'network'
      ])
    },

    watch: {
      page: function() {
        this.get_policy();
      },

      show_validators: function() {
        this.total_count = this.show_validators ? this.policy.total_validators : this.policy.total_other_identities;
      }
    }
  }
</script>
