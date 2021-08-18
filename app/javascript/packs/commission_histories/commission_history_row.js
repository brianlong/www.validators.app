import Vue from 'vue/dist/vue.esm'


var CommissionHistoryRow = Vue.component('CommissionHistoryRow', {
  props: {
    chistory: {
      type: Object,
      required: true
    }
  },
  data() {
    if(this.chistory.name == null){
      var chistory_name = this.chistory.account.substring(0,6) + "..." + this.chistory.account.substring(this.chistory.account.length - 4)
    } else {
      var chistory_name = this.chistory.name
    }
    return {
      chistory_href: "/validators/" + this.chistory.network + "/" + this.chistory.account,
      chistory_name: chistory_name,
      descending: (this.chistory.commission_before > this.chistory.commission_after) ? true : false
    }
  },
  watch: {
    chistory: function() {
      this.prepareData()
    }
  },
  mounted: function(){
    this.prepareData()
  },
  methods: {
    prepareData: function() {
      this.chistory.commission_before = this.chistory.commission_before ? this.chistory.commission_before : 0
      this.chistory.commission_after = this.chistory.commission_after ? this.chistory.commission_after : 0
    }
  },
  template: `
    <tr>
      <td>
        <a v-bind:href="chistory_href" > {{ chistory_name }} </a>
      </td>
      <td>
        {{ chistory.epoch }}
        <small>({{ chistory.epoch_completion }}%)</small>
      </td>
      <td> 
        {{ chistory.batch_uuid }}
      </td>
      <td class="text-center">
        {{ chistory.commission_before }}%
        <i class="fas fa-long-arrow-alt-right px-2"></i>
        {{ chistory.commission_after }}%
        <i class="fas fa-long-arrow-alt-down text-success" v-if="descending"></i>
        <i class="fas fa-long-arrow-alt-up text-danger" v-if="!descending"></i>
      </td>
      <td> 
        {{ chistory.created_at }}
      </td>
    </tr>
  `
})

export default CommissionHistoryRow
