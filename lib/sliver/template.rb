class Sliver::Template
  attr_reader :doc, :subs

  def initialize(doc, full_document = true)
    @subs = {}
    @doc = full_document ? Nokogiri::HTML(doc.to_html) : Nokogiri::HTML.fragment(doc.to_html)
  end

  def self.load_template(filename)
    self.new(File.read(filename))
  end

  def change(selector, data, options = {})
    # render to noko objs and #swap?
    get_selectors(selector, !options[:silent_failure]).each { |s| s.inner_html= data.to_html }
    self
  end

  def set_attributes(selector, attrs, options = {})
    get_selectors(selector, !options[:silent_failure]).each { |s| attrs.each{ |k, v| s[k.to_s] = v.to_s } }
    self
  end

  def set_class(selector, class_val, options = {})
    set_attributes(selector, {:class => class_val}, options)
  end

  def add_into(selector, data, options = {})
    get_selectors(selector, !options[:silent_failure]).each { |s| s.add_child data.to_html }
    self
  end

  def insert_into(selector, data, options = {})
    get_selectors(selector, !options[:silent_failure]).each { |s| s.children.first.add_previous_sibling data.to_html }
    self
  end

  def delete(selector, options = {})
    get_selectors(selector, !options[:silent_failure]).each { |s| s.remove }
    self
  end

  def empty(selector, options = {})
    get_selectors(selector, !options[:silent_failure]).each { |s| s.children.each{ |x| x.remove } }
    self
  end

  def list(selector, data_list, options = {})
    raise(ArgumentError, "Block expected") unless block_given?
    sub = make_repeating_sub(selector, options)
    return self unless sub
    empty(selector)
    data_list.each{ |d| add_into(selector, yield(d, @subs[selector].dup).render) }
    self
  end

  def render
    @doc.to_html
  end

  def render_to_file(filename = 'test2.html')
    File.open(filename, 'w') { |f| f.write(self.render) }
  end

  private

  def get_selectors(selector, raise_errors = true)
    selecteds = @doc.css(selector)
    raise "No element found in template for selector \"#{selector}\"" if selecteds.empty? && raise_errors
    selecteds
  end

  def make_repeating_sub(selector, options = {})
    node = get_selectors(selector, !options[:silent_failure]).first
    return unless node
    sub = node.element_children.first
    return unless sub
    @subs[selector] = Sliver::Template.new(sub, false)
  end

end

