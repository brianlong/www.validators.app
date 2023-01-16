<template>

  <div class="modal modal-large fade"
       :id="'scoresModal' + validator.account"
       tabindex="-1"
       role="dialog"
       aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h6 class="modal-title">
            <a :href="`validators/${validator.account}?network=${network}`"
               class="fw-bold" >
              {{ validator.name }}
            </a>
            total score: {{ validator.score.displayed_total_score }} <span class="text-muted">(max 11)</span>
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
                  <i :class="'score-' + validator.root_distance_score"
                     class="fas fa-circle me-1>">
                  </i>
                  {{ validator.root_distance_score }}
                  <small class="d-lg-none text-muted">(2)</small>
                  <small class="d-none d-lg-inline text-muted">(max 2)</small>
                </td>
                <td class="column-md small">
                  This score measures the&nbsp;median &&nbsp;average distance in block height between the&nbsp;validator
                  and
                  the&nbsp;tower's highest block.
                </td>
              </tr>

              <tr>
                <td class="column-md fw-bold">Vote Distance Score</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + parseInt(validator.vote_distance_score)"
                     class="fas fa-circle me-1">
                  </i>
                  {{ validator.vote_distance_score }}
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
                  <i :class="'score-' + parseInt(validator.skipped_slot_score)"
                     class="fas fa-circle me-1">
                  </i>
                  {{ validator.skipped_slot_score }}
                  <small class="d-lg-none text-muted">(2)</small>
                  <small class="d-none d-lg-inline text-muted">(max 2)</small>
                </td>
                <td class="column-lg small">
                  This score measures the&nbsp;percent of the&nbsp;time that a&nbsp;leader fails to produce a&nbsp;block
                  during their allocated slots.
                </td>
              </tr>

              <tr>
                <td class="column-md fw-bold">Published Information Score</td>
                <td class="column-xs text-nowrap">
                  <i :class="'score-' + parseInt(validator.published_information_score)"
                     class="fas fa-circle me-1"></i>
                  {{ validator.published_information_score }}
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
                  <i :class="'score-' + parseInt(validator.software_version_score)"
                     class="fas fa-circle me-1"></i>
                  {{ validator.software_version_score }}
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
                  <i :class="'score-' + parseInt(validator.security_report_score)"
                     class="fas fa-circle me-1"></i>
                  {{ validator.security_report_score }}
                  <small class="d-lg-none text-muted">(1)</small>
                  <small class="d-none d-lg-inline text-muted">(max 1)</small>
                </td>
                <td class="column-lg small">
                  Bonus Point is assigned for providing a&nbsp;URL to validator's web page related to security policies.
                </td>
              </tr>

              <tr v-if="parseInt(validator.stake_concentration_score) < 0">
                <td class="column-md fw-bold">Stake Concentration Score</td>
                <td class="column-xs text-nowrap">
                  <i class="fas fa-minus-circle me-1 text-warning"></i>
                  {{ validator.stake_concentration_score }}
                  <small class="d-lg-none text-muted">(0)</small>
                  <small class="d-none d-lg-inline text-muted">(max 0)</small>
                </td>
                <td class="column-lg small">
                  This is a&nbsp;contra-score and will deduct points if the validator is one of the&nbsp;top
                  33%&nbsp;active stake holders.
                </td>
              </tr>

              <tr v-if="parseInt(validator.data_center_concentration_score) < 0">
                <td class="column-md fw-bold">Data Center Concentration Score</td>
                <td class="column-xs text-nowrap">
                  <i class="fas fa-minus-circle me-1 text-warning"></i>
                  {{ validator.data_center_concentration_score }}
                  <small class="d-lg-none text-muted">(0)</small>
                  <small class="d-none d-lg-inline text-muted">(max 0)</small>
                </td>
                <td class="column-lg small">
                  This is a&nbsp;contra-score and will deduct points from the&nbsp;validator located in data centers
                  that host a&nbsp;high percentage of other Solana validators.
                </td>
              </tr>

              <tr v-if="parseInt(validator.authorized_withdrawer_score) < 0">
                <td class="column-md fw-bold">Authorized Withdrawer Score</td>
                <td class="column-xs text-nowrap">
                  <i class="fas fa-minus-circle me-1 text-warning"></i>
                  {{ validator.authorized_withdrawer_score.to_i }}
                    <small class="d-lg-none text-muted">(0)</small>
                    <small class="d-none d-lg-inline text-muted">(max 0)</small>
                </td>
                <td class="column-lg small">
                  This is a&nbsp;contra-score and will deduct points from the&nbsp;validator whose identity
                  matches authorized withdrawer.
                </td>
              </tr>

              <tr v-if="parseInt(validator.consensus_mods_score) < 0">
                <td class="column-md fw-bold">Consensus Mods Score</td>
                <td class="column-xs text-nowrap">
                  <i class="fas fa-minus-circle me-1 text-warning"></i>
                  {{ validator.consensus_mods_score.to_i }}
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

  export default {
    props: {
      validator: {
        type: Object,
        required: true
      }
    },
    computed: mapGetters([
      'web3_url',
      'network'
    ])
  }
</script>
