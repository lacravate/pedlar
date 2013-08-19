# encoding: utf-8

require File.expand_path('../../lib/pedlar.rb', __FILE__)

RSpec.configure do |config|
  # config from --init
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

# A class to test the module.
# It makes use of all the accessor/writer calls.
# It uses safe_delegations, and makes a vanilla
# Forwardable delegation
class HasInterfaces

  extend Pedlar

  peddles String, reader: :poopoo, default: "pidoo"

  peddles DateTime,
    accessors: %w|foo bar|,
    blam: { type: :accessor, default: DateTime.now },
    baz:  :reader,
    writers: %w|plip plap plop|

  peddles ERB => {
      y_ankok: :writer
    },
    Pathname =>  {
      humpty: { type: :accessor, default: Proc.new { to_humpty 'humpty/dumpty' } },
      dumpty: :accessor,
      pilou_pilou: { type: :reader, default: 'pilou_pilou' },
      writers: %w|laurel hardy|
    }

  safe_delegator :@bim, :to_s, :to_string
  safe_delegators :@bim, :day, :month
  safe_delegators :bam, :year

  def_delegators :@plop, :to_s, :plopinou

  attr_accessor :bim

  def test_methods
     %w|
      foo= bar= foo bar baz plip= plap= plop= blam blam=
      humpty= dumpty= humpty dumpty pilou_pilou
      laurel= hardy= y_ankok= poopoo
    |
  end

  def bam
    @bim
  end

  private

  def to_humpty(s)
    s.capitalize
  end

  # fitting setter method called by Pedlar
  def bar_setter(*args)
    args[0] -= 1
    DateTime.new *args
  end

end
