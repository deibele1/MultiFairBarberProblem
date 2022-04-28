class Semaphore
  def initialize
    @count = 0
    @mutex = Mutex.new
  end

  def signal
    @mutex.synchronize do
      @count += 1
    end
    @count
  end

  def peek
    @count
  end

  def release
    @mutex.synchronize do
      @count -= 1
    end
  end
end
