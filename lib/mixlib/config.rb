#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
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

require 'mixlib/config/version'
require 'mixlib/config/configurable'
require 'mixlib/config/unknown_config_option_error'

module Mixlib
  module Config
    def self.extended(base)
      class << base; attr_accessor :configuration; end
      class << base; attr_accessor :configurables; end
      class << base; attr_accessor :config_contexts; end
      class << base; attr_accessor :config_parent; end
      base.configuration = Hash.new
      base.configurables = Hash.new
      base.config_contexts = Array.new
    end

    # Loads a given ruby file, and runs instance_eval against it in the context of the current
    # object.
    #
    # Raises an IOError if the file cannot be found, or is not readable.
    #
    # === Parameters
    # filename<String>:: A filename to read from
    def from_file(filename)
      self.instance_eval(IO.read(filename), filename, 1)
    end

    # Pass Mixlib::Config.configure() a block, and it will yield itself
    #
    # === Parameters
    # block<Block>:: A block that is called with self.configuration as the arugment.
    def configure(&block)
      block.call(self.configuration)
    end

    # Get the value of a config option
    #
    # === Parameters
    # config_option<Symbol>:: The config option to return
    #
    # === Returns
    # value:: The value of the config option
    #
    # === Raises
    # <UnknownConfigOptionError>:: If the config option does not exist and strict mode is on.
    def [](config_option)
      internal_get(config_option.to_sym)
    end

    # Set the value of a config option
    #
    # === Parameters
    # config_option<Symbol>:: The config option to set (within the [])
    # value:: The value for the config option
    #
    # === Returns
    # value:: The new value of the config option
    #
    # === Raises
    # <UnknownConfigOptionError>:: If the config option does not exist and strict mode is on.
    def []=(config_option, value)
      internal_set(config_option.to_sym, value)
    end

    # Check if Mixlib::Config has a config option.
    #
    # === Parameters
    # key<Symbol>:: The config option to check for
    #
    # === Returns
    # <True>:: If the config option exists
    # <False>:: If the config option does not exist
    def has_key?(key)
      self.configuration.has_key?(key.to_sym)
    end

    # Resets a config option to its default.
    #
    # === Parameters
    # symbol<Symbol>:: Name of the config option
    def delete(symbol)
      self.configuration.delete(symbol)
    end

    # Resets all config options to their defaults.
    def reset
      self.configuration = Hash.new
      self.config_contexts.each { |config_context| config_context.reset }
    end

    # Merge an incoming hash with our config options
    #
    # === Parameters
    # hash<Hash>:: The incoming hash
    #
    # === Returns
    # result of Hash#merge!
    def merge!(hash)
      self.configuration.merge!(hash)
    end

    # Return the set of config hash keys
    #
    # === Returns
    # result of Hash#keys
    def keys
      self.configuration.keys
    end

    # Creates a shallow copy of the internal hash
    #
    # === Returns
    # result of Hash#dup
    def hash_dup
      self.configuration.dup
    end

    # metaprogramming to ensure that the slot for method_symbol
    # gets set to value after any other logic is run
    #
    # === Parameters
    # method_symbol<Symbol>:: Name of the method (variable setter)
    # blk<Block>:: logic block to run in setting slot method_symbol to value
    # value<Object>:: Value to be set in config hash
    #
    def config_attr_writer(method_symbol, &block)
      configurable(method_symbol).writes_value(&block)
    end

    # metaprogramming to set the default value for the given config option
    #
    # === Parameters
    # symbol<Symbol>:: Name of the config option
    # default_value<Object>:: Default value (can be unspecified)
    # block<Block>:: Logic block that calculates default value
    def default(symbol, default_value = nil, &block)
      configurable(symbol).defaults_to(default_value, &block)
    end

    # metaprogramming to set information about a config option.  This may be
    # used in one of two ways:
    #
    # 1. Block-based:
    # configurable(:attr) do
    #   defaults_to 4
    #   writes_value { |value| 10 }
    # end
    #
    # 2. Chain-based:
    # configurable(:attr).defaults_to(4).writes_value { |value| 10 }
    #
    # Currently supported configuration:
    #
    # defaults_to(value): value returned when configurable has no explicit value
    # defaults_to BLOCK: block is run when the configurable has no explicit value
    # writes_value BLOCK: block that is run to filter a value when it is being set
    #
    # === Parameters
    # symbol<Symbol>:: Name of the config option
    # default_value<Object>:: Default value [optional]
    # block<Block>:: Logic block that calculates default value [optional]
    #
    # === Returns
    # The value of the config option.
    def configurable(symbol, &block)
      unless configurables[symbol]
        configurables[symbol] = Configurable.new(symbol)
        define_attr_accessor_methods(symbol)
      end
      if block
        block.call(configurables[symbol])
      end
      configurables[symbol]
    end

    # Allows you to create a new config context where you can define new
    # options with default values.
    #
    # For example:
    #
    # config_context :server_info do
    #   configurable(:url).defaults_to("http://localhost")
    # end
    #
    # === Parameters
    # symbol<Symbol>: the name of the context
    # block<Block>: a block that will be run in the context of this new config
    # class.
    def config_context(symbol, &block)
      context = Class.new
      context.extend(::Mixlib::Config)
      context.config_parent = self
      config_contexts << context
      if block
        context.instance_eval(&block)
      end
      configurable(symbol).defaults_to(context).writes_value do |value|
        raise "config context #{symbol} cannot be modified"
      end
    end

    NOT_PASSED = Object.new

    # Gets or sets strict mode.  When strict mode is on, only values which
    # were specified with configurable(), default() or writes_with() may be
    # retrieved or set. Getting or setting anything else will cause
    # Mixlib::Config::UnknownConfigOptionError to be thrown.
    #
    # If this is set to :warn, unknown values may be get or set, but a warning
    # will be printed with Chef::Log.warn if this occurs.
    #
    # === Parameters
    # value<String>:: pass this value to set strict mode [optional]
    #
    # === Returns
    # Current value of config_strict_mode
    #
    # === Raises
    # <ArgumentError>:: if value is set to something other than true, false, or :warn
    #
    def config_strict_mode(value = NOT_PASSED)
      if value == NOT_PASSED
        if @config_strict_mode.nil?
          if config_parent
            config_parent.config_strict_mode
          else
            false
          end
        else
          @config_strict_mode
        end
      else
        self.config_strict_mode = value
      end
    end

    # Sets strict mode.  When strict mode is on, only values which
    # were specified with configurable(), default() or writes_with() may be
    # retrieved or set.  All other values
    #
    # If this is set to :warn, unknown values may be get or set, but a warning
    # will be printed with Chef::Log.warn if this occurs.
    #
    # === Parameters
    # value<String>:: pass this value to set strict mode [optional]
    #
    # === Raises
    # <ArgumentError>:: if value is set to something other than true, false, or :warn
    #
    def config_strict_mode=(value)
      if ![ true, false, :warn, nil ].include?(value)
        raise ArgumentError, "config_strict_mode must be true, false, nil or :warn"
      end
      @config_strict_mode = value
    end

    # Allows for simple lookups and setting of config options via method calls
    # on Mixlib::Config.  If there any arguments to the method, they are used to set
    # the value of the config option.  Otherwise, it's a simple get operation.
    #
    # === Parameters
    # method_symbol<Symbol>:: The method called.  Must match a config option.
    # *args:: Any arguments passed to the method
    #
    # === Returns
    # value:: The value of the config option.
    #
    # === Raises
    # <UnknownConfigOptionError>:: If the config option does not exist and strict mode is on.
    def method_missing(method_symbol, *args)
      method_symbol = $1.to_sym if method_symbol.to_s =~ /(.+)=$/
      internal_get_or_set(method_symbol, *args)
    end

    private

    # Internal dispatch setter for config values.
    # === Parameters
    # symbol<Symbol>:: Name of the method (variable setter)
    # value<Object>:: Value to be set in config hash
    #      
    def internal_set(symbol,value)
      if configurables.has_key?(symbol)
        configurables[symbol].set(self.configuration, value)
      else
        if config_strict_mode == :warn
          Chef::Log.warn("Setting unsupported config value #{method_name}..")
        elsif config_strict_mode
          raise UnknownConfigOptionError, "Cannot set unsupported config value #{method_name}."
        end
        configuration[symbol] = value
      end
    end

    def internal_get(symbol)
      if configurables.has_key?(symbol)
        configurables[symbol].get(self.configuration)
      else
        if config_strict_mode == :warn
          Chef::Log.warn("Reading unsupported config value #{symbol}.")
        elsif config_strict_mode
          raise UnknownConfigOptionError, "Reading unsupported config value #{symbol}."
        end
        configuration[symbol]
      end
    end

    def internal_get_or_set(symbol,*args)
      num_args = args.length
      # Setting
      if num_args > 0
        internal_set(symbol, num_args == 1 ? args[0] : args)
      end

      # Returning
      internal_get(symbol)
    end

    def define_attr_accessor_methods(symbol)
      # When Ruby 1.8.7 is no longer supported, this stuff can be done with define_singleton_method!
      meta = class << self; self; end
      # Setter
      meta.send :define_method, "#{symbol.to_s}=".to_sym do |value|
        internal_set(symbol, value)
      end
      # Getter
      meta.send :define_method, symbol do |*args|
        internal_get_or_set(symbol, *args)
      end
    end
  end
end
