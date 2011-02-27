require 'rubygems'
require 'nokogiri'
require_relative '../lib/omg_monkeys'

class Sliver
  attr_reader :doc

  def initialize(doc)
    @doc = Nokogiri::HTML(doc)
  end
end

