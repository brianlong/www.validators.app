module SolPricesHelper
  def create_filter_links
    div_css_classes = ["btn-group"]
    
    content_tag(:div, nil, class: div_css_classes) do
      
      @filter_days.map do |filter|
        button_css_classes = 'btn btn-xs btn-secondary nav-link chartFilterButton'

        if filter.to_s == params[:filtering]
          button_css_classes += ' active'
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

  def active_tab?(exchange)
    return nil unless params[:exchange]
    
    params[:exchange].to_sym == exchange ? 'active' : 'fade'
  end

  def active_button?(exchange)
    return nil unless params[:exchange]

    'active' if params[:exchange]&.to_sym == exchange
  end
end
