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

  def link_to_toggle_private(type:, url_params:)
    case type
    when :data_center
      link_to show_private?(url_params) ? "Hide private" : "Show private",
        data_center_url(network: url_params[:network], key: url_params[:key], show_private: !show_private?(url_params)),
        class: "btn btn-sm btn-secondary mr-1 mb-4"
    when :asn
      link_to show_private?(url_params) ? "Hide private" : "Show private",
        asn_url(network: url_params[:network], asn: url_params[:asn], show_private: !show_private?(url_params)),
        class: "btn btn-sm btn-secondary mr-1 mb-4"
    end
  end

  def show_private?(url_params)
    if url_params[:show_private].blank? || (url_params[:filter_by].blank? && url_params[:show_private] == "true")
      true
    else
      false
    end
  end

  def create_filter_link(view:, params_list:, filter_by:)
    classes_list = "btn btn-sm btn-secondary mr-1 mb-4 "
    classes_list << "active" if params_list[:filter_by] == filter_by
    url = send("#{view}_url",
                network:params_list[:network],
                key: params[:key],
                filter_by: filter_by
              )

    link_to "Filter by #{filter_by}", url, class: classes_list
  end
end
