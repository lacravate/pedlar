# encoding: utf-8

# maybe i like that one too much...
require 'forwardable'

module Pedlar

  # Forwardable is available to the extending class
  include Forwardable

  def peddles(*brands)

    include Pedlar::Peddles

    # do we have a list of interface to setup
    # or one interface with an alias ?
    brands = [brands] unless brands.all? { |brand| brand.is_a? Class }

    # Ruby is too nice a pal... It accepts to assign iteration
    # variables in a juicy DWIM way : depending on the arguments
    # we got, `brands` is either a flat list of classes
    # or a list of one list. But it's the same to my pal...
    brands.each do |brand, dsl|
      # lousy lousy active_support neat methods mockery
      (dsl ||= {})[:as] ||= brand.to_s.downcase.gsub('::', '_')

      # three class methods per `brand` to setup accessors/mutators.
      %w|accessor writer reader|.each do |type|
        # ex: brand=Date defines `date_accessor`, `date_writer`, `date_reader`.
        # Each of these three calls private methods (`type`) setting up
        # the actual accessor/mutator with user-defined name.
        define_singleton_method "#{dsl[:as]}_#{type}".to_sym do |*accessors|
          accessors = [accessors] if accessors.last.is_a?(Hash)

          # `accessors` below being the user-defined accessors names.
          accessors.each do |accessor, options|
            default = (options || {})[:default]
            send type, brand, accessor, default
          end
        end

        send "#{dsl[:as]}_#{type}", *dsl[type.to_sym] if dsl[type.to_sym]
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
      instance_variable_get("@#{accessor}") || (
        default &&
        instance_variable_get("@#{accessor}").nil? &&
        peddles(accessor, brand, default.dup)
      )
    end
  end

  # defines reader and writer
  def accessor(*definitions)
    reader(*definitions) && writer(*definitions)
  end

  module Peddles

    private

    def peddles(accessor, brand, *values)
      if respond_to? "#{accessor}_setter", true
        send "#{accessor}_setter", *values
      elsif !values.first.is_a? brand
        brand.new *values
      else
        values.first
      end
    end

  end

end
