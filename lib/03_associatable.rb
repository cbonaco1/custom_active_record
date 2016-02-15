require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions

  #These 3 are the key features of associatable
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default_options = {
      :foreign_key => "#{name.downcase}_id".to_sym,
      :primary_key => :id,
      :class_name => name.to_s.camelcase
    }

    # @foreign_key = options[:foreign_key]
    # @primary_key = options[:primary_key]
    # @class_name = options[:class_name]

    default_options.keys.each do |key|
      self.send("#{key}=", options[key] || default_options[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default_options = {
      :foreign_key => "#{self_class_name.downcase}_id".to_sym,
      :primary_key => :id,
      :class_name => name.to_s.camelcase.singularize
    }

    # These are going to be methods, not instance variables
    # @foreign_key = options[:foreign_key]
    # @primary_key = options[:primary_key]
    # @class_name = options[:class_name]

    # why is this send and not define_method?
    default_options.keys.each do |key|
      self.send("#{key}=", options[key] || default_options[key])
    end

  end
end

module Associatable

  #THESE ARE ALL CLASS METHODS
  
  def belongs_to(name, options = {})
    #Sets up the options
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    #creates method
    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key_value = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign_key_value).first
    end

  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key_value = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_key_value)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
