require 'xcodeproj/inflector'

module Xcodeproj
  class Project
    module Object

      class AbstractPBXObject
        def self.reflections
          @reflections ||= []
        end

        def self.create_reflection(type, name, options)
          (reflections << Association::Reflection.new(type, name, options)).last
        end

        def self.reflection(name)
          reflections.find { |r| r.name.to_s == name.to_s }
        end
      end

      class Association
        class Reflection
          def initialize(type, name, options)
            @type, @name, @options = type, name.to_s, options
          end

          attr_reader :type, :name, :options

          def klass
            @options[:class] ||= begin
              name = "PBX#{@name.classify}"
              name = "XC#{@name.classify}" unless Xcodeproj::Project::Object.const_defined?(name)
              Xcodeproj::Project::Object.const_get(name)
            end
          end

          def inverse
            klass.reflection(@options[:inverse_of])
          end

          def inverse?
            !!@options[:inverse_of]
          end

          def attribute_name
            (@options[:uuid] || @options[:uuids] || @name).to_sym
          end

          def attribute_getter
            case type
            when :has_many
              uuid_method_name.pluralize
            when :has_one
              uuid_method_name
            end.to_sym
          end

          def attribute_setter
            "#{attribute_getter}=".to_sym
          end

          def getter
            @name.to_sym
          end

          def setter
            "#{@name}=".to_sym
          end

          def association_for(owner, &block)
            case type
            when :has_many then Association::HasMany
            when :has_one  then Association::HasOne
            end.new(owner, self, &block)
          end

          private

          def uuid_method_name
            (@options[:uuid] || @options[:uuids] || "#{@name.singularize}_reference").to_s.singularize
          end
        end

      end

    end
  end
end
