require './supervisor'
$demand = 5
$delay = 1
$barbers = 10
$total = 20
$chairs = 5

def add_call(identifier)
  @supervisor.queue(Proc.new do
    puts "#{identifier} started"
    sleep(rand(1..5) * $delay)
    puts "  #{identifier} finished"
    @waiting.release
  end)
end

@waiting = Semaphore.new
@supervisor = Supervisor.new($barbers)
@num = Semaphore.new
while @num.peek <= $total do
  sleep(rand(0.0..3.0) / $demand)
  Thread.new do
    num = @num.signal
    if @waiting.peek < $chairs
      @waiting.signal
      puts("#{num} is waiting")
      add_call(num)
    else
      puts("#{num} came and left because there wasn't a chair")
    end
  end
end
@supervisor.wait