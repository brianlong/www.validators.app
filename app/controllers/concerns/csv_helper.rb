# frozen_string_literal: true

module CsvHelper
  def convert_to_csv(headers, data)
    ::CSV.generate do |csv|
      csv << headers
      data = data.is_a?(Array) ? data : [data]
      data.each do |row|
        values = headers.map do |header|
          row[header].is_a?(Array) ? row[header].compact.join(", ") : row[header]
        end

        csv << values
      end
    end
  end
end
