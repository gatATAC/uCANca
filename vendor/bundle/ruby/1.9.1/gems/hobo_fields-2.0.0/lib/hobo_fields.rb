require 'hobo_support'

ActiveSupport::Dependencies.autoload_paths |= [ File.dirname(__FILE__) ]
ActiveSupport::Dependencies.autoload_once_paths |= [ File.dirname(__FILE__) ]

module Hobo
  # Empty class to represent the boolean type.
  class Boolean; end
end

module HoboFields

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end

  extend self

  PLAIN_TYPES = {
    :boolean       => Hobo::Boolean,
    :date          => Date,
    :datetime      => ActiveSupport::TimeWithZone,
    :time          => Time,
    :integer       => Integer,
    :decimal       => BigDecimal,
    :float         => Float,
    :string        => String
  }

  ALIAS_TYPES = {
    Fixnum => "integer",
    Bignum => "integer"
  }

  # Provide a lookup for these rather than loading them all preemptively

  STANDARD_TYPES = {
    :raw_html      => "RawHtmlString",
    :html          => "HtmlString",
    :raw_markdown  => "RawMarkdownString",
    :markdown      => "MarkdownString",
    :textile       => "TextileString",
    :password      => "PasswordString",
    :text          => "Text",
    :email_address => "EmailAddress",
    :serialized    => "SerializedObject"
  }

  @field_types   = PLAIN_TYPES.with_indifferent_access
  @never_wrap_types = Set.new([NilClass, Hobo::Boolean, TrueClass, FalseClass])
  attr_reader :field_types

  def to_class(type)
    if type.is_one_of?(Symbol, String)
      type = type.to_sym
      field_types[type] || standard_class(type)
    else
      type # assume it's already a class
    end
  end

  def to_name(type)
    field_types.key(type) || ALIAS_TYPES[type]
  end

  def can_wrap?(type, val)
    col_type = type::COLUMN_TYPE
    return false if val.blank? && (col_type == :integer || col_type == :float || col_type == :decimal)
    klass = Object.instance_method(:class).bind(val).call # Make sure we get the *real* class
    init_method = type.instance_method(:initialize)
    [-1,1].include?(init_method.arity) &&
      init_method.owner != Object.instance_method(:initialize).owner &&
      !@never_wrap_types.any? { |c| klass <= c }
  end

  def never_wrap(type)
    @never_wrap_types << type
  end

  def register_type(name, klass)
    field_types[name] = klass
  end

  def plain_type?(type_name)
    type_name.in?(PLAIN_TYPES)
  end

  def standard_class(name)
    class_name = STANDARD_TYPES[name]
    "HoboFields::Types::#{class_name}".constantize if class_name
  end

end

require 'hobo_fields/railtie'


