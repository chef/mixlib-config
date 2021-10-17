# Mixlib::Config

[![Gem Version](https://badge.fury.io/rb/mixlib-config.svg)](https://badge.fury.io/rb/mixlib-config)
[![Build status](https://badge.buildkite.com/038bff14d03b1f91115dbb444ca81b387bd23855413f017fc0.svg?branch=master)](https://buildkite.com/chef-oss/chef-mixlib-config-master-verify)

**Umbrella Project**: [Chef Foundation](https://github.com/chef/chef-oss-practices/blob/master/projects/chef-foundation.md)

**Project State**: [Active](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md#active)

**Issues [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

**Pull Request [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

Mixlib::Config provides a class-based configuration object, as used in Chef. To use in your project:

```ruby
  require 'mixlib/config'

  module MyConfig
    extend Mixlib::Config
    config_strict_mode true
    default :first_value, 'something'
    default :other_value, 'something_else'
  end
```

You can use this to provide a configuration file for a user. For example, if you do this:

```ruby
  MyConfig.from_file('~/.myconfig.rb')
```

A user could write a Ruby config file that looked like this:

```ruby
  first_value 'hi'
  second_value "#{first_value}!  10 times 10 is #{10*10}!"
```

Inside your app, you can check configuration values with this syntax:

```ruby
  MyConfig.first_value   # returns 'something'
  MyConfig[:first_value] # returns 'something'
```

And you can modify configuration values with this syntax:

```ruby
  MyConfig.first_value('foobar')    # sets first_value to 'foobar'
  MyConfig.first_value = 'foobar'   # sets first_value to 'foobar'
  MyConfig[:first_value] = 'foobar' # sets first_value to 'foobar'
```

If you prefer to allow your users to pass in configuration via YAML, JSON or TOML files, `mixlib-config` supports that too!

```ruby
  MyConfig.from_file('~/.myconfig.yml')
  MyConfig.from_file('~/.myconfig.json')
  MyConfig.from_file('~/.myconfig.toml')
```

This way, a user could write a YAML config file that looked like this:

```yaml
---
first_value: 'hi'
second_value: 'goodbye'
```

or a JSON file that looks like this:

```json
{
  "first_value": "hi",
  "second_value": "goodbye"
}
```

or a TOML file that looks like this:

```toml
first_value = "hi"
second_value = "goodbye"
```

Please note: There is an inherent limitation in the logic you can do with YAML and JSON file. At this time, `mixlib-config` does not support ERB or other logic in YAML or JSON config (read "static content only").

## Nested Configuration

Often you want to be able to group configuration options to provide a common context. Mixlib::Config supports this thus:

```ruby
  require 'mixlib/config'

  module MyConfig
    extend Mixlib::Config
    config_context :logging do
      default :base_filename, 'mylog'
      default :max_log_files, 10
    end
  end
```

The user can write their config file in one of three formats:

### Method Style

```ruby
logging.base_filename 'superlog'
logging.max_log_files 2
```

### Block Style

Using this format the block is executed in the context, so all configurables on that context is directly accessible

```ruby
logging do
  base_filename 'superlog'
  max_log_files 2
end
```

### Block with Argument Style

Using this format the context is given to the block as an argument

```ruby
logging do |l|
  l.base_filename = 'superlog'
  l.max_log_files = 2
end
```

You can access these variables thus:

```ruby
  MyConfig.logging.base_filename
  MyConfig[:logging][:max_log_files]
```

### Lists of Contexts
For use cases where you need to be able to specify a list of things with identical configuration
you can define a `context_config_list` like so:

```ruby
  require 'mixlib/config'

  module MyConfig
    extend Mixlib::Config

    # The first argument is the plural word for your item, the second is the singular
    config_context_list :apples, :apple do
      default :species
      default :color, 'red'
      default :crispness, 10
    end
  end
```

With this definition every time the `apple` is called within the config file it
will create a new item that can be configured with a block like so:

```ruby
apple do
  species 'Royal Gala'
end
apple do
  species 'Granny Smith'
  color 'green'
end
```

You can then iterate over the defined values in code:

```ruby
MyConfig.apples.each do |apple|
  puts "#{apple.species} are #{apple.color}"
end

# => Royal Gala are red
# => Granny Smith are green
```

_**Note**: When using the config context lists they must use the [block style](#block-style) or [block with argument style](#block-with-argument-style)_

### Hashes of Contexts
For use cases where you need to be able to specify a list of things with identical configuration
that are keyed to a specific value, you can define a `context_config_hash` like so:

```ruby
  require 'mixlib/config'

  module MyConfig
    extend Mixlib::Config

    # The first argument is the plural word for your item, the second is the singular
    config_context_hash :apples, :apple do
      default :species
      default :color, 'red'
      default :crispness, 10
    end
  end
```

This can then be used in the config file like so:

```ruby
apple 'Royal Gala' do
  species 'Royal Gala'
end
apple 'Granny Smith' do
  species 'Granny Smith'
  color 'green'
end

# You can also reopen a context to edit a value
apple 'Royal Gala' do
  crispness 3
end
```

You can then iterate over the defined values in code:

```ruby
MyConfig.apples.each do |key, apple|
  puts "#{key} => #{apple.species} are #{apple.color}"
end

# => Royal Gala => Royal Gala are red
# => Granny Smith => Granny Smith are green
```

_**Note**: When using the config context hashes they must use the [block style](#block-style) or [block with argument style](#block-with-argument-style)_

## Default Values

Mixlib::Config has a powerful default value facility. In addition to being able to specify explicit default values, you can even specify Ruby code blocks that will run if the config value is not set. This can allow you to build options whose values are based on other options.

```ruby
  require 'mixlib/config'

  module MyConfig
    extend Mixlib::Config
    config_strict_mode true
    default :verbosity, 1
    default(:print_network_requests) { verbosity >= 2 }
    default(:print_ridiculously_unimportant_stuff) { verbosity >= 10 }
  end
```

This allows the user to quickly specify a number of values with one default, while still allowing them to override anything:

```ruby
  verbosity 5
  print_network_requests false
```

You can also inspect if the values are still their defaults or not:

```ruby
MyConfig.is_default?(:verbosity)  # == true
MyConfig[:verbosity] = 5
MyConfig.is_default?(:verbosity)  # == false
MyConfig[:verbosity] = 1
MyConfig.is_default?(:verbosity)  # == true
```

Trying to call `is_default?` on a config context or a config which does not have a declared default is an error and will raise.

## Strict Mode

Misspellings are a common configuration problem, and Mixlib::Config has an answer: `config_strict_mode`. Setting `config_strict_mode` to `true` will cause any misspelled or incorrect configuration option references to throw `Mixlib::Config::UnknownConfigOptionError`.

```ruby
  require 'mixlib/config'

  module MyConfig
    extend Mixlib::Config
    config_strict_mode true
    default :filename, '~/output.txt'
    configurable :server_url # configurable declares an option with no default value
    config_context :logging do
      default :base_name, 'log'
      default :max_files, 20
    end
  end
```

Now if a user types `fielname "~/output-mine.txt"` in their configuration file, it will toss an exception telling them that the option "fielname" is unknown. If you do not set config_strict_mode, the fielname option will be merrily set and the application just won't know about it.

Different config_contexts can have different strict modes; but they inherit the strict mode of their parent if you don't explicitly set it. So setting it once at the top level is sufficient. In the above example, `logging.base_naem 'mylog'` will raise an error.

In conclusion: _always set config_strict_mode to true_. You know you want to.

## Testing and Reset

Testing your application with different sets of arguments can by simplified with `reset`. Call `MyConfig.reset` before each test and all configuration will be reset to its default value. There's no need to explicitly unset all your options between each run.

NOTE: if you have arrays of arrays, or other deep nesting, we suggest you use code blocks to set up your default values (`default(:option) { [ [ 1, 2 ], [ 3, 4 ] ] }`). Deep children will not always be reset to their default values.

Enjoy!

## Contributing

For information on contributing to this project see <https://github.com/chef/chef/blob/master/CONTRIBUTING.md>

## License

- Copyright:: Copyright (c) 2009-2019 Chef Software, Inc.
- License:: Apache License, Version 2.0

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
