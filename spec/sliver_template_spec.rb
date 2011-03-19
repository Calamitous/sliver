require 'rubygems'
require 'rspec/autorun'
require File.expand_path('../../lib/sliver', __FILE__)

describe 'Sliver::Template' do
  context 'rendering' do
    before do
      @template = <<TEMPLATE
        <html>
          <head>
          </head>
          <body>
            <h1>Title!</h1>
            <a class="link" href="/wtf">Click Me!</a>
            <pre class="LOLCAT">CODE ME SOME CODE</pre>
            <div id="list">
              <p>Some text</p>
              <p>MORE text</p>
            </div>
          </body>
        </html>
TEMPLATE
      @sliver = Sliver::Template.new(@template)
    end

    context '#new' do
      it 'sets the doc value' do
        Sliver::Template.new('<br />').doc.should_not be_nil
      end

      it 'automatically converts monkey arrays' do
        Sliver::Template.new([:c, [:p, 'A'], [:p, 'B']]).render.should match(%r+<c><p>A</p>\s*<p>B</p></c>+)
      end
    end

    context '#change' do
      it 'replaces the contents of the requested element' do
        @sliver.change('.link', 'Go to Home')
        @sliver.render.should match(%r+<a class="link" href="/wtf">Go to Home</a>+)
      end

      it 'errors out when the selector is not found' do
        lambda { @sliver.change('INVALIDNODE', 'Go to Home') }.should raise_error
      end

      it 'allows caller to override "not found" behavior' do
        lambda { @sliver.change('INVALIDNODE', 'Go to Home', :silent_failure => true) }.should_not raise_error
      end

      it 'automatically converts monkey arrays' do
        @sliver.change('.link', [:p, 'pop'])
        @sliver.render.should match(%r+<a class="link" href="/wtf"><p>pop</p></a>+)
      end

      it 'is chainable' do
        @sliver.change('#list', [:b, 'Stuff']).render.should match(%r+<div id="list"><b>Stuff</b></div>+)
      end

      it 'updates all nodes that match' do
        sliver = Sliver::Template.new('<p>A</p><p>B</p>')
        sliver.change('p', 'C')
        sliver.render.should match(%r+<p>C</p>\s*<p>C</p>+)
      end
    end

    context '#add_into' do
      it 'appends to the contents of the requested element' do
        @sliver.add_into('.link', ' Please!')
        @sliver.render.should match(%r+<a class="link" href="/wtf">Click Me! Please!</a>+)
      end

      it 'errors out when the selector is not found' do
        lambda { @sliver.add_into('INVALIDNODE', ' Please!') }.should raise_error
      end

      it 'allows caller to override "not found" behavior' do
        lambda { @sliver.add_into('INVALIDNODE', ' Please!', :silent_failure => true) }.should_not raise_error
      end

      it 'automatically converts monkey arrays' do
        @sliver.add_into('#list', [:p, 'less text'])
        @sliver.render.should match(%r+<p>MORE text</p>\s*<p>less text</p>+)
      end

      it 'is chainable' do
        @sliver.add_into('.link', 'Hi').render.should match(%r+href="/wtf">Click Me!Hi</a>+)
      end

      it 'updates all nodes that match' do
        sliver = Sliver::Template.new('<p>A</p><p>B</p>')
        sliver.add_into('p', 'C')
        sliver.render.should match(%r+<p>AC</p>\s*<p>BC</p>+)
      end
    end

    context '#insert_into' do
      it 'inserts contents of the requested element' do
        @sliver.insert_into('.link', 'Please! ')
        @sliver.render.should match(%r+<a class="link" href="/wtf">Please! Click Me!</a>+)
      end

      it 'errors out when the selector is not found' do
        lambda { @sliver.insert_into('INVALIDNODE', 'Please! ') }.should raise_error
      end

      it 'allows caller to override "not found" behavior' do
        lambda { @sliver.insert_into('INVALIDNODE', 'Please! ', :silent_failure => true) }.should_not raise_error
      end


      it 'automatically converts monkey arrays' do
        @sliver.insert_into('#list', [:p, 'less text'])
        @sliver.render.should match(%r+<p>less text</p>\s*<p>Some text</p>+)
      end

      it 'is chainable' do
        @sliver.insert_into('.link', 'Hi').render.should match(%r+href="/wtf">HiClick Me!</a>+)
      end

      it 'updates all nodes that match' do
        sliver = Sliver::Template.new('<p>A</p><p>B</p>')
        sliver.insert_into('p', 'C')
        sliver.render.should match(%r+<p>CA</p>\s*<p>CB</p>+)
      end
    end

    context '#delete' do
      it 'removes the requested element' do
        @sliver.render.should match(/Click/)
        @sliver.delete('.link')
        @sliver.render.should_not match(/Click/)
      end

      it 'errors out when the selector is not found' do
        lambda { @sliver.delete('INVALIDNODE') }.should raise_error
      end

      it 'allows caller to override "not found" behavior' do
        lambda { @sliver.delete('INVALIDNODE', :silent_failure => true) }.should_not raise_error
      end

      it 'updates all nodes that match' do
        sliver = Sliver::Template.new('<b><p>A</p><p>B</p></b>')
        sliver.delete('p')
        sliver.render.should match(%r+<b>\s*</b>+)
      end

      it 'is chainable' do
        @sliver.delete('.link').render.should match(%r+</h1>\s*<pre class="LOLCAT">+)
      end
    end

    context '#empty' do
      it 'empties out the requested element' do
        @sliver.render.should match(/Click/)
        @sliver.empty('.link')
        @sliver.render.should match(%r+<a class="link" href="/wtf">\s*</a>+)
      end

      it 'errors out when the selector is not found' do
        lambda { @sliver.empty('INVALID_NODE') }.should raise_error
      end

      it 'allows caller to override "not found" behavior' do
        lambda { @sliver.empty('INVALID_NODE', :silent_failure => true) }.should_not raise_error
      end


      it 'updates all nodes that match' do
        sliver = Sliver::Template.new([:a, [:p, 'A'], [:p, 'B']])
        sliver.empty('p')
        sliver.render.should match(%r+<a><p></p>\s*<p></p></a>+)
      end

      it 'is chainable' do
        @sliver.empty('.link').render.should match(%r+<a class="link" href="/wtf"></a>+)
      end
    end

    context '#set_attributes' do
      it 'sets the attribute of the requested element' do
        @sliver.set_attributes('.link', {:href => '/disco'})
        @sliver.render.should match(%r+<a class="link" href="/disco">Click Me!</a>+)
      end

      it 'adds an attribute to the requested element' do
        @sliver.set_attributes('.link', {:toot => 'suite'})
        @sliver.render.should match(%r+<a class="link" href="/wtf" toot="suite">Click Me!</a>+)
      end

      it 'errors out when the selector is not found' do
        lambda { @sliver.set_attributes('INVALID_NODE', {:toot => 'suite'}) }.should raise_error
      end

      it 'allows caller to override "not found" behavior' do
        lambda { @sliver.set_attributes('INVALID_NODE', {:toot => 'suite'}, :silent_failure => true) }.should_not raise_error
      end

      it 'sets multiple attributes' do
        @sliver.set_attributes('.link', { :href => '/disco', :toot => 'suite', :class => :baz, :foo => 'bar' })
        rendered = @sliver.render
        rendered.should match(%r+<a .*class="baz".*>Click Me!</a>+)
        rendered.should match(%r+<a .*href="/disco".*>Click Me!</a>+)
        rendered.should match(%r+<a .*foo="bar".*>Click Me!</a>+)
        rendered.should match(%r+<a .*toot="suite".*>Click Me!</a>+)
      end

      it 'updates all nodes that match' do
        sliver = Sliver::Template.new('<p>A</p><p>B</p>')
        sliver.set_attributes('p', { :herp => 'derp' })
        sliver.render.should match(%r+<p herp="derp">A</p>\s*<p herp="derp">B</p>+)
      end

      it 'is chainable' do
        @sliver.set_attributes('.link', {:a => 'b'}).render.should match(%r+a="b"+)
      end
    end

    context '#set_class' do
      it 'sets the attribute of the requested element' do
        @sliver.set_class('.link', 'lunk')
        @sliver.render.should match(%r+<a class="lunk" href="/wtf">Click Me!</a>+)
      end

      it 'errors out when the selector is not found' do
        lambda{ @sliver.set_class('INVALID_NODE', 'lunk') }.should raise_error
      end

      it 'allows caller to override "not found" behavior' do
        lambda{ @sliver.set_class('INVALID_NODE', 'lunk', :silent_failure => true) }.should_not raise_error
      end

      it 'updates all nodes that match' do
        sliver = Sliver::Template.new('<p>A</p><p>B</p>')
        sliver.set_class('p', 'aaa')
        sliver.render.should match(%r+<p class="aaa">A</p>\s*<p class="aaa">B</p>+)
      end

      it 'is chainable' do
        @sliver.set_class('.link', 'b').render.should match(%r+class="b"+)
      end
    end

    context '#list' do
      it 'creates a sub from the first element of the selector'
      it 'is chainable'
      it 'updates all nodes that match'
      it 'errors out when the selector is not found'
      it 'allows caller to override "not found" behavior'
      it 'requires a block'
      it 'does not leave the original content in the selector'
      it 'runs the block for each data item provided'
      it 'uses a fresh copy of the sub for each data element'
    end

    context 'loading partial template from external file'
  end
end
