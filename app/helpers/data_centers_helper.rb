module DataCentersHelper
  def render_table_header_by(sort_by)
    if sort_by == 'asn'
      render 'asn_head'
    elsif [nil, 'data_center'].include? sort_by
      render 'data_center_head'
    end
  end

  def render_table_content_by(sort_by)
    if sort_by == 'asn'
      render 'asn_list'
    elsif [nil, 'data_center'].include? sort_by
      render 'data_center_list'
    end
  end

  def count_percentage(dividend, divisor)
    (dividend.to_f / divisor.to_f * 100).round(2)
  end

  def create_link_to_toggle_private(type:)
    case type
    when :data_center
      link_to show_private? ? "Hide private" : "Show private",
        data_center_url(network: params[:network], key: params[:key], show_private: !show_private?),
        class: "btn btn-xs btn-secondary mr-1 mb-4 float-right"
    when :asn
      link_to show_private? ? "Hide private" : "Show private",
        asn_url(network: params[:network], asn: params[:asn], show_private: !show_private?),
        class: "btn btn-xs btn-secondary mr-1 mb-4 float-right"
    end
  end

  def show_private?
    if params[:show_private].blank? || (params[:filter_by].blank? && params[:show_private] == "true")
      true
    else
      false
    end
  end
end
