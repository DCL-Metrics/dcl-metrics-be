model = Models::PeersDump
columns = model.columns - [:id]

(Date.parse('2022-04-01')..Date.parse('2022-12-31')).each do |date|
  data = Models::PeersDump.
    where(created_at: ("#{date} 00:00:00".."#{date} 11:59:59")).
    all.
    map { |d| d.values.except(:id).values }

  Sequel.connect(ENV['HEROKU_POSTGRESQL_PINK_URL']) do |db|
    db[:peers_dump].import(columns, data)
  end
  print '.'

  data = Models::PeersDump.
    where(created_at: ("#{date} 12:00:00".."#{date} 23:59:59")).
    all.
    map { |d| d.values.except(:id).values }

  Sequel.connect(ENV['HEROKU_POSTGRESQL_PINK_URL']) do |db|
    db[:peers_dump].import(columns, data)
  end
  print '.'
end

