<template>
  <div class="dropdown">
    <button class="btn btn-secondary dropdown-toggle btn-block" type="button" id="network-select" data-bs-toggle="dropdown" aria-expanded="false">
      {{ network }}
    </button>
    <ul class="dropdown-menu" aria-labelledby="network-select" data-turbolinks="false">
      <li v-for="network_entry in $store.state.networks" :key="network_entry">
        <a class="dropdown-item" href="#" @click.prevent="change_network(network_entry)">{{ network_entry }}</a>
      </li>
    </ul>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'

  export default {
    data(){
      return {
        url: ''
      }
    },
    created() {
      $('.dropdown-toggle').dropdown()
    },
    computed: mapGetters([
      'network'
    ]),
    methods: {
      change_network: function(target_network){
        let splitted_url = this.url.split("/")
        this.url = window.location.href
        if(this.url.includes('network=')){
          this.url = this.url.replace(/network=(mainnet|testnet|pythnet)/, "network=" + target_network)
        } else {
          this.url = this.url + '?network=' + target_network
        }
        window.location.href = this.url
        return true
      }
    }
  }
</script>
