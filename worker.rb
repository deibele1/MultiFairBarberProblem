require './supervisor'
class Worker
  def initialize(supervisor)
    @supervisor = supervisor
    @living = true
    @thread = Thread.new do
      supervisor.subscribe.call while @living
    end
  end

  def wakeup
    @thread.wakeup
  end

  def join
    wakeup if @thread.alive?
    @thread.join
  end
end
