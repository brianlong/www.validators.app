import Vue from 'vue/dist/vue.esm'


  Vue.component('commission-history-row', {
    props: {
      chistory: {
        type: Object,
        required: true
      }
    },
    created: function() {
      this.chistory.href = "/validators/" + this.chistory.network + "/" + this.chistory.account
      this.chistory.name = this.chistory.account.substring(0,5) + "..." + this.chistory.account.substring(this.chistory.account.length - 5)
    },
    template: `
      <tr>
        <td>
          <a v-bind:href="chistory.href" > {{ chistory.name }} </a>
        </td>
        <td>
          {{ chistory.epoch }}
          <!-- <small>{{ chistory.epoch_completion }}</small> -->
        </td>
        <td> 
          <!-- {{ chistory.batch_uuid }} -->
        </td>
        <td>
          {{ chistory.commission_before }}
          {{ chistory.commission_after }}
        </td>
        <td> 
          {{ chistory.created_at }}
        </td>
      </tr>
    `
  })
