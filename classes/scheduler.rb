class Scheduler
  def self.call
    scheduler = Rufus::Scheduler.new

    scheduler.every '1m' do
      # cron '00 09 * * *' do
      Task.new.send
    end
  end
end
