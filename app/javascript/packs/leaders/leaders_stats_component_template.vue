<template>
  <div class="col-md-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <div class="mb-4">
          <h2 class="h5 card-heading-left">Leader</h2>
          <span class="text-muted" v-if="!current_leader">loading...</span>

          <div class="d-flex flex-wrap gap-3" v-if="current_leader">
            <a :href="validator_details_link(current_leader.account)"
               title="Go to validator details." target="_blank">
              <img :src="avatar_link(current_leader)" class="img-circle-medium" />
            </a>
            <div class="d-flex flex-column justify-content-center">
              <a :href="validator_details_link(current_leader.account)"
                 title="Go to validator details."
                 class="fw-bold" target="_blank">
                {{ leader_name(current_leader) }}
              </a>
            </div>
          </div>
        </div>

        <div v-if="next_leaders.length > 0">
          <h2 class="h6 card-heading-left">Next Leaders</h2>
          <div class="d-flex flex-wrap gap-3">
            <a v-for="leader in next_leaders"
               :href="validator_details_link(leader.account)"
               title="Go to validator details." target="_blank">
              <img :src="avatar_link(leader)" class='img-circle-small' />
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    data() {
      return {
        current_leader: null,
        next_leaders: [],
      }
    },
    channels: {
      LeadersChannel: {
        connected() { },
        rejected() { },
        received(data) {
          data = data[this.network];
          if (data) {
            this.current_leader = data.current_leader;
            this.next_leaders = data.next_leaders;
          }
        },
        disconnected() { }
      }
    },
    mounted() {
      this.$cable.subscribe({
        channel: 'LeadersChannel',
        room: "public"
      });
    },
    computed: mapGetters([
      'network'
    ]),
    methods: {
      avatar_link(leader) {
        if (leader.avatar_url) {
          return leader.avatar_url
        } else {
          return "https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png"
        }
      },

      leader_name(leader) {
        if (leader.name) {
          return leader.name
        } else {
          const account = leader.account

          return account.substring(0, 5) + "..." + account.substring(account.length - 5)
        }
      },

      validator_details_link(account) {
        return `/validators/${account}?network=${this.network}`;
      }
    },
  }
</script>
