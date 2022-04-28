require './supervisor'
$demand = 5
$delay = 1
$barbers = 3
$total_customers = 50
$chairs = 5

def add_call(identifier)
  @supervisor.queue(Proc.new do
    puts "  #{identifier} started"
    sleep(rand(0.5..2.0) * $delay)
    puts "    #{identifier} finished"
  end)
end

@supervisor = Supervisor.new($barbers, max_queue_length: $chairs, overflow_handler: lambda { |_job| print ": no seat available" })
@num = Semaphore.new
while @num.peek + 1 < $total_customers do
  sleep(rand(0.0..3.0) / $demand)
  Thread.new do
    num = @num.signal
    print("#{num} arrived")
    add_call(num)
    print("\n")
  end
end
@supervisor.wait