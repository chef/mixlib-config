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

module Mixlib
  module Config
    
    @@configuration = Hash.new
    
    # Loads a given ruby file, and runs instance_eval against it in the context of the current 
    # object.  
    #
    # Raises an IOError if the file cannot be found, or is not readable.
    #
    # === Parameters
    # <string>:: A filename to read from
    def from_file(filename)
      self.instance_eval(IO.read(filename), filename, 1)
    end
    
    # Pass Mixlib::Config.configure() a block, and it will yield @@configuration.
    #
    # === Parameters
    # <block>:: A block that is sent @@configuration as its argument
    def configure(&block)
      block.call(@@configuration)
    end

    # Get the value of a configuration option
    #
    # === Parameters
    # config_option<Symbol>:: The configuration option to return
    #
    # === Returns
    # value:: The value of the configuration option
    #
    # === Raises
    # <ArgumentError>:: If the configuration option does not exist
    def [](config_option)
      @@configuration[config_option.to_sym]
    end
      
    # Set the value of a configuration option
    #
    # === Parameters
    # config_option<Symbol>:: The configuration option to set (within the [])
    # value:: The value for the configuration option
    #
    # === Returns
    # value:: The new value of the configuration option
    def []=(config_option, value)
      internal_set(config_option,value)
    end
    
    # Check if Mixlib::Config has a configuration option.
    #
    # === Parameters
    # key<Symbol>:: The configuration option to check for
    #
    # === Returns
    # <True>:: If the configuration option exists
    # <False>:: If the configuration option does not exist
    def has_key?(key)
      @@configuration.has_key?(key.to_sym)
    end

    # Merge an incoming hash with our config options
    #
    # === Parameters
    # hash<Hash>:: The incoming hash
    #
    # === Returns
    # result of Hash#merge!
    def merge!(hash)
      @@configuration.merge!(hash)
    end
    
    # Return the set of config hash keys
    #
    # === Returns
    # result of Hash#keys
    def keys
      @@configuration.keys
    end
    
    # Creates a shallow copy of the internal hash
    #
    # === Returns
    # result of Hash#dup
    def hash_dup
      @@configuration.dup
    end
    
    # Internal dispatch setter, calling either the real defined method or setting the
    # hash value directly
    #
    # === Parameters
    # method_symbol<Symbol>:: Name of the method (variable setter)
    # value<Object>:: Value to be set in config hash
    #      
    def internal_set(method_symbol,value)
      method_name = method_symbol.id2name
      if (self.public_methods - ["[]="]).include?("#{method_name}=")
        self.send("#{method_name}=", value)
      else
        @@configuration[method_symbol] = value
      end
    end

    private :internal_set
    
    # Allows for simple lookups and setting of configuration options via method calls
    # on Mixlib::Config.  If there any arguments to the method, they are used to set
    # the value of the configuration option.  Otherwise, it's a simple get operation.
    #
    # === Parameters
    # method_symbol<Symbol>:: The method called.  Must match a configuration option.
    # *args:: Any arguments passed to the method
    #
    # === Returns
    # value:: The value of the configuration option.
    #
    # === Raises
    # <ArgumentError>:: If the method_symbol does not match a configuration option.
    def method_missing(method_symbol, *args)
      num_args = args.length
      
      # Setting
      if num_args > 0
        method_symbol = $1.to_sym unless (method_symbol.to_s =~ /(.+)=$/).nil?
        internal_set method_symbol, (num_args == 1 ? args[0] : args)
      end
      
      # Returning
      @@configuration[method_symbol]        

    end
  end
end
