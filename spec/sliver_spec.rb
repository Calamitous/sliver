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
              <p>Some test</p>
              <p>MORE txt</p>
            </div>
          </body>
        </html>
TEMPLATE
    end
    context "change" do
      it "replaces the contents of the requested element" do
        sliver = Sliver.new(@template)
        sliver.change('.link', 'Go to Home')
        sliver.render.should match(%r!<a class="link" href="/wtf">Go to Home</a>!)
      end

      it "automatically converts monkey arrays" do
        sliver = Sliver.new(@template)
        sliver.change('.link', [:p, 'pop'])
        sliver.render.should match(%r!<a class="link" href="/wtf"><p>pop</p></a>!)
      end
    end

    context "add" do
      it "appends to the contents of the requested element"
      it "automatically converts monkey arrays"
    end
    context "remove"
    context "loading partial template from external file"
    context "loading partial template from inline div"
  end
end
