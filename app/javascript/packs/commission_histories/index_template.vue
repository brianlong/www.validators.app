<template>
  <div class="card mb-4">
    <div class="table-responsive-lg">
      <table class='table mb-0'>
        <thead>
          <tr>
            <th>Validator</th>
            <th class="narrow-column">
              Epoch<br />
              <small>(completion %)</small>
            </th>
            <th class="wider-column">Batch</th>
            <th class="wider-column text-center">Before<i class="fas fa-long-arrow-alt-right px-2"></i>After</th>
            <th class="narrow-column">Timestamp</th>
          </tr>
        </thead>
          <commission-history-row v-for="ch in commission_histories" :key="ch.account" :chistory="ch">
          </commission-history-row>
        <tbody>

        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    data () {
        return {
        commission_histories: []
        }
    },
    created () {
      var ctx = this
      axios.get('/api/v1/commission-changes/mainnet')
      .then(response => (
        response.data.forEach(function(ch){
          ch.href = "/validators/" + ch.network + "/" + ch.account
          ch.commission_before = ch.commission_before ? ch.commission_before : 0
          ctx.commission_histories.push(ch)
        }) 
      ))
    },
  }
</script>