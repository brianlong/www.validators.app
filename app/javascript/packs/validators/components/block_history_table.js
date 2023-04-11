var moment = require('moment');

export default {
  props: {
    block_histories: {
      type: Array,
      required: true
    },
    block_history_stats: {
      type: Array,
      required: true
    }
  },

  data() {
    return {
      default_score_class: "fas fa-circle me-1 score-"
    }
  },

  methods: {
    block_stats(history) {
      return this.block_history_stats.find(o => o.batch_uuid == history.batch_uuid);
    },
    history_created_at(history) {
      return moment(new Date(history.created_at)).utc().format('YYYY-MM-DD HH:mm:ss z')
    },
    formatted_number(n) {
      return n.toLocaleString('en-US').replace("&nbsp;", ",")
    }
  },

  template: `
    <div class="card mb-4">
      <div class="card-content pb-0">
        <h2 class="h4 card-heading">Recent Block Production</h2>
      </div>
      
      <div class="table-responsive-lg">
      <table class='table mb-0'>
        <thead>
        <tr>
          <th class='column-xs text-end'>Epoch</th>
          <th class='column-md text-end'>Leader Slots<br />Total Slots</th>
          <th class='column-md text-end'>Leader Blocks<br />Total Blocks</th>
          <th class='column-md text-end'>
            Skipped Slots<br />
            Skipped Total
          </th>
          <th class='column-md text-end'>
            &percnt; Skipped<br />
            &percnt; Total
          </th>
          <th class="column-md">Timestamp</th>
        </tr>
        </thead>
        <tbody>
          <tr v-for="history in block_histories" :key="history.id">
            <td class='text-end'>
              {{ history.epoch }}
            </td>
            <td class='text-end'>
              {{ formatted_number(history.leader_slots) }}<br />
              {{ formatted_number(block_stats(history).total_slots) }}
            </td>
            <td class='text-end'>
              {{ formatted_number(history.blocks_produced) }}<br />
              {{ formatted_number(block_stats(history).total_blocks_produced) }}
            </td>
            <td class='text-end'>
              {{ formatted_number(history.skipped_slots) }}<br />
              {{ formatted_number(block_stats(history).total_slots_skipped) }}
            </td>
            <td class='text-end'>
              {{ (history.skipped_slot_percent * 100.0).toLocaleString('en-US', {maximumFractionDigits: 2}) }}%<br />
              {{ (block_stats(history).total_slots_skipped / block_stats(history).total_slots * 100.0).toLocaleString('en-US', {maximumFractionDigits: 2}) }}%
            </td>
            <td v-html="history_created_at(history)">
            </td>
          </tr>
        </tbody>
      </table>
      </div>
  
    </div>
`
}
