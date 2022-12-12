<template>
  <div>
    <b-form @submit="onSubmit" class="flex-fill">
      <div class="form-group-row">
        <b-input-group>
          <b-form-input v-model="form.query"
                        placeholder="Starts with... (validator name, validator account or data center key)"
                        required>
          </b-form-input>
          <b-input-group-append>
            <b-button variant="primary" class="btn-sm btn-radius-right">Search</b-button>
          </b-input-group-append>
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
    created() { },
    computed: {
      ...mapGetters([
        'network'
      ])
    },
    methods: {
      onSubmit(event) {
        event.preventDefault()
        window.location.replace(`validators?q=${this.form.query}&network=${this.network}`)
      }
    }
  }
</script>
