module SolPricesHelper
  def active_tab?(exchange)
    return nil unless params[:exchange]
    
    params[:exchange].to_sym == exchange ? "active" : "fade"
  end
end
