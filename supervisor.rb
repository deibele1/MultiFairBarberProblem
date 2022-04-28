require './vector'
require './semaphore'
require './worker'

class Supervisor
  # @param number_of_workers determine the number of worker threads that will get jobs from this supervisor
  def initialize(number_of_workers, max_queue_length: 5, overflow_handler: Proc.new { print("queue overflow: ") })
    @overflow_handler = overflow_handler
    @queue_length = Semaphore.new
    @max_queue_length = max_queue_length
    @pool = Vector.new
    @subscription_identifier = Semaphore.new
    @next_task_identifier = Semaphore.new
    @jobs = Hash.new
    @workers = []
    number_of_workers.times { add_worker }
  end

  # @param job Proc to be executed by worker threads
  def queue(job)
    return @overflow_handler.call(job) if @queue_length.peek + 1 > @max_queue_length
    @queue_length.signal

    @jobs[@next_task_identifier.signal] = job
    @pool.next.wakeup if @pool.has_next?
  end

  # @note should only be called by a worker thread capable consuming the result procedure
  def subscribe
    subscription_identifier = @subscription_identifier.signal
    Proc.new do
      unless @jobs[subscription_identifier]
        @pool.add(Thread.current)
        sleep
      end
      @queue_length.release
      @jobs.delete(subscription_identifier)&.call
    end
  end

  private def add_worker
    @workers << Worker.new(self)
  end

  # kills all jobs overseen by the supervisor worker threads are stopped on their next subscription
  # @note no jobs will be executed even those already in the queue
  def kill
    define_singleton_method :subscribe do
      Proc.new { Thread.exit }
    end
    @workers.each(&:wakeup)
  end

  # indicates no new jobs are to be executed. Those already in the queue will be executed. Worker threads will be stopped as soon as the queue is empty.
  # @note finished the jobs currently in the queue then stops the worker threads
  def stop
    define_singleton_method :subscribe do
      subscription_identifier = @subscription_identifier.signal
      Proc.new do
        (@jobs.delete(subscription_identifier) || Proc.new { Thread.exit } ).call
      end
    end
  end

  # indicates the process is to stop when the queue is empty and waits for threads to finish
  def wait
    stop
    @workers.each(&:join)
  end
end
