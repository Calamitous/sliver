require 'rubygems'
require 'nokogiri'
require File.expand_path('../../lib/omg_monkeys', __FILE__)

class Sliver
  attr_reader :doc

  def initialize(doc)
    @doc = Nokogiri::HTML(doc)
  end

  def self.load_template(filename)
    self.new(File.read(filename))
  end

  def add(selector, data)
    selected = @doc.at_css(selector)

    raise "No element found in template for selector \"#{selector}\"" unless selected
    selected.add_child data.to_html
  end

  def change(selector, data)
    selected = @doc.at_css(selector)

    raise "No element found in template for selector \"#{selector}\"" unless selected
    selected.content = data.to_html
  end

  def render
    @doc.to_html
  end

  def render_to_file(filename = 'test2.html')
    File.open(filename, 'w') { |f| f.write(self.render) }
  end

  def self.test
    template = Sliver.load_template('test.html')
    things = ['Thing 1', 'Thing 2', 'NO WAI WAT']

    template.change('.test', "Go to Home")
    template.change('#list', things.map{|x| [:p, x]})
    template.render_to_file
    template
  end
end

