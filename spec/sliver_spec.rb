require 'rubygems'
require 'rspec/autorun'
require File.expand_path('../../lib/sliver', __FILE__)

describe "Sliver" do
  context "rendering" do
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
      @sliver = Sliver.new(@template)
    end

    context '#new' do
      it "sets the doc value" do
        Sliver.new('<br />').doc.should_not be_nil
      end

      it "automatically converts monkey arrays" do
        Sliver.new([:c, [:p, 'A'], [:p, 'B']]).render.should match(%r+<c><p>A</p>\s*<p>B</p></c>+)
      end
    end

    context "#change" do
      it "replaces the contents of the requested element" do
        @sliver.change('.link', 'Go to Home')
        @sliver.render.should match(%r+<a class="link" href="/wtf">Go to Home</a>+)
      end

      it "automatically converts monkey arrays" do
        @sliver.change('.link', [:p, 'pop'])
        @sliver.render.should match(%r+<a class="link" href="/wtf"><p>pop</p></a>+)
      end

      it "is chainable" do
        @sliver.change('#list', [:b, 'Stuff']).render.should match(%r+<div id="list"><b>Stuff</b></div>+)
      end

      it "updates all nodes that match" do
        sliver = Sliver.new('<p>A</p><p>B</p>')
        sliver.change('p', 'C')
        sliver.render.should match(%r+<p>C</p>\s*<p>C</p>+)
      end
    end

    context "#add_into" do
      it "appends to the contents of the requested element" do
        @sliver.add_into('.link', " Please!")
        @sliver.render.should match(%r+<a class="link" href="/wtf">Click Me! Please!</a>+)
      end

      it "automatically converts monkey arrays" do
        @sliver.add_into('#list', [:p, "less text"])
        @sliver.render.should match(%r+<p>MORE text</p>\s*<p>less text</p>+)
      end

      it "is chainable" do
        @sliver.add_into('.link', 'Hi').render.should match(%r+href="/wtf">Click Me!Hi</a>+)
      end

      it "updates all nodes that match" do
        sliver = Sliver.new('<p>A</p><p>B</p>')
        sliver.add_into('p', 'C')
        sliver.render.should match(%r+<p>AC</p>\s*<p>BC</p>+)
      end
    end

    context "#insert_into" do
      it "inserts contents of the requested element" do
        @sliver.insert_into('.link', "Please! ")
        @sliver.render.should match(%r+<a class="link" href="/wtf">Please! Click Me!</a>+)
      end

      it "automatically converts monkey arrays" do
        @sliver.insert_into('#list', [:p, "less text"])
        @sliver.render.should match(%r+<p>less text</p>\s*<p>Some text</p>+)
      end

      it "is chainable" do
        @sliver.insert_into('.link', 'Hi').render.should match(%r+href="/wtf">HiClick Me!</a>+)
      end

      it "updates all nodes that match" do
        sliver = Sliver.new('<p>A</p><p>B</p>')
        sliver.insert_into('p', 'C')
        sliver.render.should match(%r+<p>CA</p>\s*<p>CB</p>+)
      end
    end

    context "#delete" do
      it "removes the requested element" do
        @sliver.render.should match(/Click/)
        @sliver.delete('.link')
        @sliver.render.should_not match(/Click/)
      end

      it "updates all nodes that match" do
        sliver = Sliver.new('<b><p>A</p><p>B</p></b>')
        sliver.delete('p')
        sliver.render.should match(%r+<b>\s*</b>+)
      end

      it "is chainable" do
        @sliver.delete('.link').render.should match(%r+</h1>\s*<pre class="LOLCAT">+)
      end
    end

    context "#empty" do
      it "empties out the requested element" do
        @sliver.render.should match(/Click/)
        @sliver.empty('.link')
        @sliver.render.should match(%r+<a class="link" href="/wtf">\s*</a>+)
      end

      it "updates all nodes that match" do
        sliver = Sliver.new([:a, [:p, 'A'], [:p, 'B']])
        sliver.empty('p')
        sliver.render.should match(%r+<a><p></p>\s*<p></p></a>+)
      end

      it "is chainable" do
        @sliver.empty('.link').render.should match(%r+<a class="link" href="/wtf"></a>+)
      end
    end

    context "loading partial template from external file"
    context "loading partial template from inline div"
  end
end
