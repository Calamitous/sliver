require 'rubygems'
require 'rspec/autorun'
require File.expand_path('../../lib/sliver', __FILE__)

describe "monkey patches" do
  context "while entagging data" do
    it "entags a tag array" do
      data = [[:a]]
      data.to_html.should == '<a />'
    end

    it "entags multiple arrays" do
      data = [[[:a], [:b]]]
      data.to_html.should == '<a /><b />'
    end

    it "entags nested tag arrays" do
      data = [[:a, [:b]]]
      data.to_html.should == '<a><b /></a>'
    end

    it "entags nested multiple tag arrays" do
      data = [[[:a, [:b]], [:c, [:d]]]]
      data.to_html.should == '<a><b /></a><c><d /></c>'
    end

    it "entags nested arrays to an arbitrary depth" do
      data = [[:a, [:b, [:c, [:d]]]]]
      data.to_html.should == '<a><b><c><d /></c></b></a>'
    end

    it "entags nested arrays including static text" do
      # hmmm, what should be the preferred usage...
      # [:p, "Test", [:a, {:href => '/wut'}, "this"], "baby"] 
      # or
      # [:p, "Test #{[:a, {:href => '/wut'}, "this"].to_html} baby"] 
      data = [[:a, [:b, "NO WAI", [:c, [:d, "LOLWUT"]]]]]
      # data.to_html.should == '<a><b>NO WAI<c><d>LOLWUT</d></c></b></a>'
    end

    it "ignores empty nesting" do
      data = [[:a, [[[:b]]], [:c]]]
      data.to_html.should == '<a><b /><c /></a>'
    end

    it "raises an error if a tag is not correctly wrapped" do
      data = [[:a], :c]
      lambda { data.to_html }.should raise_error(":c is not a valid tag array.  Did you mean [:c]?")
    end

    it "renders static text" do
      data = [:p, "this thing"]
      data.to_html.should == '<p>this thing</p>'
    end

    context "with properties" do
      it "entags a tag array" do
        data = [[:a, {:foo => :bar}]]
        data.to_html.should == '<a foo="bar" />'
      end

      it "renders static text" do
        data = [:p, {:class => 'test'},  "this thing"]
        data.to_html.should == '<p class="test">this thing</p>'
      end

      it "entags properties around interleaved tag arrays" do
        data = [[:a, [:b], {:foo => :bar}]]
        data.to_html.should == '<a foo="bar"><b /></a>'
      end

      it "collects multiple hashes in to a single list of properties" do
        data = [[:a, {:foo => :bar}, {:baz => 'quux!'}]]
        data.to_html.should match(/baz="quux!"/)
        data.to_html.should match(/foo="bar"/)
      end

      it "overrides properties which have already been defined to the left" do
        data = [[:a, {:foo => :bar}, {:foo => 'quux!'}]]
        data.to_html.should == '<a foo="quux!" />'
      end

      it "entags nested arrays" do
        data = [[:a, [:b, {:lol => 'wut'}]]]
        data.to_html.should == '<a><b lol="wut" /></a>'
      end

      it "entags nested multiple tag arrays" do
        data = [[[:a, [:b, {:lol => 'wut'}]], [:c, [:d, {:no => 'wai'}]]]]
        data.to_html.should == '<a><b lol="wut" /></a><c><d no="wai" /></c>'
      end
    end
  end
end
