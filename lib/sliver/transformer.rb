require File.expand_path('../../sliver', __FILE__)

class Sliver::Transformer < Sliver
  def initialize(filename)
    # super.new(File.read(filename))
    super File.read(filename)
  end

end

