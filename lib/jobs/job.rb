module Jobs
  class Job
    include Sidekiq::Worker
  end
end
