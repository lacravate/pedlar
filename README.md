# Pedlar

Pedlar is a very (very very) small utility that allows you to define
getter / setter methods, more or less after the fashion of attr_accessor and
friends do it.

The resources thus exposed are instances of classes `Pedlar` `peddles`.

As well, with the precious help of Forwardable (from stdlib), `Pedlar` gives
access to delegations and (provided by Pedlar) so-called safe delegations.

## Installation

Ruby 1.9.2 is required.

Install it with rubygems:

    gem install pedlar

With bundler, add it to your `Gemfile`:

``` ruby
gem "pedlar"
```

## Use

``` ruby
require 'pedlar'

class HasInterfaces

  extend Pedlar

  # gives access to getter / setter methods
  # exposing resources as Pathname, Plop and
  # Plap instances
  peddles Pathname, Plip::Plop, Plip::Plap

  pathname_accessor :humpty
  pathname_reader :dumpty

  plip_plap_accessor :plap
  plip_plop_reader :plop

  # Same as above except an alias is specified.
  # Will set for example 'date_accessor' instead 
  # of 'datetime_accessor'.
  # One class - alias couple at a time
  peddles DateTime, :date

  # DateTime accessors
  date_accessor :foo
  date_writer :bar
  date_reader :baz

  # Pedlar delegations
  # returns nil if delegate is nil
  safe_delegator :@foo, :to_s, :to_string
  safe_delegators :@foo, :day, :month

  # vanilla Forwardable
  def_delegators :@plop, :to_s, :plopinou

  private

  # fitting setter method called by Pedlar
  def bar_setter(*args)
    args[0] -= 1
    DateTime.new *args
  end

end

###

h = HasInterfaces.new

# @foo not set yet
h.day # => nil, but does not crash

# @foo is set as DateTime.new(2001, 2, 3, 4, 5, 6)
h.foo_with(2001, 2, 3, 4, 5, 6)
# h.foo_with(DateTime.new(2001, 2, 3, 4, 5, 6)) would do the same
# h.foo = DateTime.new(2001, 2, 3, 4, 5, 6) would do the same

# :day forwarded to @foo now
h.day # => 3

```

### Class methods :
In the example above :
  `peddles Pathname` will set :
    - pathname_accessor : getter / setter of a Pathname
    - pathname_writer   : setter of a Pathname
    - pathname_reader   : getter of a Pathname

If no alias is specified, class names will be downcased and '::' are replaced
by '_'.

### Pedlar Delegations (class methods as well)
Those delegations are there only to avoid a crash or bizarre behaviour in case
delegate resource is not set.
  `safe_delegator` set up one delegation with an optional alias
  `safe_delegators` set up a number of delegations

### Instance methods :
In the example above :
  `pathname_accessor :humpty` will set :
    - a getter method : `h.humpty` will return @humpty value (classic)
    - a setter method : `h.humpty_with(args)` will set @humpty
      as Pathname.new(args)
    - a setter method : `h.humpty = a_value` will set @humpty to a_value
      if a_value is a Pathname

  `pathname_writer :humpty` would have set only the setter methods

  `pathname_reader :humpty` would have set only the getter method
```

Copyright
---------

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.
