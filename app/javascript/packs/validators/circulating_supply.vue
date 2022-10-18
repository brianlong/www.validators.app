<template>
  <div class="col-md-4 col-sm-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Stake</h2>
        <div>
          <span class="text-muted me-1">Circulating Supply:</span>

          <span class="text-muted" v-if="!circulating_supply">loading...</span>
          <strong class="text-success" v-if="circulating_supply">{{ circulating_supply }}&nbsp;SOL</strong>
        </div>

        <small class="text-muted" v-if="total_circulating_supply">
          ({{ percent_of_total_stake() }}% of total {{ total_circulating_supply }}&nbsp;SOL)
        </small>
      </div>
    </div>
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js";
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        connection: null,
        circulating_supply: null,
        total_circulating_supply: null,
        api_params: { excludeNonCirculatingAccountsList: true }
      }
    },
    created() {
      this.connection = new web3.Connection(this.web3_url);

      this.update_circulating_supply();
      this.set_continuous_supply_update();
    },
    computed: mapGetters([
      'web3_url'
    ]),
    methods: {
      lamports_to_sol(lamports) {
        return lamports / 1000000000;
      },
      update_circulating_supply() {
        this.connection.getSupply(this.api_params)
          .then(response => {
            const val = response.value;
            this.circulating_supply = this.lamports_to_sol(val.circulating).toLocaleString('en-US', { maximumFractionDigits: 0 });
            this.total_circulating_supply = this.lamports_to_sol(val.total).toLocaleString('en-US', { maximumFractionDigits: 0 });
          });
      },
      percent_of_total_stake() {
        return (parseInt(this.circulating_supply) * 100 / parseInt(this.total_circulating_supply)).toFixed(0);
      },
      set_continuous_supply_update() {
        setInterval(() => {
          this.update_circulating_supply();
        }, 5000);
      }
    }
  }
</script>
