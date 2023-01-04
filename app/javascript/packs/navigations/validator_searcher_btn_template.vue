<template>
  <button id="validator-searcher-btn"
          :class="'btn btn-lg btn-secondary ms-3 ' + searcher_class()"
          v-on:click="trigger_btn()">
    <i class="fas fa-search"></i>
  </button>
</template>

<script>
  export default {
    data() {
      return {
        is_active: false
      }
    },
    methods: {
      searcher_class() {
        return this.is_active ? 'active' : ''
      },
      trigger_btn() {
        this.is_active = !this.is_active

        const validator_searcher_bar = document.getElementById("validator-searcher-bar")

        validator_searcher_bar.classList.toggle("active")
      }
    }
  }
</script>
