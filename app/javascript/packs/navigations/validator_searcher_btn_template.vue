<template>
  <button class="btn btn-lg btn-secondary"
          id="validator-searcher-btn"
          :class="searcher_class()"
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

        if (this.is_active) {
          validator_searcher_bar.classList.add("active")
        } else {
          validator_searcher_bar.classList.remove("active")
        }
      }
    }
  }
</script>
