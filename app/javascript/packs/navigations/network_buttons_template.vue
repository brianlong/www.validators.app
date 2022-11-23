<template>
  <div id="network-select">
    <button class="btn btn-lg btn-secondary" type="button" @click="toggle_dropdown" >
      {{ network }}
    </button>
    <ul :class="'dropdown-options ' + dropdown_visible" v-click-outside="hide_dropdown" aria-labelledby="network-select" data-turbolinks="false">
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
        url: '',
        dropdown_active: false,
        click_outside_active: false
      }
    },
    created() {

    },
    computed: {
      dropdown_visible() {
        return this.dropdown_active ? '' : 'd-none'
      },
      ...mapGetters([
        'network'
      ]),
    },
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
      },
      toggle_dropdown: function(){
        if(this.dropdown_active){
          this.dropdown_active = false
          this.toggle_click_outside(false)
        } else {
          this.dropdown_active = true
          var ctx = this
          setTimeout(function(){
            ctx.toggle_click_outside(true)
          }, 200)
        }
      },
      toggle_click_outside(active){
        this.click_outside_active = active
      },
      hide_dropdown(){
        if(this.dropdown_active && this.click_outside_active) {
          this.dropdown_active = false
          this.toggle_click_outside(false)
        }
      }
    }
  }
</script>
