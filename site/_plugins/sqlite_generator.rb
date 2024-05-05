require 'sqlite3'

module JekyllSQLite
  class SqliteDataSource < Jekyll::Generator

    def process_data_configs(db, configs, data)
        configs.each do |config|
          data_name = config['data']
          query = build_query(config['query'], data) 
          result = db.execute(query)
          data[data_name] = result
          return 
        end
    end

    def build_query(query, data)
        query.gsub(/:(\w+)/) do |match|
          key_name = $1
          data[key_name] || "MISSING_KEY_#{key_name}" 
        end
    end

    def generate(site)
      site.config['sqlite'].each do |data_config|
        SQLite3::Database.open(data_config["file"], readonly: true) do |db|
            data_name = data_config['data']
            db.results_as_hash = true
            query = data_config['query']
            count = process_data_configs(db, [data_config], site.data)
            Jekyll.logger.info "Jekyll SQLite:", "Loaded #{data_name} with count=#{site.data[data_name].count}, as_hash=#{db.results_as_hash}"
        end
      end
    end
  end
end
