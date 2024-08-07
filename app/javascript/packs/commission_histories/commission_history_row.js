import Vue from 'vue/dist/vue.esm'
import '../mixins/dates_mixins'

var CommissionHistoryRow = Vue.component('CommissionHistoryRow', {
  props: {
    comm_history: {
      type: Object,
      required: true
    }
  },

  data() {
    if(this.comm_history.name == null) {
      var comm_history_name = this.comm_history.account.substring(0,6) + "..." + this.comm_history.account.substring(this.comm_history.account.length - 4)
    } else {
      var comm_history_name = this.comm_history.name
    }
    return {
      comm_history_href: "/validators/" + this.comm_history.account + "?network=" + this.comm_history.network,
      comm_history_name: comm_history_name,
      descending: (this.comm_history.commission_before > this.comm_history.commission_after) ? true : false
    }
  },

  watch: {
    comm_history: function() {
      this.prepareData()
    }
  },

  mounted: function() {
    this.prepareData()
  },

  methods: {
    prepareData: function() {
      this.comm_history.commission_before = this.comm_history.commission_before ? this.comm_history.commission_before : 0
      this.comm_history.commission_after = this.comm_history.commission_after ? this.comm_history.commission_after : 0
    },
    filterByQuery: function(e) {
      this.$emit('filter_by_query', this.comm_history.account);
    },
    source_name: function() {
      return this.comm_history.source_from_rewards ? "rewards" : "pipeline"
    }
  },

  template: `
    <tr>
      <td>
        <a href="#" v-bind:account="comm_history_name" title="Click to show commission changes only for this validator." @click.prevent="filterByQuery">{{ comm_history_name }}</a>
        <a v-bind:href="comm_history_href" title="Go to validator details." target="_blank"><i class="fa-solid fa-up-right-from-square small ms-2"></i></a>
      </td>
      <td>
        {{ comm_history.epoch }}
        <small class="text-muted">({{ comm_history.epoch_completion }}%)</small>
      </td>
      <td class="small">
        {{ source_name() }}
      </td>
      <td class="text-center text-nowrap">
        {{ comm_history.commission_before }}%
        <i class="fa-solid fa-right-long px-2"></i>
        {{ comm_history.commission_after }}%
        <i class="fa-solid fa-down-long text-success" v-if="descending"></i>
        <i class="fa-solid fa-up-long text-danger" v-if="!descending"></i>
      </td>
      <td class="small">
        {{ date_time_with_timezone(comm_history.created_at) }}
      </td>
    </tr>
  `
})

export default CommissionHistoryRow
