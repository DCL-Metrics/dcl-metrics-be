print "dropping raw_internal_metrics table\n"

Sequel.migration do
  change do
    drop_table(:raw_internal_metrics)
  end
end
