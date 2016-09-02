# Mixlib::Config

[![Build Status](https://travis-ci.org/chef/mixlib-config.svg?branch=master)](https://travis-ci.org/chef/mixlib-config)[![Gem Version](https://badge.fury.io/rb/mixlib-config.svg)](https://badge.fury.io/rb/mixlib-config)

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

#### Method Style
```ruby
logging.base_filename 'superlog'
logging.max_log_files 2
```

#### Block Style
Using this format the block is executed in the context, so all configurables on that context is directly accessible
```ruby
logging do
  base_filename 'superlog'
  max_log_files 2
end
```

#### Block with Argument Style
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
