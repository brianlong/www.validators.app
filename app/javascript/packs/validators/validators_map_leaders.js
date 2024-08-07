import Vue from 'vue/dist/vue.esm'
import '../mixins/validators_mixins';

var ValidatorsMapLeaders = Vue.component('ValidatorsMapLeaders', {
    props: {
        current_leader: {
            type: Object,
            required: true
        },
        next_leaders: {
            type: Array,
            required: true
        },
    },

    data() {
        return {}
    },

    methods: {},

    template: `
    <div class="map-legend-col">
      <div class="small text-muted mb-2">Current Leader</div>
      <div class="small" v-if="!current_leader">loading...</div>

      <div class="d-flex flex-wrap gap-3 mb-3" v-if="current_leader">
        <a :href="validator_url(current_leader.account, $parent.network)"
           title="Go to validator details" target="_blank">
          <img :src="avatar_url(current_leader)" class="img-circle-small" />
        </a>
        <div class="d-flex flex-column justify-content-center">
          <a :href="validator_url(current_leader.account, $parent.network)"
             title="Go to validator details"
             class="fw-bold" target="_blank">
            {{ shortened_validator_name(current_leader.name, current_leader.account) }}
          </a>
        </div>
      </div>

      <div class="" v-if="next_leaders.length > 0">
        <div class="small text-muted mb-2">Next Leaders</div>
        <div class="d-flex flex-wrap gap-3">
          <a v-for="leader in next_leaders"
             :href="validator_url(leader.account, $parent.network)"
             title="Go to validator details" target="_blank">
            <img :src="avatar_url(leader)" class='img-circle-small' />
          </a>
        </div>
      </div>
    </div>
  `
})

export default ValidatorsMapLeaders
