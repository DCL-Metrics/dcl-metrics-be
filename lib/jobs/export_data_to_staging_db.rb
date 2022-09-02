module Jobs
  class ExportDataToStagingDb < Job
    sidekiq_options queue: 'low'

    def perform(model_name, period)
      return unless ENV['RACK_ENV'] == 'production'

      klass_name = model_name.split('_').map(&:capitalize).join
      model = Models.const_get(klass_name)
      columns = model.columns - [:id]
      data = model.
        where { date >= Date.today - period }.
        all.
        map { |d| d.values.except(:id).values }

      Sequel.connect(ENV['STAGING_DB_URL']) do |db|
        db[model_name.to_sym].truncate
        db[model_name.to_sym].import(columns, data)
      end

      nil
    end
  end
end
