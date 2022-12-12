<template>
  <div>
    <b-form @submit="onSubmit" class="flex-fill">
      <div class="form-group-row">
        <b-input-group id="input-group-1">
          <b-form-input id="input-1"
                        v-model="form.query"
                        placeholder="Starts with... (validator name, validator account or data center key)"
                        :value="query"
                        required>
          </b-form-input>
          <b-input-group-append>
            <b-button class="btn-sm btn-primary">Search</b-button>
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
        query: null
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
      alert(JSON.stringify(this.form))
    }
  }
}
</script>
