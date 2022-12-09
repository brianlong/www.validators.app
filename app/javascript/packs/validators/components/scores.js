export default {
  props: {
    score: {
        type: Object,
        required: true
    }
  },
  data() {
    return {
      default_score_class: "fas fa-circle me-1 score-"
    }
  },
  methods: {
    score_class(class_score) {
      return this.default_score_class + class_score
    },
    root_distance_score_title() {
      return "Root Distance Score = " + this.score.root_distance_score
    },
    vote_distance_score_title() {
      return "Vote Distance Score = " + this.score.vote_distance_score
    },
    skipped_slot_score_title() {
      return "Skipped Slot Score = " + this.score.skipped_slot_score
    },
    published_information_score_title() {
      return "Published Information Score = " + this.score.published_information_score
    },
    software_version_score_title() {
      return "Software Version Score = " + this.score.software_version_score
    },
    security_report_score_title() {
      return "Bonus Point = " + this.score.security_report_score
    },
    consensus_mods_score_title() {
      return "Consensus Mods Score = " + this.score.consensus_mods_score + ". Validator appears to use software modifications with an unproven effect on consensus."
    },
    authorized_withdrawer_score_title() {
      return "Authorized Withdrawer Score = " + this.score.authorized_withdrawer_score.to_i
    },
    stake_concentration_score_title() {
      return "Stake Concentration Score = " + this.score.stake_concentration_score
    },
    data_center_concentration_score_title() {
      return "Data Center Concentration Score = " + this.score.data_center_concentration_score
    }
  },
  template: `
    <div>
      <a class="small text-nowrap base-color" data-bs-toggle="modal" data-bs-target="#scoresModal<%=validator.account%>">
        <i :class="score_class(score.root_distance_score)"
           :title="root_distance_score_title()"></i>

        <i :class="score_class(score.vote_distance_score)"
           :title="vote_distance_score_title()"></i>

        <i :class="score_class(score.skipped_slot_score)"
           :title="skipped_slot_score_title()"></i>

        <i :class="score_class(score.published_information_score)"
           :title="published_information_score_title()"></i>

        <i :class="score_class(score.software_version_score)"
           :title="software_version_score_title()"></i>

        <i :class="score_class(score.security_report_score)"
           :title="security_report_score_title()"></i>

        <i class="fas fa-minus-circle me-1 text-warning"
           v-if="score.consensus_mods_score < 0"
           :title="consensus_mods_score_title()"></i>
           
        <i class="fas fa-minus-circle me-1 text-warning"
           v-if="score.authorized_withdrawer_score < 0"
           :title="authorized_withdrawer_score_title()"></i>

        <i class="fas fa-minus-circle me-1 text-warning"
           v-if="score.stake_concentration_score < 0"
           :title="stake_concentration_score_title()"></i>
        
        <i class="fas fa-minus-circle me-1 text-warning"
           v-if="score.data_center_concentration_score < 0"
           :title="data_center_concentration_score_title()"></i>
      </a>
      ({{ score.displayed_total_score }})
    </div>
`
}
