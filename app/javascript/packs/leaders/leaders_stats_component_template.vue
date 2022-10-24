<template>
  <div class="col-md-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <div class="mb-4">
          <h2 class="h5 card-heading-left">Leader</h2>
          <span class="text-muted" v-if="!current_leader">loading...</span>
          <div class="d-flex flex-wrap gap-3" v-if="current_leader">
            <img :src="create_avatar_link(current_leader)" class="img-circle-medium" />
            <div class="d-flex flex-column justify-content-center">
              <strong class="text-purple">{{ leader_name(current_leader) }}</strong>
            </div>
          </div>
        </div>

        <div v-if="current_leader">
          <h2 class="h5 card-heading-left">Next Leaders</h2>
          <div class="d-flex flex-wrap gap-3">
            <span v-for="leader in next_leaders">
              <img :src="create_avatar_link(leader)" class='img-circle-small' />
            </span>
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
