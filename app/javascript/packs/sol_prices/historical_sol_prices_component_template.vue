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

          </div>
        </div>

        <!-- Tab panes -->
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
  export default {
    data() {
      return {
      }
    },
    methods: {
    },
    mounted() {
    },
  }
</script>

  def create_filter_links
    div_css_classes = ["btn-group"]
    
    content_tag(:div, nil, class: div_css_classes) do
      
      @filter_days.map do |filter|
        button_css_classes = "btn btn-sm btn-secondary nav-link chartFilterButton"

        if filter.to_s == params[:filtering]
          button_css_classes += " active"
        end

        link_text = "#{filter} days"
        
        link_to link_text, 
                sol_prices_url(
                  network: params[:network], 
                  filtering: filter,
                  exchange: params[:exchange]
                ),
                class: button_css_classes,
                remote: true 
      end.join.html_safe
    end
  end
