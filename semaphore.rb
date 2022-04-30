require './counter'
class Semaphore < Counter
  def release
    @mutex.synchronize do
      @count =- 1
    end
  end
end
