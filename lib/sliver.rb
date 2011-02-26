require 'rubygems'
require 'lib/omg_monkeys'
require 'nokogiri'

class Sliver
  attr_reader :doc

  def initialize(doc)
    @doc = Nokogiri::HTML(doc)
  end
end

