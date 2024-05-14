#frozen_string_literal: true

module Archivable
  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper

  def archive_class
    Object.const_get(self.name + "Archive")
  end

  def archive_due_to(date_to:, network:, destroy_after_archive: false)
    begin
      records = where(network: network).where("created_at < ?", date_to)
      total = records.count

      puts_no_test "Archiving #{total} records for #{self.name} (#{network})"

      records.find_each.with_index do |record, idx|
        print_no_test "\r#{number_with_delimiter(idx + 1)}/#{total}"
        archive(record, destroy_after_archive: destroy_after_archive)
      end

      puts_no_test "...done!"
    rescue NameError => e
      puts_no_test e
      raise "Archive class not found for #{self.name}"
    end
  end

  def archive_due_epoch(epoch:, network:, destroy_after_archive: false)
    raise "Epoch does not exist for this class" if self.column_names.exclude?("epoch")

    begin
      records = where(network: network).where("epoch < ?", epoch)
      total = records.count

      puts_no_test "Archiving #{total} records for #{self.name} (#{network})"

      records.find_each.with_index(1) do |record, idx|
        print_no_test "\r#{number_with_delimiter(idx)}/#{total}"
        archive(record, destroy_after_archive: destroy_after_archive)
      end

      puts_no_test "...done!"
    rescue NameError => e
      puts_no_test e
      raise "Archive class not found for #{self.name}"
    end
  end

  def archive(record, destroy_after_archive: false)
    archive = archive_class.find_or_initialize_by(id: record.id)
    archive.update!(record.attributes)
    record.destroy! if destroy_after_archive
  end

  def puts_no_test(msg)
    puts msg unless Rails.env.test?
  end

  def print_no_test(msg)
    print msg unless Rails.env.test?
  end
end
