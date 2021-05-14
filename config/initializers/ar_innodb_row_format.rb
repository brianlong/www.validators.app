require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    # This initializer ensures to set column limit to 191 for the column type varchar 
    # at the time of executing ALTER or CREATE command on the table.
    #
    # Why length 191?
    # MySQL indexes are limited to 768 bytes because the InnoDB storage engine has a maximum index length of 767 bytes.
    # This means that if we increase VARCHAR(255) from 3 bytes per character to 4 bytes per character,
    # the index key is smaller in terms of characters.
    # 
    # That's why we need to change the length from 255 to 191.

    class AbstractMysqlAdapter
      NATIVE_DATABASE_TYPES[:string] = { name: 'varchar', limit: 191 }
    end
  end
end