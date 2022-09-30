<template>
  <div class="btn-group btn-group-xs btn-group-toggle">
    <wallet-multi-button :wallets="wallets" auto-connect />
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
  import { WalletMultiButton } from 'solana-wallets-vue-2';
  import 'solana-wallets-vue-2/styles.css'
  import { PhantomWalletAdapter } from '@solana/wallet-adapter-wallets'

  export default {
    data(){
      return {
        network: '',
        url: '',
        wallets: [
          new PhantomWalletAdapter()
        ]
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
        window.location.href = this.url
        return true
      }
    },
    components: { 'wallet-multi-button': WalletMultiButton }
  }
</script>
