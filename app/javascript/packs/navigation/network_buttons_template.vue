<template>
  <div class="btn-group btn-group-xs btn-group-toggle">
    <label 
      class="btn btn-secondary nav-link" 
      :class="{ active: is_mainnet() }"
      @click="change_network('mainnet')">
      <a class="">Mainnet</a>
    </label>
    <label 
      class="btn btn-secondary nav-link" 
      :class="{ active: is_testnet() }"
      @click="change_network('testnet')">
      <a class="">Testnet</a>
    </label>
  </div>
</template>

<script>
  import { mapActions } from 'vuex'
  import types from '../mutations/main_mutations_types.js'

  export default {
    data(){
      return {
        network: '',
        url: ''
      }
    },
    created() {
      this.url = window.location.href
      if(this.url.includes('testnet')){
        this.network = 'testnet'
      } else {
        this.network = 'mainnet'
      }
    },
    methods: {
      is_testnet: function(){
        return this.network == 'testnet'
      },
      is_mainnet: function(){
        return this.network == 'mainnet'
      },
      change_network: function(target_network){
        let splitted_url = this.url.split("/")
        if(this.url.includes('network=')){
          this.url = this.url.replace(/network=(mainnet|testnet)/, "network=" + target_network)
        } else {
          this.url = this.url + '?network=' + target_network
        }

        this.set_network(target_network)
        window.location.href = this.url
        return true
      },
      ...mapActions([types.SET_NETWORK])
    },
  }
</script>
