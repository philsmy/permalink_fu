module PermalinkFu
  module ActiveRecord
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def has_permalink(attr_names = [], permalink_field = nil, options = {})
        include InstanceMethods

        if permalink_field.is_a?(Hash)
          options = permalink_field
          permalink_field = nil
        end

        cattr_accessor :permalink_options
        cattr_accessor :permalink_attributes
        cattr_accessor :permalink_field

        self.permalink_attributes = [attr_names].flatten
        self.permalink_field      = (permalink_field || 'permalink').to_s
        self.permalink_options    = {:unique => true}.update(options)

        if self.permalink_options[:unique]
          before_validation :create_unique_permalink
        else
          before_validation :create_common_permalink
        end

        define_method :"#{self.permalink_field}=" do |value|
          write_attribute(self.permalink_field, value.blank? ? '' : PermalinkFu.escape(value))
        end

        extend  PermalinkFinders

        case options[:param]
        when false
          # nothing
        when :permalink
          include ToParam
        else
          include ToParamWithID
        end
      end
    end

    module ToParam
      def to_param
        read_attribute(self.class.permalink_field)
      end
    end
  
    module ToParamWithID
      def to_param
        permalink = read_attribute(self.class.permalink_field)
        return super if new_record? || permalink.blank?
        "#{id}-#{permalink}"
      end
    end
  
    module PermalinkFinders
      def find_by_permalink(value)
        find(:first, :conditions => { permalink_field => value  })
      end
    
      def find_by_permalink!(value)
        find_by_permalink(value) ||
        raise(ActiveRecord::RecordNotFound, "Couldn't find #{name} with permalink #{value.inspect}")
      end
    end

    # This contains instance methods for ActiveRecord models that have permalinks.
    module InstanceMethods

      protected

      def create_common_permalink
        return unless should_create_permalink?

        if read_attribute(self.class.permalink_field).blank? || permalink_fields_changed?
          send("#{self.class.permalink_field}=", create_permalink_for(self.class.permalink_attributes))
        end

        return if changed.include?(self.class.permalink_field)

        limit   = self.class.columns_hash[self.class.permalink_field].limit
        base    = send("#{self.class.permalink_field}=", read_attribute(self.class.permalink_field)[0..limit - 1])
        
        return [limit, base]
      end

      def create_unique_permalink
        limit, base = create_common_permalink

        return if limit.nil?

        conditions = ["#{self.class.permalink_field} = ?", base]
        unless new_record?
          conditions.first << " AND id != ?"
          conditions       << id
        end

        [self.class.permalink_options[:scope]].flatten.compact.each do |scope|
          value = send(scope)
          if value
            conditions.first << " AND #{scope} = ?"
            conditions       << send(scope)
          else
            conditions.first << " AND #{scope} IS NULL"
          end
        end

        counter = 1

        while ::ActiveRecord::Base.uncached{ self.class.exists?(conditions) }
          suffix = "-#{counter += 1}"
          conditions[1] = "#{base[0..limit-suffix.size-1]}#{suffix}"
          send("#{self.class.permalink_field}=", conditions[1])
        end
      end

      def create_permalink_for(attr_names)
        str = attr_names.collect { |attr_name| send(attr_name).to_s } * " "
        str.blank? ? PermalinkFu.random_permalink : str
      end

      private

      def should_create_permalink?
        if self.class.permalink_field.blank?
          false
        elsif self.class.permalink_options[:if]
          evaluate_method(self.class.permalink_options[:if])
        elsif self.class.permalink_options[:unless]
          !evaluate_method(self.class.permalink_options[:unless])
        else
          true
        end
      end

      def permalink_fields_changed?
        return false unless self.class.permalink_options[:update]
        (self.class.permalink_attributes & self.changed).any?
      end

      def evaluate_method(method)
        case method
        when Symbol
          send(method)
        when Proc, Method
          method.call(self)
        end
      end
    end
  end
end