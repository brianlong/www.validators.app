<template>
  <div>
    <div v-for="(network, index) in $store.state.networks"
        :key="network" class="footer-item">
      <a :class="link_class(network) + ' footer-link'" href="#" @click.prevent="change_network(network)">
        {{ capitalize(network) }}
      </a>
      <span class="d-lg-none ms-2" v-if="index != ($store.state.networks.length - 1)">/</span>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        url: ''
      }
    },

    created() {},

    computed: {
      ...mapGetters([
        'network'
      ]),
    },

    methods: {
      change_network: function(target_network) {
        this.url = window.location.href
        if(this.url.includes('network=')) {
          this.url = this.url.replace(/network=(mainnet|testnet|pythnet)/, "network=" + target_network)
        } else {
          this.url = this.url + '?network=' + target_network
        }
        window.location.href = this.url
        return true
      },

      link_class: function(network) {
        let url = window.location.href
        if(url.includes(network)) {
          return 'active';
        } else if(!url.includes('network=') && network === "mainnet") {
          return 'active';
        }
      },
    }
  }
</script>
