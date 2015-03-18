class NilLight
  include ::Logger

  def initialize
    logger.warn "No light present. Falling back to NilLight"
  end

  def off!;      end
  def failure!;  end
  def warning!;  end
  def success!;  end
  def running!;  end
  def claimed!;  end
  def happy!;    end
end