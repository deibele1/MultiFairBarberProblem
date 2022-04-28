require './supervisor'
$demand = 5
$delay = 1
$barbers = 15
$total_customers = 50
$chairs = 5

def add_call(identifier)
  @supervisor.queue(Proc.new do
    puts "#{identifier} started"
    sleep(rand(1..3) * $delay)
    puts "  #{identifier} finished"
  end)
end

@supervisor = Supervisor.new($barbers, overflow: $chairs)
@num = Semaphore.new
while @num.peek + 1 < $total_customers do
  sleep(rand(0.0..3.0) / $demand)
  Thread.new do
    num = @num.signal
    add_call(num)
    puts("#{num} arrived")
  end
end
@supervisor.wait