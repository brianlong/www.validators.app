<template>
  <!--
  <div class="dropdown">
    <button :class="dropdown_visibility_class + ' btn btn-lg btn-secondary btn'"
            type="button" @click="toggle_dropdown">
      {{ capitalize(network) }}
    </button>

    <ul :class="dropdown_visibility_class + ' dropdown-options'" v-click-outside="hide_dropdown">
      <li v-for="network_entry in $store.state.networks"
          :key="network_entry" class="dropdown-item">
        <a class="dropdown-link" href="#" @click.prevent="change_network(network_entry)">
          {{ capitalize(network_entry) }}
        </a>
      </li>
    </ul>
  </div>
  -->
  <div>
    <div v-for="(network_entry, index) in $store.state.networks"
        :key="network_entry" class="footer-item">
      <a :class="link_class(network_entry) + ' footer-link'" href="#" @click.prevent="change_network(network_entry)">
        {{ capitalize(network_entry) }}
      </a>
      <span class="d-lg-none ms-2" v-if="index != ($store.state.networks.length - 1)">/</span>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import '../mixins/strings_mixins'

  export default {
    data() {
      return {
        url: '',
        dropdown_active: false,
        click_outside_active: false
      }
    },

    created() {},

    computed: {
      dropdown_visibility_class() {
        return this.dropdown_active ? 'open' : ''
      },
      ...mapGetters([
        'network'
      ]),
    },

    methods: {
      change_network: function(target_network) {
        let splitted_url = this.url.split("/")
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

      toggle_dropdown: function() {
        if(this.dropdown_active) {
          this.dropdown_active = false
          this.toggle_click_outside(false)
        } else {
          this.dropdown_active = true
          var ctx = this
          setTimeout(function() {
            ctx.toggle_click_outside(true)
          }, 200)
        }
      },

      toggle_click_outside(active) {
        this.click_outside_active = active
      },

      hide_dropdown() {
        if(this.dropdown_active && this.click_outside_active) {
          this.dropdown_active = false
          this.toggle_click_outside(false)
        }
      }
    }
  }
</script>
