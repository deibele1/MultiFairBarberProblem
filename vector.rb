class Vector
  def initialize
    @mutex = Mutex.new
    @elements = []
  end

  def next
    @mutex.synchronize { @elements.shift }
  end

  def has_next?
    @mutex.synchronize { @elements.any? }
  end

  def add(element)
    @mutex.synchronize { @elements.append element}
  end

end
