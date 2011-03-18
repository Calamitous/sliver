require File.expand_path('../../lib/sliver/template', __FILE__)

# load './example.html.sliver.rb'; ExampleView.new.render_to_file('test2.html')

# load '../lib/sliver.rb'; load './example.html.sliver.rb'; ev = ExampleView.new; a = ev.make_repeating_sub('#list')
#
class ExampleView < Sliver::Transformer

  def initialize(data = {})
    @data = data
    #super File.basename(__FILE__, '.sliver.rb')
    super './example.html'
  end

  # use_template 'test.html'
  def render
    change('h1', 'Zorbo\'s Awesome Website')
    add_into('.link', name)
    change('#list', list_snippet('George'))
    add_into('.link', 'name')

    set_attributes('.link', {:href => home_url})
    #set_class('.selected', 'chosen')
    #delete('#admin_login') unless @data[:is_admin]
    super
  end

  private

  def home_url
    '/disco'
  end

  def list_snippet(name)
    [
      [:p, "#{name}'s Phone"],
      [:p, "#{name}'s Address", {:class => 'selected'}],
      [:p, "#{name}'s OS Preference"],
    ]
  end
end
