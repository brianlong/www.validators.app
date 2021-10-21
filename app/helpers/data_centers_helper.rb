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
end
