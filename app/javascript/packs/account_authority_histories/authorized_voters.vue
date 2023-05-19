<template>
  <div>
  </div>
</template>

<script>
  export default {
    name: 'AuthorizedVoters',
    props: {
      authorized_voters: {
        type: String,
        required: true
      }
    },

    data() {
      return {
        authorized_voters: null,
        authorized_withdrawer: null
      }
    },

    mounted() {
    },

    methods: {
    }
  }
</script>
