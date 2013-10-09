# encoding: utf-8

# maybe i like that one too much...
require 'forwardable'

module Pedlar

  # Forwardable is available to the extending class
  include Forwardable

  def peddles(brands, options=nil)
    # wait till Pedlar::Peddles is defined to include it
    include Pedlar::Peddles

    # options ? DSL for one accessor then
    # let's make it appear as it was a hash'ed definition
    brands = { brands => options } if options

    # each interface class
    brands.each do |brand, dsl|
      # definition entry displays reserved word ?
      # reformat definition then
      if type = (dsl.keys & %w|accessor writer reader|.map(&:to_sym)).first
        dsl = { dsl.delete(type.to_sym) => dsl.merge(type: type) }
      end

      # each definition entry
      dsl.each do |name, options|
        # group definiton made by reserved words
        # readers, writers, accessors
        # hence the `chop` to determine accessor type
        if options.is_a? Array
          options.each do |actual|
            define_accessor_for brand, actual.to_sym, name.to_s.chop
          end
        else
          # single definition, possibly with options
          define_accessor_for brand, name, options
        end
      end
    end
  end

  # hand-made delegation setup
  def safe_delegator(delegate, delegation, method=delegation)
    safe_delegation delegate, delegation, method
  end

  # hand-made delegations setup
  def safe_delegators(delegate, *delegations)
    delegations.each { |d| safe_delegation delegate, d }
  end

  private

  # last DSL routing before actual definition
  def define_accessor_for(brand, name, options)
    if options.is_a? Hash
      type = options.delete :type
    else
      # options was not a hash, it means it was in fact
      # the accessor type that was sent as a symbol
      type, options = options, {}
    end

    # type : accessor, reader, writer
    # brand : class interfaced
    # name : user-defined accessor name
    # default as the only accepted option so far
    send type, brand, name.to_sym, options[:default]
  end

  # hand-made delegation
  # tests if delegate is not nil to avoid crash.
  # it returns nil in this case.
  def safe_delegation(delegate, delegation, method=delegation)
    define_method method.to_sym do |*args, &block|
      # Forwardable makes an eval so it does not care whether
      # delegate is a method or an instance variable.
      # I chose not to do it (so far), so i have to try both
      # ways to get the delegate, in a violent way. But i like it.
      interface = begin
        send :instance_variable_get, delegate.to_s
      rescue
        send delegate
      end

      interface && interface.send(delegation, *args, &block)
    end
  end

  # defines two instance writer methods
  # - `accessor=`
  # - `accessor_with`
  def writer(brand, accessor, default)
    # classic setter scheme, it does nothing if value
    # parameter is not a `brand` instance though
    define_method "#{accessor}=".to_sym do |value|
      instance_variable_set "@#{accessor}", value if value.is_a? brand
    end

    # pedlar setter `accessor_with`
    # it sets instance variable with :
    #  - fitting user-defined method
    #  - or instance creation with passed params
    #  - or value that must a be an instance of `brand`
    define_method "#{accessor}_with".to_sym do |*values|
      instance_variable_set "@#{accessor}", peddles(accessor, brand, *values)
    end
  end

  # defines an instance reader method with `accessor` as its name
  def reader(brand, accessor, default)
    define_method "#{accessor}".to_sym do
      # do we have it ? No, instantiate it if we have a default directive
      instance_variable_get("@#{accessor}") || (
        default &&
        instance_variable_get("@#{accessor}").nil? &&
        instance_variable_set("@#{accessor}", peddles(accessor, brand, default_value(default)))
      )
    end
  end

  # defines reader and writer
  def accessor(*definitions)
    reader(*definitions) && writer(*definitions)
  end

  module Peddles

    private

    def default_value(value)
      value.is_a?(Proc) ? ->() { instance_eval &value }.call : value.dup
    end

    def peddles(accessor, brand, *values)
      # fitting setter method ?
      if respond_to? "#{accessor}_setter", true
        send "#{accessor}_setter", *values
      # not an instance of class interfaced ?
      elsif !values.first.instance_of? brand
        brand.new *values
      else
        values.first
      end
    end

  end

end
