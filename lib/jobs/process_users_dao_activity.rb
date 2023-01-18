module Jobs
  class ProcessUsersDaoActivity < Job
    sidekiq_options queue: 'processing'

    # 3. go through each sheet's data and pull out the defined attributes
    # for the UserDaoActivity model by address
    # 4. then put all the data grouped by address together so it can be saved
    # in a json field like "data_json"

    # members for total/delegated_vp, delegators and delegate
    # votes for first/last votes cast and votes cast
    # proposals for proposals authored
    # grants for determining beneficiaries with most grants
    # collections for collection creator
    # team for filling memberships_json / active dao committee member
    # kpis for overall data
    #
    # first_vote, most_recent_vote = votes.
    #   group_by { |x| x['Member'] }["0x895Be97bDb9F8a244c472B18EA96DeE39ddf8fe5"].
    #   sort_by { |x| x['Created'] }.minmax
    def perform
      data = Adapters::Dcl::DaoTransparency::ActivityWrapper.call

      # data.each do |member|
      #   # create or update based on address
      #   # Models::UserDaoActivity.create(dao_activity(address))
      # end
    end
  end
end
