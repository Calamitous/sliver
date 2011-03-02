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
    context "#change" do
      it "replaces the contents of the requested element" do
        @sliver.change('.link', 'Go to Home')
        @sliver.render.should match(%r+<a class="link" href="/wtf">Go to Home</a>+)
      end

      it "automatically converts monkey arrays" do
        @sliver.change('.link', [:p, 'pop'])
        @sliver.render.should match(%r+<a class="link" href="/wtf"><p>pop</p></a>+)
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
    end

    context "#delete" do
      it "removes the requested element" do
        @sliver.render.should match(/Click/)
        @sliver.delete('.link')
        @sliver.render.should_not match(/Click/)
      end
    end

    context "#empty" do
      it "empties out the requested element" do
        @sliver.render.should match(/Click/)
        @sliver.empty('.link')
        @sliver.render.should match(%r+<a class="link" href="/wtf">\s*</a>+)
      end
    end

    context "loading partial template from external file"
    context "loading partial template from inline div"
  end
end
