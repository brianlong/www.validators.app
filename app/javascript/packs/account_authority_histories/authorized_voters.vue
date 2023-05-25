<template>
  <div class="table-responsive-md">
    <table class="table mb-0">
      <thead>
        <tr>
          <th class="col-md-6 text-end">
            Authorized Voter
          </th>
          <th class="col-md-6">
            Timestamp
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="voter in voters"
            v-if="display_voter(voter)">
          <td class="text-end">
            {{ voter.authorized_voters_after }}
          </td>
          <td>
            {{ date_time_with_timezone(voter.created_at) }}
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
      voters: {
        type: Array,
        required: true
      }
    },

    methods: {
      display_voter(voter) {
        return JSON.stringify(voter.authorized_voters_after) !== JSON.stringify(voter.authorized_voters_before)
      }
    }
  }
</script>
