<template>
  <button :class="'btn btn-lg btn-secondary ms-lg-3 mt-3 mt-lg-0 ' + searcher_btn_class()"
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
        return this.is_active ? "active" : ""
      },
      toggle_searcher() {
        this.is_active = !this.is_active
        const searcher_bar = document.getElementById("searcher-bar")
        searcher_bar.classList.toggle("d-none")
        if (this.is_active == true) {
          searcher_bar.getElementsByClassName("form-control")[0].focus()
        }
      }
    }
  }
</script>
