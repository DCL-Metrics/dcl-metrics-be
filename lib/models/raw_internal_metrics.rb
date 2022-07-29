# primary_key :id
#
# Date   :date,         null: false
# String :endpoint,     null: false
# Jsonb  :metrics_json, null: false
#
# Time   :created_at,   null: false
#
# add_index :raw_internal_metrics, [:date]
# add_index :raw_internal_metrics, [:endpoint]

module Models
  class RawInternalMetrics < Sequel::Model
    def metrics
      JSON.parse(metrics_json)
    end
  end
end
