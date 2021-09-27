<template>
  <div class="btn-group btn-group-toggle">
    <label 
      class="btn btn-secondary" 
      :class="{ active: is_mainnet() }"
      @click="change_network('mainnet')">
      mainnet
    </label>
    <label 
      class="btn btn-secondary" 
      :class="{ active: is_testnet() }"
      @click="change_network('testnet')">
      testnet
    </label>
  </div>
</template>

<script>
  import { defineComponent } from '@vue/composition-api'

  export default defineComponent({
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
        } else if(this.url.match(/\/(mainnet|testnet)/)){
          this.url = this.url.replace(/\/(mainnet|testnet)/,'/' + target_network)
        }
        console.log(this.url)
        window.location.href = this.url
        return true
      }
    }
  })
</script>
