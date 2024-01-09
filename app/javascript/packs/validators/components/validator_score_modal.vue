<template>
  <div class="modal modal-large fade"
       id="scoresModal"
       tabindex="-1"
       role="dialog"
       aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content" v-if="validator">
        <div class="modal-header">
          <h6 class="modal-title">
            <a :href="`validators/${validator.account}?network=${network}`"
               class="fw-bold" >
              {{ validator.name }}
            </a>
            total score: {{ score.displayed_total_score }} <span class="text-muted">(max 13)</span>
          </h6>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>

        <div class="modal-body p-0">
          <table class="table table-scores mb-0">
            <tbody>
              <tr>
                <td class="column-md fw-bold">Root Distance Score</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + score.root_distance_score"
                     class="fa-solid fa-circle me-1">
                  </i>
                  {{ score.root_distance_score }}
                  <small class="d-lg-none text-muted">(2)</small>
                  <small class="d-none d-lg-inline text-muted">(max 2)</small>
                </td>
                <td class="column-md small">
                  This score measures the&nbsp;median &&nbsp;average distance in block height between the&nbsp;validator
                  and the&nbsp;tower's highest block.
                </td>
              </tr>

              <tr>
                <td class="column-md fw-bold">Vote Distance Score</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + parseInt(score.vote_distance_score)"
                     class="fa-solid fa-circle me-1">
                  </i>
                  {{ score.vote_distance_score }}
                  <small class="d-lg-none text-muted">(2)</small>
                  <small class="d-none d-lg-inline text-muted">(max 2)</small>
                </td>
                <td class="column-lg small">
                  This score is very similar to the&nbsp;Root Distance. Lower numbers mean that the&nbsp;node is voting
                  near the front of the&nbsp;group.
                </td>
              </tr>

              <tr>
                <td class="column-md fw-bold">Skipped Slot Score</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + parseInt(score.skipped_slot_score)"
                     class="fa-solid fa-circle me-1">
                  </i>
                  {{ score.skipped_slot_score }}
                  <small class="d-lg-none text-muted">(2)</small>
                  <small class="d-none d-lg-inline text-muted">(max 2)</small>
                </td>
                <td class="column-lg small">
                  This score measures the&nbsp;percent of the&nbsp;time that a&nbsp;leader fails to produce a&nbsp;block
                  during their allocated slots.
                </td>
              </tr>

              <tr>
                <td class="column-md fw-bold">Skipped After Score</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + parseInt(score.skipped_after_score)"
                     class="fa-solid fa-circle me-1">
                  </i>
                  {{ score.skipped_after_score }}
                  <small class="d-lg-none text-muted">(2)</small>
                  <small class="d-none d-lg-inline text-muted">(max 2)</small>
                </td>
                <td class="column-lg small">
                  This score shows the performance by the leader AFTER the designated node.
                </td>
              </tr>

              <tr>
                <td class="column-md fw-bold">Published Information Score</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + parseInt(score.published_information_score)"
                     class="fa-solid fa-circle me-1"></i>
                  {{ score.published_information_score }}
                  <small class="d-lg-none text-muted">(2)</small>
                  <small class="d-none d-lg-inline text-muted">(max 2)</small>
                </td>
                <td class="column-lg small">
                  This score measures the&nbsp;contact information that the&nbsp;validator has posted to
                  the&nbsp;blockchain.
                </td>
              </tr>

              <tr>
                <td class="column-md fw-bold">Software Version Score</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + parseInt(score.software_version_score)"
                     class="fa-solid fa-circle me-1"></i>
                  {{ score.software_version_score }}
                  <small class="d-lg-none text-muted">(2)</small>
                  <small class="d-none d-lg-inline text-muted">(max 2)</small>
                </td>
                <td class="column-lg small">
                  This score is based on the&nbsp;Solana software version currently in use on this node.
                </td>
              </tr>

              <tr>
                <td class="column-md fw-bold">Bonus Point</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + parseInt(score.security_report_score)"
                     class="fa-solid fa-circle me-1"></i>
                  {{ score.security_report_score }}
                  <small class="d-lg-none text-muted">(1)</small>
                  <small class="d-none d-lg-inline text-muted">(max 1)</small>
                </td>
                <td class="column-lg small">
                  Bonus Point is assigned for providing a&nbsp;URL to validator's web page related to security policies.
                </td>
              </tr>

              <tr v-if="parseInt(score.stake_concentration_score) < 0">
                <td class="column-md fw-bold">Stake Concentration Score</td>
                <td class="column-xs text-nowrap">
                  <i class="fa-solid fa-minus-circle me-1 text-warning"></i>
                  {{ score.stake_concentration_score }}
                  <small class="d-lg-none text-muted">(0)</small>
                  <small class="d-none d-lg-inline text-muted">(max 0)</small>
                </td>
                <td class="column-lg small">
                  This is a&nbsp;contra-score and will deduct points if the validator is one of the&nbsp;top
                  33%&nbsp;active stake holders.
                </td>
              </tr>

              <tr v-if="parseInt(score.data_center_concentration_score) < 0">
                <td class="column-md fw-bold">Data Center Concentration Score</td>
                <td class="column-xs text-nowrap">
                  <i class="fa-solid fa-minus-circle me-1 text-warning"></i>
                  {{ score.data_center_concentration_score }}
                  <small class="d-lg-none text-muted">(0)</small>
                  <small class="d-none d-lg-inline text-muted">(max 0)</small>
                </td>
                <td class="column-lg small">
                  This is a&nbsp;contra-score and will deduct points from the&nbsp;validator located in data centers
                  that host a&nbsp;high percentage of other Solana validators.
                </td>
              </tr>

              <tr v-if="parseInt(score.authorized_withdrawer_score) < 0">
                <td class="column-md fw-bold">Authorized Withdrawer Score</td>
                <td class="column-xs text-nowrap">
                  <i class="fa-solid fa-minus-circle me-1 text-warning"></i>
                  {{ score.authorized_withdrawer_score }}
                    <small class="d-lg-none text-muted">(0)</small>
                    <small class="d-none d-lg-inline text-muted">(max 0)</small>
                </td>
                <td class="column-lg small">
                  This is a&nbsp;contra-score and will deduct points from the&nbsp;validator whose identity
                  matches authorized withdrawer.
                </td>
              </tr>

              <tr v-if="parseInt(score.consensus_mods_score) < 0">
                <td class="column-md fw-bold">Consensus Mods Score</td>
                <td class="column-xs text-nowrap">
                  <i class="fa-solid fa-minus-circle me-1 text-warning"></i>
                  {{ score.consensus_mods_score }}
                    <small class="d-lg-none text-muted">(0)</small>
                    <small class="d-none d-lg-inline text-muted">(max 0)</small>
                </td>
                <td class="column-lg small">
                  This is a&nbsp;contra-score and will deduct points from the&nbsp;validator that appears
                  to&nbsp;use unproven software modifications.
                </td>
              </tr>
            </tbody>
          </table>
          <div class="px-3 pb-3 pt-2 text-muted text-center">
            <small>See <a :href="`/faq?network=${network}#score`">Our Scoring System</a> page for more information.</small>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import axios from 'axios';
  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  export default {
    props: {
      account_prop: {
        type: String,
        required: false
      }
    },

    data() {
      return {
        account: this.account_prop || '',
        validator: null,
        score: null
      }
    },

    created() {
      if(this.account != "") {
        this.update_account(this.account)
      }
    },

    mounted() {
      this.$root.$on('set_modal_account', data => {
        this.update_account(data);
      });
    },

    methods: {
      update_account(account) {
        this.account = account
        let ctx = this
        axios.get("/api/v1/validators/" + this.network + "/" + this.account + "?internal=true").then(function (response) {
          ctx.validator = JSON.parse(response.data.validator)
          ctx.score = JSON.parse(response.data.score)
        })
      }
    },

    watch: {
      'account_prop': function() {}
    },

    computed: mapGetters([
      'web3_url',
      'network'
    ])
  }
</script>
