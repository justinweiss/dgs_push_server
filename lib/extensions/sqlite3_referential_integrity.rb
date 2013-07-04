module Extensions
  module SQLite3ReferentialIntegrity
    def disable_referential_integrity
      execute "PRAGMA foreign_keys = OFF"
      super
    ensure
      execute "PRAGMA foreign_keys = ON"
    end
  end
end

ActiveRecord::ConnectionAdapters::SQLite3Adapter.send(:include, Extensions::SQLite3ReferentialIntegrity) if defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
