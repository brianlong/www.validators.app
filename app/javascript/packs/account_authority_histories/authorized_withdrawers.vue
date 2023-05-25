<template>
  <div class="table-responsive-md">
    <table class="table mb-0">
      <thead>
        <tr>
          <th class="col-md-4">
            Authorized Withdrawer Before
          </th>
          <th class="col-md-4">
            Authorized Withdrawer After
          </th>
          <th class="col-md-4">
            Timestamp
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="withdrawer in withdrawers"
            v-if="display_withdrawer(withdrawer)">
          <td>
            {{ withdrawer.authorized_withdrawer_before }}
            </td>
          <td>
            {{ withdrawer.authorized_withdrawer_after }}
          </td>
          <td>
            {{ date_time_with_timezone(withdrawer.created_at) }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
  import '../mixins/dates_mixins'

  export default {
    props: {
      withdrawers: {
        type: Array,
        required: true
      }
    },

    methods: {
      display_withdrawer(withdrawer) {
        return JSON.stringify(withdrawer.authorized_withdrawer_after) !== JSON.stringify(withdrawer.authorized_withdrawer_before)
      }
    }
  }
</script>
