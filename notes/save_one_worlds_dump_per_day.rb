start_date = Models::WorldsDump.order(:created_at).first.created_at.to_date

(Date.today - 7).upto(Date.today - 3) do |date|
  daily = DATABASE_CONNECTION[
    "select * from worlds_dump where created_at::date = '#{date}' order by created_at"
  ].all

  to_save = daily.last
  to_delete = daily - [to_save]
  ids = to_delete.map { |x| x[:id] }

  Models::WorldsDump.where(id: ids).delete
end
