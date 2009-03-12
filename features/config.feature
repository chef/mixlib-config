Feature: Configure an application
  In order to make it trivial to configure an application
  As a Developer
  I want to utilize a simple configuration object
  
Scenario: Set a configuration option to a string
  Given a configuration class
  When I set 'foo' to 'bar'
  Then config option 'foo' is 'bar'
  
Scenario: Set a configuration option to an Array
  Given a configuration class
  When I set 'foo' to:
    |key|
    |bar|
    |baz|
  Then an array is returned for 'foo'

Scenario: Set a configuration option from a file
  Given a configuration file 'bobo.config'
   When I load the configuration
   Then config option 'foo' is 'bar'
    And config option 'baz' is 'snarl'
