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

  def change(selector, data)
    # render to noko objs and #swap?
    get_selector(selector).inner_html= data.to_html
  end

  def add_into(selector, data)
    get_selector(selector).add_child data.to_html
  end

  def insert_into(selector, data)
    get_selector(selector).children.first.add_previous_sibling data.to_html
  end

  def delete(selector)
    get_selector(selector).remove
  end

  def empty(selector)
    get_selector(selector).children.each(&:remove)
  end

  def render
    @doc.to_html
  end

  def render_to_file(filename = 'test2.html')
    File.open(filename, 'w') { |f| f.write(self.render) }
  end

  private

  def get_selector(selector)
    selected = @doc.at_css(selector)
    raise "No element found in template for selector \"#{selector}\"" unless selected
    selected
  end

end

