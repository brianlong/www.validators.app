import { NIL } from 'uuid'
import Vue from 'vue/dist/vue.esm'


Vue.component('CommissionHistoryRow', {
  props: {
    chistory: {
      type: Object,
      required: true
    },
    descending: {
      type: Boolean
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
      this.chistory.href = "/validators/" + this.chistory.network + "/" + this.chistory.account
      if(this.chistory.name == NIL){
        this.chistory.name = this.chistory.account.substring(0,6) + "..." + this.chistory.account.substring(this.chistory.account.length - 4)
      }
      this.chistory.commission_before = this.chistory.commission_before ? this.chistory.commission_before : 0
      this.chistory.commission_after = this.chistory.commission_after ? this.chistory.commission_after : 0

      this.descending = (this.chistory.commission_before > this.chistory.commission_after) ? true : false
    }
  },
  template: `
    <tr>
      <td>
        <a v-bind:href="chistory.href" > {{ chistory.name }} </a>
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
