module SolPricesHelper
  def create_filter_links
    div_css_classes = ['btn-group', 'btn-group-sm mt-3', 'mb-3']
    
    content_tag(:div, nil, class: div_css_classes) do
      
      [7, 30, 90, 'all'].map do |filter|
        button_css_classes = 'btn btn-sm btn-secondary chartFilterButton'

        if filter.to_s == params[:filtering]
          button_css_classes += ' active'
        end
        link_text = filter.is_a?(Integer) ? "#{filter} days" : filter.capitalize
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
    params[:exchange].to_sym == exchange ? 'active' : 'fade'
  end

  def active_buttin?(exchange)
    'active' if params[:exchange].to_sym == exchange
  end
end
