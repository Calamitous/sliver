require File.expand_path('../../lib/sliver/template', __FILE__)

# load './example.html.sliver.rb'; ExampleView.new.render_to_file('test2.html')

class ExampleView < Sliver::Template

  def initialize
    super File.basename(__FILE__, '.sliver.rb')
  end

  # use_template 'test.html'
  def render
    name = "George"
    list_snippet = [
      [:p, "#{name}'s Phone"],
      [:p, "#{name}'s Address", {:class => 'selected'}],
      [:p, "#{name}'s OS Preference"],
    ]

    change('h1', 'Zorbo\'s Awesome Website')
    add_into('.link', name)
    change('#list', list_snippet)

    # set('.link', {:href => home_url})
    # delete('#admin_login') unless @is_admin
    super
  end
end
