# frozen_string_literal: true

def create_data_center
  data_center = DataCenter.create
  data_center.update_column(data_center_key: 'Unknown')

  data_center_host = DataCenterHost.create(
    host: nil,
    data_center: data_center
  )
end

