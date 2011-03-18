class Sliver::Template
  attr_reader :doc, :subs

  def initialize(doc, full_document = true)
    @subs = {}
    @doc = full_document ? Nokogiri::HTML(doc.to_html) : Nokogiri::HTML.fragment(doc.to_html)
  end

  def self.load_template(filename)
    self.new(File.read(filename))
  end

  def change(selector, data)
    # render to noko objs and #swap?
    get_selectors(selector).each { |s| s.inner_html= data.to_html }
    self
  end

  def set_attributes(selector, attrs)
    get_selectors(selector).each { |s| attrs.each{ |k, v| s[k.to_s] = v.to_s } }
    self
  end

  def set_class(selector, class_val)
    set_attributes(selector, {:class => class_val})
  end

  def add_into(selector, data)
    get_selectors(selector).each { |s| s.add_child data.to_html }
    self
  end

  def insert_into(selector, data)
    get_selectors(selector).each { |s| s.children.first.add_previous_sibling data.to_html }
    self
  end

  def delete(selector)
    get_selectors(selector).each { |s| s.remove }
    self
  end

  def empty(selector)
    get_selectors(selector).each { |s| s.children.each{ |x| x.remove } }
    self
  end

  def list(selector, data_list)
    sub = make_repeating_sub(selector).clone
    empty(selector)
    data_list.each{ |d| add_into(selector, yield(d, @subs[selector].dup).render) }
  end

  def render
    @doc.to_html
  end

  def render_to_file(filename = 'test2.html')
    File.open(filename, 'w') { |f| f.write(self.render) }
  end

  private

  def get_selectors(selector)
    selecteds = @doc.css(selector)
    raise "No element found in template for selector \"#{selector}\"" if selecteds.empty?
    selecteds
  end

  def make_repeating_sub(selector)
    node = get_selectors(selector).first.element_children.first
    @subs[selector] = Sliver::Template.new(node, false)
  end

end

