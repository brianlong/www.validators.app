module Archivable
  extend ActiveSupport::Concern

  def archive_class
    Object.const_get(self.name + "Archive")
  end

  def archive_due_to(date_to: , destroy_after_archive: false)
    begin
      records = where("created_at <= ?", date_to)
      puts "Archiving #{records.count} records for #{self.name}"

      records.find_each do |record|
        archive = archive_class.find_or_initialize_by(id: record.id)
        record.attributes.each do |attr, value|
          archive.send("#{attr}=", value)
        end
        archive.save!
        record.destroy! if destroy_after_archive
      end

      puts "Archieved #{records.count} records for #{self.name}"
    rescue NameError => e
      puts e
      raise "Archive class not found for #{self.name}"
    end
  end
end
