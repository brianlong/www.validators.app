<template>
  <div class="table-responsive-lg">
    <table class='table'>
      <thead>
      <tr>
        <th class="column-md-sm">Success / Time</th>
        <th class="column-lg">
          Reported&nbsp;At<br />
          <span class="small text-muted">Signature</span>
        </th>
        <th class="column-lg">
          Application<br />
          <span class="small text-muted">Type (Commitment Level)</span>
        </th>
        <th class="column-xs">Posted&nbsp;By</th>
      </tr>
      </thead>

      <tbody>
        <tr v-for="(pt) in ping_things" :key="pt.id">
          <td>
            <span v-html="success_icon(pt.success)"></span>
            <strong class="text-success h6">{{ pt.response_time.toLocaleString() }}</strong>&nbsp;ms
          </td>
          <td class="small">
            {{ formatted_date(pt.reported_at) }}<br />
            <span class="word-break">
              <a :href="link_from_signature(pt.signature)" target="_blank" class="small">
                {{ pt.signature.substring(0,6) + "..." + pt.signature.substring(pt.signature.length - 4, pt.signature.length) }}
              </a>
            </span>
          </td>
          <td class="small">
            <div v-if="pt.application">
              {{ pt.application }}<br />
            </div>
            <span class="text-muted">
              <span v-html="transaction_type_icon(pt.transaction_type)"></span>
              {{ pt.transaction_type }}
              <span v-if="pt.commitment_level">
                ({{ pt.commitment_level }})
              </span>
            </span>
          </td>
          <td class="text-muted">{{ pt.username }}</td>
        </tr>
      </tbody>
    </table>

  </div>
</template>

<script>
  var moment = require('moment');

  export default {
    props: {
      ping_things: {
        type: Array,
        required: true
      },
    },
    methods: {
      success_icon(success) {
        if(success){
          return '<i class="fas fa-check-circle text-success me-1"></i>'
        } else {
          return '<i class="fas fa-times-circle text-danger me-1"></i>'
        }
      },
      link_from_signature(signature){
        return "https://solanabeach.io/transaction/" + signature
      },
      transaction_type_icon(tx){
        switch(tx){
          case 'transfer':
            return '<i class="fas fa-exchange-alt text-success me-1"></i>'
          default:
            return '<i class="fas fa-random text-success me-1"></i>'
        }
      },
      formatted_date(date){
        var date = new Date(date)
        var formatted_date = moment(date).utc().format('YYYY-MM-DD HH:mm:ss z')

        return formatted_date
      }
    }
  }
</script>
