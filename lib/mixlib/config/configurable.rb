#
# Author:: John Keiser (<jkeiser@opscode.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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
    class Configurable
      def initialize(symbol)
        @symbol = symbol
        @default_block = nil
        @has_default = false
        @default_value = nil
        @writes_value = nil
      end

      attr_reader :has_default

      def defaults_to(default_value = nil, &block)
        @has_default = true
        @default_block = block
        @default_value = default_value
        self
      end

      def writes_value(&block)
        @writes_value = block
        self
      end

      def get(config)
        if config.has_key?(@symbol)
          config[@symbol]
        elsif @default_block
          @default_block.call
        else
          begin
            # Some things cannot be dup'd, and you won't know this till after the fact
            # because all values implement dup
            config[@symbol] = @default_value.dup
          rescue TypeError
            @default_value
          end
        end
      end

      def set(config, value)
        config[@symbol] = @writes_value ? @writes_value.call(value) : value
      end

      def default
        if @default_block
          @default_block.call
        else
          @default_value
        end
      end
    end
  end
end
