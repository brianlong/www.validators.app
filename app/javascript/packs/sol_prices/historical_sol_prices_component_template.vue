<template>
  <div>
    <section class="page-header">
      <h1>Sol Token Prices</h1>
    </section>

    <div class="card">
      <div class="card-content">
        <div class="d-inline-block mb-4 float-md-end">
          {{ create_filter_links }}
          <div class="btn-group">
            <div v-for="filter_by_days in filter_by_days_options">
              <a :href="sol_prices_path(filter_by_days)"
                 title="`Filter by ${filter_days} days`"
                 class="btn btn-sm btn-secondary nav-link chartFilterButton `${filter_btn_class(filter_days)}">
                {{ `{{filter_days}} days` }}
              </a>
            </div>
          </div>
        </div>

        <div class="tab-content" id='sol-prices-tab-content'>
          <div class="tab-pane solPriceChartTab <%= active_tab?(:coin_gecko) %>" id="coinGeckoChartTab">
            <%= render 'coin_gecko_chart' %>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  const filter_by_days_options = [7, 30, 60, 90]

  export default {
    data() {
      return {
        filter_days_options: filter_days_options
      }
    },
    methods: {
      filter_btn_class(filter_by_days) {
        return window.location.href.includes(`filtering=${filter_by_days}`) ? " active" : "";
      },
      exchange_params() {
        return window.location.href.includes("exchange=true") ? true : false;
      },
      sol_prices_path(filter_by_days) {
        return `/sol-prices?network=${this.network}&filtering=${filter_by_days}&exchange=${exchange_params}`;
      }
    },
    computed: mapGetters([
      'network'
    ]),
  }
</script>
