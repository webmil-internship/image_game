class Scheduler
  def self.call
    scheduler = Rufus::Scheduler.new

    scheduler.cron '00 09 * * *' do
      # every '1m' do ---- write it for testing
      Task.new.perform
    end
  end
end
