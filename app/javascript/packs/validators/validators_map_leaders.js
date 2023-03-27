import Vue from 'vue/dist/vue.esm'

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
    methods: {
        validator_details_link: function(account) {
            return this.$parent.validator_details_link(account);
        },
        avatar_link: function(leader) {
            return this.$parent.avatar_link(leader);
        },
        leader_name: function(leader) {
            if (leader.name) {
                return leader.name;
            } else {
                const account = leader.account;
                return account.substring(0, 5) + "..." + account.substring(account.length - 5);
            }
        },
    },
    template: `
    <div class="map-legend-col">
      <div class="small text-muted mb-2">Current Leader</div>
      <div class="small" v-if="!current_leader">loading...</div>

      <div class="d-flex flex-wrap gap-3 mb-3" v-if="current_leader">
        <a :href="validator_details_link(current_leader.account)"
           title="Go to validator details" target="_blank">
          <img :src="avatar_link(current_leader)" class="img-circle-small" />
        </a>
        <div class="d-flex flex-column justify-content-center">
          <a :href="validator_details_link(current_leader.account)"
             title="Go to validator details"
             class="fw-bold" target="_blank">
            {{ leader_name(current_leader) }}
          </a>
        </div>
      </div>

      <div class="" v-if="next_leaders.length > 0">
        <div class="small text-muted mb-2">Next Leaders</div>
        <div class="d-flex flex-wrap gap-3">
          <a v-for="leader in next_leaders"
             :href="validator_details_link(leader.account)"
             title="Go to validator details" target="_blank">
            <img :src="avatar_link(leader)" class='img-circle-small' />
          </a>
        </div>
      </div>
    </div>
  `
})

export default ValidatorsMapLeaders
