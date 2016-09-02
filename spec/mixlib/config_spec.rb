#
# Author:: Adam Jacob (<adam@chef.io>)
# Copyright:: Copyright (c) 2008-2016 Chef Software, Inc.
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

describe Mixlib::Config do
  before(:each) do
    ConfigIt.configure do |c|
      c[:alpha] = "omega"
      c[:foo] = nil
    end
  end

  it "loads a config file" do
    allow(File).to receive(:exists?).and_return(true)
    allow(File).to receive(:readable?).and_return(true)
    allow(IO).to receive(:read).with("config.rb").and_return("alpha = 'omega'\nfoo = 'bar'")
    expect(lambda {
      ConfigIt.from_file("config.rb")
    }).to_not raise_error
  end

  it "doesn't raise an ArgumentError with an explanation if you try and set a non-existent variable" do
    expect(lambda {
      ConfigIt[:foobar] = "blah"
    }).to_not raise_error
  end

  it "raises an Errno::ENOENT if it can't find the file" do
    expect(lambda {
      ConfigIt.from_file("/tmp/timmytimmytimmy")
    }).to raise_error(Errno::ENOENT)
  end

  it "allows the error to bubble up when it's anything other than IOError" do
    allow(IO).to receive(:read).with("config.rb").and_return("@#asdf")
    expect(lambda {
      ConfigIt.from_file("config.rb")
    }).to raise_error(SyntaxError)
  end

  it "allows you to reference a value by index" do
    expect(ConfigIt[:alpha]).to eql("omega")
  end

  it "allows you to reference a value by string index" do
    expect(ConfigIt["alpha"]).to eql("omega")
  end

  it "allows you to set a value by index" do
    ConfigIt[:alpha] = "one"
    expect(ConfigIt[:alpha]).to eql("one")
  end

  it "allows you to set a value by string index" do
    ConfigIt["alpha"] = "one"
    expect(ConfigIt[:alpha]).to eql("one")
  end

  it "allows setting a value with attribute form" do
    ConfigIt.arbitrary_value = 50
    expect(ConfigIt.arbitrary_value).to eql(50)
    expect(ConfigIt[:arbitrary_value]).to eql(50)
  end

  it "allows setting a value with method form" do
    ConfigIt.arbitrary_value 50
    expect(ConfigIt.arbitrary_value).to eql(50)
    expect(ConfigIt[:arbitrary_value]).to eql(50)
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
      expect(lambda { StrictClass.y }).to raise_error(Mixlib::Config::UnknownConfigOptionError, "Reading unsupported config value y.")
    end

    it "raises an error when you get an arbitrary config option with [:y]" do
      expect(lambda { StrictClass[:y] }).to raise_error(Mixlib::Config::UnknownConfigOptionError, "Reading unsupported config value y.")
    end

    it "raises an error when you set an arbitrary config option with .y = 10" do
      expect(lambda { StrictClass.y = 10 }).to raise_error(Mixlib::Config::UnknownConfigOptionError, "Cannot set unsupported config value y.")
    end

    it "raises an error when you set an arbitrary config option with .y 10" do
      expect(lambda { StrictClass.y 10 }).to raise_error(Mixlib::Config::UnknownConfigOptionError, "Cannot set unsupported config value y.")
    end

    it "raises an error when you set an arbitrary config option with [:y] = 10" do
      expect(lambda { StrictClass[:y] = 10 }).to raise_error(Mixlib::Config::UnknownConfigOptionError, "Cannot set unsupported config value y.")
    end
  end

  describe "when a block has been used to set config values" do
    before do
      ConfigIt.configure { |c| c[:cookbook_path] = "monkey_rabbit"; c[:otherthing] = "boo" }
    end

    { :cookbook_path => "monkey_rabbit", :otherthing => "boo" }.each do |k, v|
      it "allows you to retrieve the config value for #{k} via []" do
        expect(ConfigIt[k]).to eql(v)
      end
      it "allows you to retrieve the config value for #{k} via method_missing" do
        expect(ConfigIt.send(k)).to eql(v)
      end
    end
  end

  it "doesn't raise an ArgumentError if you access a config option that does not exist" do
    expect(lambda { ConfigIt[:snob_hobbery] }).to_not raise_error
  end

  it "returns true or false with has_key?" do
    expect(ConfigIt.has_key?(:monkey)).to be false
    ConfigIt[:monkey] = "gotcha"
    expect(ConfigIt.has_key?(:monkey)).to be true
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

    it "multiplies an integer by 1000" do
      @klass[:test_method] = 53
      expect(@klass[:test_method]).to eql(53000)
    end

    it "multiplies an integer by 1000 with the method_missing form" do
      @klass.test_method = 63
      expect(@klass.test_method).to eql(63000)
    end

    it "multiplies an integer by 1000 with the instance_eval DSL form" do
      @klass.instance_eval("test_method 73")
      expect(@klass.test_method).to eql(73000)
    end

    it "multiplies an integer by 1000 via from-file, too" do
      allow(IO).to receive(:read).with("config.rb").and_return("test_method 99")
      @klass.from_file("config.rb")
      expect(@klass.test_method).to eql(99000)
    end

    it "receives internal_set with the method name and config value" do
      expect(@klass).to receive(:internal_set).with(:test_method, 53).and_return(true)
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
      expect(@klass.respond_to?(:daemonizeme)).to be true
      expect(@klass.respond_to?(:a)).to be true
      expect(@klass.respond_to?(:b)).to be true
      expect(@klass.respond_to?(:c)).to be true
      expect(@klass.respond_to?(:z)).to be false
    end

    it "Setter methods are created for the configurable" do
      expect(@klass.respond_to?("daemonizeme=".to_sym)).to be true
      expect(@klass.respond_to?("a=".to_sym)).to be true
      expect(@klass.respond_to?("b=".to_sym)).to be true
      expect(@klass.respond_to?("c=".to_sym)).to be true
      expect(@klass.respond_to?("z=".to_sym)).to be false
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

      after do
        Object.send :remove_method, :daemonizeme
        Object.send :remove_method, :'daemonizeme='
      end

      it "Normal classes call the extra method" do
        normal_class = Class.new
        normal_class.extend(::Mixlib::Config)
        expect(lambda { normal_class.daemonizeme }).to raise_error(NopeError)
      end

      it "Configurables with the same name as the extra method can be set" do
        @klass.daemonizeme = 10
        expect(@klass[:daemonizeme]).to eql(10)
      end

      it "Configurables with the same name as the extra method can be retrieved" do
        @klass[:daemonizeme] = 10
        expect(@klass.daemonizeme).to eql(10)
      end
    end
  end

  describe "When config has a default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval { default :attr, 4 }
    end

    it "defaults to that value" do
      expect(@klass.attr).to eql(4)
    end

    it "defaults to that value when retrieved as a hash" do
      expect(@klass[:attr]).to eql(4)
    end

    it "is settable to another value" do
      @klass.attr 5
      expect(@klass.attr).to eql(5)
    end

    it "still defaults to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      expect(@klass.attr).to eql(4)
    end

    it "still defaults to that value after reset" do
      @klass.attr 5
      @klass.reset
      expect(@klass.attr).to eql(4)
    end

    it "save should not save anything for it" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :attr => 4 })
    end

    it "saves the new value if it gets set" do
      @klass.attr 5
      expect((saved = @klass.save)).to eql({ :attr => 5 })
      @klass.reset
      expect(@klass.attr).to eql(4)
      @klass.restore(saved)
      expect(@klass.attr).to eql(5)
    end

    it "saves the new value even if it is set to its default value" do
      @klass.attr 4
      expect((saved = @klass.save)).to eql({ :attr => 4 })
      @klass.reset
      expect(@klass.save).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => 4 })
    end
  end

  describe "When config has a default value block" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        default :x, 4
        default(:attr) { x * 2 }
      end
    end

    it "defaults to that value" do
      expect(@klass.attr).to eql(8)
    end

    it "is recalculated each time it is retrieved" do
      expect(@klass.attr).to eql(8)
      @klass.x = 2
      expect(@klass.attr).to eql(4)
    end

    it "defaults to that value when retrieved as a hash" do
      expect(@klass[:attr]).to eql(8)
    end

    it "is settable to another value" do
      @klass.attr 5
      expect(@klass.attr).to eql(5)
    end

    it "still defaults to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      expect(@klass.attr).to eql(8)
    end

    it "still defaults to that value after reset" do
      @klass.attr 5
      @klass.reset
      expect(@klass.attr).to eql(8)
    end

    it "save should not save anything for it" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :attr => 8, :x => 4 })
    end

    it "saves the new value if it gets set" do
      @klass.attr 5
      expect((saved = @klass.save)).to eql({ :attr => 5 })
      @klass.reset
      expect(@klass.attr).to eql(8)
      @klass.restore(saved)
      expect(@klass.attr).to eql(5)
    end

    it "saves the new value even if it is set to its default value" do
      @klass.attr 8
      expect((saved = @klass.save)).to eql({ :attr => 8 })
      @klass.reset
      expect(@klass.save).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => 8 })
    end
  end

  describe "When config has an array default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval { default :attr, [] }
    end

    it "reset clears it to its default" do
      @klass.attr << "x"
      expect(@klass.attr).to eql([ "x" ])
      @klass.reset
      expect(@klass.attr).to eql([])
    end

    it "save should not save anything for it" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :attr => [] })
    end

    it "saves the new value if it gets set" do
      @klass.attr << "x"
      expect((saved = @klass.save)).to eql({ :attr => [ "x" ] })
      @klass.reset
      expect(@klass.attr).to eql([])
      @klass.restore(saved)
      expect(@klass.attr).to eql([ "x" ])
    end

    it "saves the new value even if it is set to its default value" do
      @klass.attr = []
      expect((saved = @klass.save)).to eql({ :attr => [] })
      @klass.reset
      expect(@klass.save).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => [] })
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
      expect(@klass.attr[:x]).to eql(10)
      @klass.reset
      expect(@klass.attr[:x]).to be_nil
    end

    it "save should not save anything for it" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :attr => {} })
    end

    it "saves the new value if it gets set" do
      @klass.attr[:hi] = "lo"
      expect((saved = @klass.save)).to eql({ :attr => { :hi => "lo" } })
      @klass.reset
      expect(@klass.attr).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => { :hi => "lo" } })
    end

    it "saves the new value even if it is set to its default value" do
      @klass.attr = {}
      expect((saved = @klass.save)).to eql({ :attr => {} })
      @klass.reset
      expect(@klass.save).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => {} })
    end
  end

  describe "When config has a string default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval { default :attr, "hello" }
    end

    it "reset clears it to its default" do
      @klass.attr << " world"
      expect(@klass.attr).to eql("hello world")
      @klass.reset
      expect(@klass.attr).to eql("hello")
    end

    it "save should not save anything for it" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :attr => "hello" })
    end

    it "saves the new value if it gets set" do
      @klass.attr << " world"
      expect((saved = @klass.save)).to eql({ :attr => "hello world" })
      @klass.reset
      expect(@klass.attr).to eql("hello")
      @klass.restore(saved)
      expect(@klass.attr).to eql("hello world")
    end

    it "saves the new value even if it is set to its default value" do
      @klass.attr "hello world"
      expect((saved = @klass.save)).to eql({ :attr => "hello world" })
      @klass.reset
      expect(@klass.save).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => "hello world" })
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

    it "defaults to that value" do
      expect(@klass.attr).to eql(4)
    end

    it "defaults to that value when retrieved as a hash" do
      expect(@klass[:attr]).to eql(4)
    end

    it "is settable to another value" do
      @klass.attr 5
      expect(@klass.attr).to eql(5)
      expect(@klass[:attr]).to eql(5)
    end

    it "still defaults to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      expect(@klass.attr).to eql(4)
    end

    it "still defaults to that value after reset" do
      @klass.attr 5
      @klass.reset
      expect(@klass.attr).to eql(4)
    end

    it "save should not save anything for it" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :attr => 4 })
    end

    it "saves the new value if it gets set" do
      @klass.attr 5
      expect((saved = @klass.save)).to eql({ :attr => 5 })
      @klass.reset
      expect(@klass.attr).to eql(4)
      @klass.restore(saved)
      expect(@klass.attr).to eql(5)
    end

    it "saves the new value even if it is set to its default value" do
      @klass.attr 4
      expect((saved = @klass.save)).to eql({ :attr => 4 })
      @klass.reset
      expect(@klass.save).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => 4 })
    end
  end

  describe "When a configurable exists with writer and default value" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        configurable(:attr) do |c|
          c.defaults_to(4)
          c.writes_value { |value| value * 2 }
        end
      end
    end

    it "defaults to that value" do
      expect(@klass.attr).to eql(4)
    end

    it "defaults to that value when retrieved as a hash" do
      expect(@klass[:attr]).to eql(4)
    end

    it "is settable to another value" do
      @klass.attr 5
      expect(@klass.attr).to eql(10)
      expect(@klass[:attr]).to eql(10)
    end

    it "is settable to another value with attr=" do
      @klass.attr = 5
      expect(@klass.attr).to eql(10)
      expect(@klass[:attr]).to eql(10)
    end

    it "is settable to another value with [:attr]=" do
      @klass[:attr] = 5
      expect(@klass.attr).to eql(10)
      expect(@klass[:attr]).to eql(10)
    end

    it "still defaults to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      expect(@klass.attr).to eql(4)
    end

    it "still defaults to that value after reset" do
      @klass.attr 5
      @klass.reset
      expect(@klass.attr).to eql(4)
    end

    it "save should not save anything for it" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :attr => 4 })
    end

    it "saves the new value if it gets set" do
      @klass.attr 5
      expect((saved = @klass.save)).to eql({ :attr => 10 })
      @klass.reset
      expect(@klass.attr).to eql(4)
      @klass.restore(saved)
      expect(@klass.attr).to eql(10)
    end

    it "saves the new value even if it is set to its default value" do
      @klass.attr 4
      expect((saved = @klass.save)).to eql({ :attr => 8 })
      @klass.reset
      expect(@klass.save).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => 8 })
    end
  end

  describe "When a configurable exists with writer and default value set in chained form" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        configurable(:attr).defaults_to(4).writes_value { |value| value * 2 }
      end
    end

    it "defaults to that value" do
      expect(@klass.attr).to eql(4)
    end

    it "defaults to that value when retrieved as a hash" do
      expect(@klass[:attr]).to eql(4)
    end

    it "is settable to another value" do
      @klass.attr 5
      expect(@klass.attr).to eql(10)
      expect(@klass[:attr]).to eql(10)
    end

    it "is settable to another value with attr=" do
      @klass.attr = 5
      expect(@klass.attr).to eql(10)
      expect(@klass[:attr]).to eql(10)
    end

    it "is settable to another value with [:attr]=" do
      @klass[:attr] = 5
      expect(@klass.attr).to eql(10)
      expect(@klass[:attr]).to eql(10)
    end

    it "still defaults to that value after delete" do
      @klass.attr 5
      @klass.delete(:attr)
      expect(@klass.attr).to eql(4)
    end

    it "still defaults to that value after reset" do
      @klass.attr 5
      @klass.reset
      expect(@klass.attr).to eql(4)
    end

    it "save should not save anything for it" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :attr => 4 })
    end

    it "saves the new value if it gets set" do
      @klass.attr 5
      expect((saved = @klass.save)).to eql({ :attr => 10 })
      @klass.reset
      expect(@klass.attr).to eql(4)
      @klass.restore(saved)
      expect(@klass.attr).to eql(10)
    end

    it "saves the new value even if it is set to its default value" do
      @klass.attr 2
      expect((saved = @klass.save)).to eql({ :attr => 4 })
      @klass.reset
      expect(@klass.save).to eql({})
      @klass.restore(saved)
      expect(@klass.save).to eql({ :attr => 4 })
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
      expect(@klass.blah.x).to eql(5)
    end

    it "after setting values in the context, the values remain set" do
      @klass.blah.x = 10
      expect(@klass.blah.x).to eql(10)
    end

    it "setting values with the same name in the parent context do not affect the child context" do
      @klass.x = 10
      expect(@klass.x).to eql(10)
      expect(@klass.blah.x).to eql(5)
    end

    it "setting the entire context to a hash with default value overridden sets the value" do
      @klass.blah = { :x => 10 }
      expect(@klass.blah.x).to eql(10)
    end

    it "setting the entire context to a hash sets non-default values" do
      @klass.blah = { :y => 10 }
      expect(@klass.blah.x).to eql(5)
      expect(@klass.blah.y).to eql(10)
    end

    it "setting the entire context to a hash deletes any non-default values and resets default values" do
      @klass.blah.x = 10
      @klass.blah.y = 10
      @klass.blah = { :z => 10 }
      expect(@klass.blah.x).to eql(5)
      expect(@klass.blah.y).to be_nil
      expect(@klass.blah.z).to eql(10)
    end

    it "setting the context values in a block overrides the default values" do
      @klass.blah do
        x 10
        y 20
      end
      @klass.blah.x.should == 10
      @klass.blah.y.should == 20
    end

    it "setting the context values in a yielded block overrides the default values" do
      @klass.blah do |b|
        b.x = 10
        b.y = 20
      end
      @klass.blah.x.should == 10
      @klass.blah.y.should == 20
    end

    it "after reset of the parent class, children are reset" do
      @klass.blah.x = 10
      expect(@klass.blah.x).to eql(10)
      @klass.reset
      expect(@klass.blah.x).to eql(5)
    end

    it "save should not save anything for it by default" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :blah => { :x => 5 } })
    end

    it "saves any new values that are set in the context" do
      @klass.blah.x = 10
      expect((saved = @klass.save)).to eql({ :blah => { :x => 10 } })
      @klass.reset
      expect(@klass.blah.x).to eql(5)
      @klass.restore(saved)
      expect(@klass.blah.x).to eql(10)
      expect(@klass.save).to eql({ :blah => { :x => 10 } })
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
            default :y, 6
          end
        end
        configurable :x
      end
    end

    it "configurable defaults in that context work" do
      expect(@klass.blah.yarr.x).to eql(5)
      expect(@klass.blah.yarr.y).to eql(6)
    end

    it "after setting values in the context, the values remain set" do
      @klass.blah.yarr.x = 10
      @klass.blah.yarr.y = 11
      expect(@klass.blah.yarr.x).to eql(10)
      expect(@klass.blah.yarr.y).to eql(11)
    end

    it "setting values with the same name in the parent context do not affect the child context" do
      @klass.x = 10
      expect(@klass.x).to eql(10)
      expect(@klass.blah.yarr.x).to eql(5)
    end

    it "after reset of the parent class, children are reset" do
      @klass.blah.yarr.x = 10
      @klass.blah.yarr.y = 11
      expect(@klass.blah.yarr.x).to eql(10)
      expect(@klass.blah.yarr.y).to eql(11)
      @klass.reset
      expect(@klass.blah.yarr.x).to eql(5)
      expect(@klass.blah.yarr.y).to eql(6)
    end

    it "save should not save anything for it by default" do
      expect(@klass.save).to eql({})
    end

    it "save with include_defaults should save all defaults" do
      expect(@klass.save(true)).to eql({ :blah => { :yarr => { :x => 5, :y => 6 } } })
    end

    it "saves any new values that are set in the context" do
      @klass.blah.yarr.x = 10
      @klass.blah.yarr.y = 11
      expect((saved = @klass.save)).to eql({ :blah => { :yarr => { :x => 10, :y => 11 } } })
      @klass.reset
      expect(@klass.blah.yarr.x).to eql(5)
      expect(@klass.blah.yarr.y).to eql(6)
      @klass.restore(saved)
      expect(@klass.blah.yarr.x).to eql(10)
      expect(@klass.blah.yarr.y).to eql(11)
      expect(@klass.save).to eql({ :blah => { :yarr => { :x => 10, :y => 11 } } })
    end

    it "restores defaults not included in saved data" do
      @klass.restore( :blah => { :yarr => { :x => 10 } } )
      expect(@klass.blah.yarr.x).to eql(10)
      expect(@klass.blah.yarr.y).to eql(6)
    end

    it "removes added properties not included in saved state" do
      @klass.blah.yarr.z = 12
      @klass.restore( :blah => { :yarr => { :x => 10 } } )
      expect(@klass.blah.yarr.x).to eql(10)
      expect(@klass.blah.yarr.z).to eql(nil)
    end

    it "can set a config context from another context" do
      @klass.blah.blyme = { :x => 7 }
      blyme = @klass.blah.blyme
      @klass.blah.yarr.x = 12
      @klass.blah.yarr = blyme
      expect(@klass.blah.yarr.x).to eql(7)
    end
  end

  describe "When a config_context with no defaulted values exists" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        config_context(:blah) do
          configurable(:x)
        end
      end
    end

    it "save does not save the hash for the config_context" do
      expect(@klass.save).to eql({})
    end

    it "save with defaults saves the hash for the config_context" do
      expect(@klass.save(true)).to eql({ :blah => {} })
    end
  end

  describe "When a config_context with no configurables exists" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        config_context(:blah)
      end
    end

    it "save does not save the hash for the config_context" do
      expect(@klass.save).to eql({})
    end

    it "save with defaults saves the hash for the config_context" do
      expect(@klass.save(true)).to eql({ :blah => {} })
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
      expect(lambda { StrictClass2.c.y = 10 }).to raise_error(Mixlib::Config::UnknownConfigOptionError, "Cannot set unsupported config value y.")
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
      expect(lambda { StrictClass3.y = 10 }).to raise_error(Mixlib::Config::UnknownConfigOptionError, "Cannot set unsupported config value y.")
    end

    it "The nested class does not allow you to set arbitrary config options" do
      expect(lambda { StrictClass3.y = 10 }).to raise_error(Mixlib::Config::UnknownConfigOptionError, "Cannot set unsupported config value y.")
    end
  end

  describe "When a config_context is opened twice" do
    before :each do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval do
        config_context(:blah) do
          default :x, 10
        end
        config_context(:blah) do
          default :y, 20
        end
      end
    end

    it "Both config_context blocks are honored" do
      @klass.blah.x == 10
      @klass.blah.y == 20
    end
  end

  it "When a config_context is opened in place of a regular configurable, an error is raised" do
    klass = Class.new
    klass.extend(::Mixlib::Config)
    expect(lambda do
      klass.class_eval do
        default :blah, 10
        config_context(:blah) do
          default :y, 20
        end
      end
    end).to raise_error(Mixlib::Config::ReopenedConfigurableWithConfigContextError)
  end

  it "When a config_context is opened in place of a regular configurable, an error is raised" do
    klass = Class.new
    klass.extend(::Mixlib::Config)
    expect(lambda do
      klass.class_eval do
        config_context(:blah) do
          default :y, 20
        end
        default :blah, 10
      end
    end).to raise_error(Mixlib::Config::ReopenedConfigContextWithConfigurableError)
  end

end
