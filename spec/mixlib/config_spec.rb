#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

class ConfigIt
  extend ::Mixlib::Config
end


describe Mixlib::Config do
  before(:each) do
    ConfigIt.configure do |c|
      c[:alpha] = 'omega'
      c[:foo] = nil
    end
  end

  it "should load a config file" do
    File.stub(:exists?).and_return(true)
    File.stub(:readable?).and_return(true)
    IO.stub(:read).with('config.rb').and_return("alpha = 'omega'\nfoo = 'bar'")
    lambda {
      ConfigIt.from_file('config.rb')
    }.should_not raise_error
  end

  it "should not raise an ArgumentError with an explanation if you try and set a non-existent variable" do
    lambda {
      ConfigIt[:foobar] = "blah"
    }.should_not raise_error
  end

  it "should raise an Errno::ENOENT if it can't find the file" do
    lambda {
      ConfigIt.from_file("/tmp/timmytimmytimmy")
    }.should raise_error(Errno::ENOENT)
  end

  it "should allow the error to bubble up when it's anything other than IOError" do
    IO.stub(:read).with('config.rb').and_return("@#asdf")
    lambda {
      ConfigIt.from_file('config.rb')
    }.should raise_error(SyntaxError)
  end

  it "should allow you to reference a value by index" do
    ConfigIt[:alpha].should == 'omega'
  end

  it "should allow you to reference a value by string index" do
    ConfigIt['alpha'].should == 'omega'
  end

  it "should allow you to set a value by index" do
    ConfigIt[:alpha] = "one"
    ConfigIt[:alpha].should == "one"
  end

  it "should allow you to set a value by string index" do
    ConfigIt['alpha'] = "one"
    ConfigIt[:alpha].should == "one"
  end

  it "should allow setting a value with attribute form" do
    ConfigIt.arbitrary_value = 50
    ConfigIt.arbitrary_value.should == 50
    ConfigIt[:arbitrary_value].should == 50
  end

  it "should allow setting a value with method form" do
    ConfigIt.arbitrary_value 50
    ConfigIt.arbitrary_value.should == 50
    ConfigIt[:arbitrary_value].should == 50
  end

  describe "when strict mode is on" do
    class StrictClass
      extend ::Mixlib::Config
      config_strict_mode true
      default :x, 1
    end

    it "allows you to get and set configured values" do
      StrictClass.x = StrictClass.x * 2
      StrictClass[:x] = StrictClass[:x] * 2
    end

    it "raises an error when you get an arbitrary config option with .y" do
      lambda { StrictClass.y }.should raise_error(Mixlib::Config::UnknownConfigOptionError)
    end

    it "raises an error when you get an arbitrary config option with [:y]" do
      lambda { StrictClass[:y] }.should raise_error(Mixlib::Config::UnknownConfigOptionError)
    end

    it "raises an error when you set an arbitrary config option with .y = 10" do
      lambda { StrictClass.y = 10 }.should raise_error(Mixlib::Config::UnknownConfigOptionError)
    end

    it "raises an error when you get an arbitrary config option with .y 10" do
      lambda { StrictClass.y 10 }.should raise_error(Mixlib::Config::UnknownConfigOptionError)
    end

    it "raises an error when you get an arbitrary config option with [:y] = 10" do
      lambda { StrictClass[:y] = 10 }.should raise_error(Mixlib::Config::UnknownConfigOptionError)
    end
  end

  describe "when a block has been used to set config values" do
    before do
      ConfigIt.configure { |c| c[:cookbook_path] = "monkey_rabbit"; c[:otherthing] = "boo" }
    end

    {:cookbook_path => "monkey_rabbit", :otherthing => "boo"}.each do |k,v|
      it "should allow you to retrieve the config value for #{k} via []" do
        ConfigIt[k].should == v
      end
      it "should allow you to retrieve the config value for #{k} via method_missing" do
        ConfigIt.send(k).should == v
      end
    end
  end

  it "should not raise an ArgumentError if you access a config option that does not exist" do
    lambda { ConfigIt[:snob_hobbery] }.should_not raise_error
  end

  it "should return true or false with has_key?" do
    ConfigIt.has_key?(:monkey).should eql(false)
    ConfigIt[:monkey] = "gotcha"
    ConfigIt.has_key?(:monkey).should eql(true)
  end

  describe "when a class method override writer exists" do
    before do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        config_attr_writer :test_method do |blah|
          blah.is_a?(Integer) ? blah * 1000 : blah
        end
      end
    end

    it "should multiply an integer by 1000" do
      @klass[:test_method] = 53
      @klass[:test_method].should == 53000
    end

    it "should multiply an integer by 1000 with the method_missing form" do
      @klass.test_method = 63
      @klass.test_method.should == 63000
    end

    it "should multiply an integer by 1000 with the instance_eval DSL form" do
      @klass.instance_eval("test_method 73")
      @klass.test_method.should == 73000
    end

    it "should multiply an integer by 1000 via from-file, too" do
      IO.stub(:read).with('config.rb').and_return("test_method 99")
      @klass.from_file('config.rb')
      @klass.test_method.should == 99000
    end

    it "should receive internal_set with the method name and config value" do
      @klass.should_receive(:internal_set).with(:test_method, 53).and_return(true)
      @klass[:test_method] = 53
    end

  end

  describe "When a configurable exists" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        configurable :daemonizeme
        default :a, 1
        config_attr_writer(:b) { |v| v }
        config_context(:c)
      end
    end

    it "Getter methods are created for the configurable" do
      @klass.respond_to?(:daemonizeme).should == true
      @klass.respond_to?(:a).should == true
      @klass.respond_to?(:b).should == true
      @klass.respond_to?(:c).should == true
      @klass.respond_to?(:z).should == false
    end

    it "Setter methods are created for the configurable" do
      @klass.respond_to?("daemonizeme=".to_sym).should == true
      @klass.respond_to?("a=".to_sym).should == true
      @klass.respond_to?("b=".to_sym).should == true
      @klass.respond_to?("c=".to_sym).should == true
      @klass.respond_to?("z=".to_sym).should == false
    end

    describe "and extra methods have been dumped into Object" do
      class NopeError < StandardError
      end
      before :each do
        Object.send :define_method, :daemonizeme do
          raise NopeError, "NOPE"
        end
        Object.send :define_method, "daemonizeme=".to_sym do
          raise NopeError, "NOPE"
        end
      end
      
      it 'Normal classes call the extra method' do
        normal_class = Class.new
        normal_class.extend(::Mixlib::Config)
        lambda { normal_class.daemonizeme }.should raise_error(NopeError)
      end

      it 'Configurables with the same name as the extra method can be set' do
        @klass.daemonizeme = 10
        @klass[:daemonizeme].should == 10
      end

      it 'Configurables with the same name as the extra method can be retrieved' do
        @klass[:daemonizeme] = 10
        @klass.daemonizeme.should == 10
      end
    end
  end

  describe "When config has a default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval { default :attr, 4 }
    end

    it "should default to that value" do
      @klass.attr.should == 4
    end

    it "should default to that value when retrieved as a hash" do
      @klass[:attr].should == 4
    end

    it "should be settable to another value" do
      @klass.attr 5
      @klass.attr.should == 5
    end

    it "should still default to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      @klass.attr.should == 4
    end

    it "should still default to that value after reset" do
      @klass.attr 5
      @klass.reset
      @klass.attr.should == 4
    end
  end

  describe "When config has a default value block" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        default :x, 4
        default(:attr) { x*2}
      end
    end

    it "should default to that value" do
      @klass.attr.should == 8
    end

    it "should be recalculated each time it is retrieved" do
      @klass.attr.should == 8
      @klass.x = 2
      @klass.attr.should == 4
    end

    it "should default to that value when retrieved as a hash" do
      @klass[:attr].should == 8
    end

    it "should be settable to another value" do
      @klass.attr 5
      @klass.attr.should == 5
    end

    it "should still default to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      @klass.attr.should == 8
    end

    it "should still default to that value after reset" do
      @klass.attr 5
      @klass.reset
      @klass.attr.should == 8
    end
  end

  describe "When config has an array default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval { default :attr, [] }
    end

    it "reset clears it to its default" do
      @klass.attr << 'x'
      @klass.attr.should == [ 'x' ]
      @klass.reset
      @klass.attr.should == []
    end
  end

  describe "When config has a hash default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval { default :attr, {} }
    end

    it "reset clears it to its default" do
      @klass.attr[:x] = 10
      @klass.attr[:x].should == 10
      @klass.reset
      @klass.attr[:x].should == nil
    end
  end

  describe "When config has a string default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval { default :attr, 'hello' }
    end

    it "reset clears it to its default" do
      @klass.attr << ' world'
      @klass.attr.should == 'hello world'
      @klass.reset
      @klass.attr.should == 'hello'
    end
  end

  describe "When config has a a default value block" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        default(:attr) { 4 }
      end
    end

    it "should default to that value" do
      @klass.attr.should == 4
    end

    it "should default to that value when retrieved as a hash" do
      @klass[:attr].should == 4
    end

    it "should be settable to another value" do
      @klass.attr 5
      @klass.attr.should == 5
      @klass[:attr].should == 5
    end

    it "should still default to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      @klass.attr.should == 4
    end

    it "should still default to that value after reset" do
      @klass.attr 5
      @klass.reset
      @klass.attr.should == 4
    end
  end

  describe "When a configurable exists with writer and default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        configurable(:attr) do |c|
          c.defaults_to(4)
          c.writes_value { |value| value*2 }
        end
      end
    end

    it "should default to that value" do
      @klass.attr.should == 4
    end

    it "should default to that value when retrieved as a hash" do
      @klass[:attr].should == 4
    end

    it "should be settable to another value" do
      @klass.attr 5
      @klass.attr.should == 10
      @klass[:attr].should == 10
    end

    it "should be settable to another value with attr=" do
      @klass.attr = 5
      @klass.attr.should == 10
      @klass[:attr].should == 10
    end

    it "should be settable to another value with [:attr]=" do
      @klass[:attr] = 5
      @klass.attr.should == 10
      @klass[:attr].should == 10
    end

    it "should still default to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      @klass.attr.should == 4
    end

    it "should still default to that value after reset" do
      @klass.attr 5
      @klass.reset
      @klass.attr.should == 4
    end
  end

  describe "When a configurable exists with writer and default value set in chained form" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        configurable(:attr).defaults_to(4).writes_value { |value| value*2 }
      end
    end

    it "should default to that value" do
      @klass.attr.should == 4
    end

    it "should default to that value when retrieved as a hash" do
      @klass[:attr].should == 4
    end

    it "should be settable to another value" do
      @klass.attr 5
      @klass.attr.should == 10
      @klass[:attr].should == 10
    end

    it "should be settable to another value with attr=" do
      @klass.attr = 5
      @klass.attr.should == 10
      @klass[:attr].should == 10
    end

    it "should be settable to another value with [:attr]=" do
      @klass[:attr] = 5
      @klass.attr.should == 10
      @klass[:attr].should == 10
    end

    it "should still default to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      @klass.attr.should == 4
    end

    it "should still default to that value after reset" do
      @klass.attr 5
      @klass.reset
      @klass.attr.should == 4
    end
  end

  describe "When a configurable exists with a context" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        configurable :x
        config_context(:blah) do
          default :x, 5
        end
      end
    end

    it "configurable defaults in that context work" do
      @klass.blah.x.should == 5
    end

    it "after setting values in the context, the values remain set" do
      @klass.blah.x = 10
      @klass.blah.x.should == 10
    end

    it "setting values with the same name in the parent context do not affect the child context" do
      @klass.x = 10
      @klass.x.should == 10
      @klass.blah.x.should == 5
    end

    it "after reset of the parent class, children are reset" do
      @klass.blah.x = 10
      @klass.blah.x.should == 10
      @klass.reset
      @klass.blah.x.should == 5
    end
  end

  describe "When a configurable exists with a nested context" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        config_context(:blah) do
          config_context(:yarr) do
            default :x, 5
          end
        end
        configurable :x
      end
    end

    it "configurable defaults in that context work" do
      @klass.blah.yarr.x.should == 5
    end

    it "after setting values in the context, the values remain set" do
      @klass.blah.yarr.x = 10
      @klass.blah.yarr.x.should == 10
    end

    it "setting values with the same name in the parent context do not affect the child context" do
      @klass.x = 10
      @klass.x.should == 10
      @klass.blah.yarr.x.should == 5
    end

    it "after reset of the parent class, children are reset" do
      @klass.blah.yarr.x = 10
      @klass.blah.yarr.x.should == 10
      @klass.reset
      @klass.blah.yarr.x.should == 5
    end
  end

  describe "When a nested context has strict mode on" do
    class StrictClass2
      extend ::Mixlib::Config
      config_context :c do
        config_strict_mode true
        default :x, 1
      end
    end

    it "The parent class allows you to set arbitrary config options" do
      StrictClass2.y = 10
    end

    it "The nested class does not allow you to set arbitrary config options" do
      lambda { StrictClass2.c.y = 10 }.should raise_error(Mixlib::Config::UnknownConfigOptionError)
    end
  end

  describe "When strict mode is on but a nested context has strict mode unspecified" do
    class StrictClass3
      extend ::Mixlib::Config
      config_strict_mode true
      default :x, 1
      config_context :c
    end

    it "The parent class does not allow you to set arbitrary config options" do
      lambda { StrictClass3.y = 10 }.should raise_error(Mixlib::Config::UnknownConfigOptionError)
    end

    it "The nested class does not allow you to set arbitrary config options" do
      lambda { StrictClass3.y = 10 }.should raise_error(Mixlib::Config::UnknownConfigOptionError)
    end
  end
end
