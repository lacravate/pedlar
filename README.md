# Pedlar

Pedlar is a very (very very) small utility that allows you to define
getter / setter methods as interfaces to helper objects for the class
extending it.

The resources thus exposed are instances of classes `Pedlar` `peddles`. No more
`initialize` method only to set a few helper objects.

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

  # class of the object interfaced
  # type of accessor : accessor, reader, writer
  # options, here default value
  # DSL for one interface
  peddles String, reader: :poopoo, default: "pidoo"

  # in one go, HasInterfaces instances will have DateTime
  # objects accessed by, respectively :
  peddles DateTime,
    # foo and bar accessors
    accessors: %w|foo bar|,
    # blam accessor with DateTime.new as default
    blam: { type: :accessor, default: DateTime.now },
    # baz reader
    baz:  :reader,
    # plip, plap and plop writers
    writers: %w|plip plap plop|

  # in one go, definition for several classes
  peddles ERB => {
      # ERB y_ankok writer
      y_ankok: :writer
    },
    Pathname =>  {
      # accessor hympty defaulted to instance eval'ed Proc
      humpty: { type: :accessor, default: Proc.new { to_humpty 'humpty/dumpty' } },
      # accessor dumpty
      dumpty: :accessor,
      # reader pilou_pilou defaulting to pilou_pilou
      pilou_pilou: { type: :reader, default: 'pilou_pilou' },
      # writers laurel and hardy
      writers: %w|laurel hardy|
    }

  # Pedlar delegations
  # returns nil if delegate is nil
  safe_delegator :@foo, :to_s, :to_string
  safe_delegators :@foo, :day, :month

  # vanilla Forwardable
  def_delegators :@plop, :to_s, :plopinou

  private

  # fitting setter method called by Pedlar for bar accessor
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

h.bar_with 2001, 2, 3, 4, 5, 6
h.bar.year # => 2000 as Pedlar would have looked in `bar_setter`
           # to instantiate the DateTime object interfaced by bar
```

### Pedlar Delegations
Those delegations are there only to avoid a crash or bizarre behaviour in case
delegate resource is not set.
 - `safe_delegator` set up one delegation with an optional alias
 - `safe_delegators` set up a number of delegations

### Instance methods :
In the example above :
 - `:humpty` definition will set :
    - a getter method : `h.humpty` will return @humpty value (classic)
    - a setter method : `h.humpty_with(args)` will set @humpty
      as Pathname.new(args)
    - a setter method : `h.humpty = a_value` will set @humpty to a_value
      if a_value is a Pathname
 - `:bar` definition will set :
    - same kind of things as bar except :
      - a setter method : `h.humpty_with(args)` will set @humpty according to
        what's found in the fitting `bar_setter` method

## Copyright

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.
