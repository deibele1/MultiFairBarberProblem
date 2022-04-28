require './supervisor'
class Worker
  def initialize(supervisor)
    @supervisor = supervisor
    @thread = Thread.new do
      supervisor.subscribe.call while true
    end
  end

  def wakeup
    @thread.wakeup if @thread.alive?
  end

  def join
    wakeup if @thread.alive?
    @thread.join
  end
end
