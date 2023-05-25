<template>
  <div class="table-responsive-md">
    <table class="table mb-0">
      <thead>
        <tr>
          <th class="col-md-4">
            Authorized Voter Before
          </th>
          <th class="col-md-4">
            Authorized Voter After
          </th>
          <th class="col-md-4">
            Timestamp
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="voter in voters"
            v-if="display_voter(voter)">
          <td>
            {{ voter.authorized_voters_before }}
          </td>
          <td>
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
