<template>
  <button :class="'btn btn-lg btn-secondary ms-3 ' + searcher_btn_class()"
          v-on:click="toggle_searcher()">
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
      searcher_btn_class() {
        return this.is_active ? 'active' : ''
      },
      toggle_searcher() {
        this.is_active = !this.is_active
        document.getElementById("searcher-bar").classList.toggle("d-none")
      }
    }
  }
</script>
