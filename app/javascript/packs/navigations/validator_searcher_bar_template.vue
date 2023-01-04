<template>
  <div class="container mt-3" id="validator-searcher-bar">
    <b-form @submit="onSubmit" class="flex-fill">
      <div class="form-group-row">
        <b-input-group>
          <b-form-input v-model="form.query"
                        placeholder="Starts with... (validator name, validator account or data center key)"
                        required>
          </b-form-input>
          <b-button type="submit" variant="primary" class="btn btn-sm btn-primary">Search</b-button>
        </b-input-group>
      </div>
    </b-form>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        form: {
          query: ''
        }
      }
    },
    computed: {
      ...mapGetters([
        'network'
      ])
    },
    methods: {
      onSubmit(event) {
        event.preventDefault()
        const path = `${window.location.origin}/validators?q=${this.form.query}&network=${this.network}`

        window.location.replace(path)
      }
    }
  }
</script>
