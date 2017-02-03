class StreamSpy

  def initialize
    @written = []
    @received = []
    @fail_next_write = false
  end

  def <<(o)
    maybe_fail
    @written << o
  end

  def flush
    @received.concat(@written)
    @written.clear
  end

  def received
    @received.dup
  end

  def fail_next_write(message = "write failed intentionall")
    @fail_next_write = message
  end

  def maybe_fail
    if @fail_next_write
      message = @fail_next_write
      @fail_next_write = false
      raise IOError.new(message)
    end
  end

end
