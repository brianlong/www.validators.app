class ChangeEncodingToUtfmb4 < ActiveRecord::Migration[6.1]
  def up
    charset = 'utf8mb4'
    collation = set_collation(charset)

    execute "ALTER DATABASE `#{db.current_database}` CHARACTER SET #{charset}
      COLLATE #{collation};"
    db.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET
      #{charset} COLLATE #{collation};"

      db.columns(table).each do |column|
        case column.sql_type
        when /([a-z]*)text/i
          alter_column_charset_and_collation(table, column, charset, collation)
        when /varchar\(([0-9]+)\)/i
          alter_column_charset_and_collation(table, column, charset, collation)
        end
      end
    end
  end

  def down
    # Please be careful, when doing rollback, if you have strings encoded in utfmb4
    # you'll get an error: Mysql2::Error: Incorrect string value: '\xF0\x9F\xA7\xB1\xF0\x9F...
    # To fix this, you should go through your data and encode it in UTF8
    # and replace/remove all incorrect characters.
    charset = 'utf8'
    collation = set_collation(charset)

    execute "ALTER DATABASE `#{db.current_database}` CHARACTER SET #{charset}
      COLLATE #{collation};"
    db.tables.each do |table|
      execute "ALTER TABLE `#{table}` CHARACTER SET
        #{charset} COLLATE #{collation};"
  
      db.columns(table).each do |column|
        case column.sql_type
        when /([a-z]*)text/i
          alter_column_charset_and_collation(table, column, charset, collation)
        when /varchar\(([0-9]+)\)/i
          alter_column_charset_and_collation(table, column, charset, collation)
        end
      end
    end
  end

  private

  def alter_column_charset_and_collation(table, column, charset, collation)
    default = column.default.blank? ? '' : "DEFAULT '#{column.default}'"
    null = column.null ? '' : 'NOT NULL'
    execute "ALTER TABLE `#{table}` MODIFY `#{column.name}` #{column.sql_type.upcase}
      CHARACTER SET #{charset} COLLATE #{collation} #{default} #{null};"
  end

  def set_collation(charset)
    if mysql_version < 8
      "#{charset}_unicode_ci"
    elsif mysql_version >= 8
      "#{charset}_0900_ai_ci" if charset == 'utf8mb4'
      "#{charset}_unicode_ci" if charset == 'utf8'
    end
  end

  def mysql_version
    mysql_version_sql = 'SELECT VERSION()'
    version = ActiveRecord::Base.connection.select_value(mysql_version_sql)
    version[0].to_i
  end

  def db
    ActiveRecord::Base.connection
  end
end
