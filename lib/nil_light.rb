class NilLight

  def initialize
    ap "No light present. Falling back to NilLight"
  end

  def off!; end
  def failure!; end
  def warning!; end
  def success!; end
end