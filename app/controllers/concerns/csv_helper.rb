# frozen_string_literal: true

module CsvHelper
  def convert_to_csv(headers, data)
    CSV.generate do |csv|
      csv << headers
      data.each do |row|
        csv << row.values_at(*headers)
      end
    end
  end
end
