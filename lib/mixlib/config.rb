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
      if File.exists?(filename) && File.readable?(filename)
        self.instance_eval(IO.read(filename), filename, 1)
      else
        raise IOError, "Cannot open or read #{filename}!"
      end
    end
    
    # Pass Mixlib::Config.configure() a block, and it will yield @configuration.
    #
    # === Parameters
    # <block>:: A block that takes @configure as it's argument
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
      if @@configuration.has_key?(config_option.to_sym)
        @@configuration[config_option.to_sym]
      else
        raise ArgumentError, "Cannot find configuration option #{config_option.to_s}"
      end
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
      @@configuration[config_option.to_sym] = value
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
       
      # If we have the symbol, or if we need to set it
      if @@configuration.has_key?(method_symbol) || num_args > 0
        if num_args > 0
          @@configuration[method_symbol] = num_args == 1 ? args[0] : args
        end
        return @@configuration[method_symbol]
      else
      # Otherwise, we're just looking it up
        raise ArgumentError, "Cannot find configuration option #{method_symbol.to_s}"
      end
    end

  end
end
