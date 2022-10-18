module Jobs
  class ExportDataToStagingDb < Job
    sidekiq_options queue: 'low'

    def perform(model_name, period, table_name = nil)
      return unless ENV['RACK_ENV'] == 'production'

      table_name ||= model_name.to_sym
      klass_name = model_name.split('_').map(&:capitalize).join
      model = Models.const_get(klass_name)
      columns = model.columns - [:id]

      data = model.
        where { date >= Date.today - period }.
        all.
        map { |d| d.values.except(:id).values }

      # staging db
      Sequel.connect(ENV['HEROKU_POSTGRESQL_ONYX_URL']) do |db|
        db[table_name].truncate
        db[table_name].import(columns, data)
      end

      nil
    end
  end
end
