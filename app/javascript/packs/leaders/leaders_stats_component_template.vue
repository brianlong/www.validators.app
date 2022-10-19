<template>
  <div class="col-md-4 col-sm-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Leader</h2>

        <span class="text-muted" v-if="!current_leader">loading...</span>

        <div class="leaders-info" v-if="current_leader">
          <div class="current-leader-info center-block text-center mb-2">
            <div class="info-avatar">
              <img :src="create_avatar_link(current_leader)" class='img-circle-medium' />
            </div>
            <div class="text-muted mt-1">{{ leader_name(current_leader) }}</div>
          </div>

          <div class="lead">Next Leaders</div>
          <div class="next-leaders-info mt-3">
            <div class="info-avatar d-flex justify-content-between flex-wrap gap-1">
              <span v-for="leader in next_leaders">
                <img :src="create_avatar_link(leader)" class='img-circle-medium' />
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        current_leader: null,
        next_leaders: [],
        network: 'mainnet'
      }
    },
    channels: {
      LeadersChannel: {
        connected() { },
        rejected() { },
        received(data) {
          data = data[this.network];
          this.current_leader = data.shift();
          this.next_leaders = data;
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
    methods: {
      create_avatar_link(leader) {
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
      }
    },
  }
</script>
