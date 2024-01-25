Models::WorldsDump.where(total_world_count: nil).first(1000).each_slice(100) do |dumps|
  dumps.each do |dump|
    data = dump.data
    world_count = data['world_count']
    next if world_count.nil?
    total_wc = world_count.is_a?(Integer) ? world_count : world_count.sum(&:last)
    dcl_wc = world_count.is_a?(Integer) ? 0 : world_count['dcl']
    ens_wc = world_count.is_a?(Integer) ? 0 : world_count['ens']

    dump.update(
      occupied_worlds: data['total_rooms'],
      total_user_count: data['total_user_count'],
      total_world_count: total_wc,
      dcl_world_count: dcl_wc,
      ens_world_count: ens_wc
    )
  end
  print '.'
end;nil
