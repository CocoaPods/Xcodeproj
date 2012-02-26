require 'xcodeproj/inflector'

module Xcodeproj
  class Project
    module Object

      class PBXObject
        def self.reflections
          @reflections ||= []
        end

        def self.create_reflection(name, options)
          (reflections << AssociationReflection.new(name, options)).last
        end

        def self.reflection(name)
          reflections.find { |r| r.name.to_s == name.to_s }
        end

        class AssociationReflection
          def initialize(name, options)
            @name, @options = name.to_s, options
          end

          attr_reader :name, :options

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

          def singular_name
            @options[:singular_name] || @name.singularize
          end

          def singular_getter
            singular_name
          end

          def singular_setter
            "#{singular_name}="
          end

          def plural_name
            # this makes 'children' work, otherwise it returns 'childrens' :-/
            @name.singularize.pluralize
          end

          def plural_getter
            plural_name
          end

          def plural_setter
            "#{plural_name}="
          end

          def uuid_attribute
            @options[:uuid] || @name
          end

          def uuid_method_name
            (@options[:uuid] || @options[:uuids] || "#{singular_name}Reference").to_s.singularize
          end

          def uuid_getter
            uuid_method_name
          end

          def uuid_setter
            "#{uuid_method_name}="
          end

          def uuids_method_name
            uuid_method_name.pluralize
          end

          def uuids_getter
            uuids_method_name
          end

          def uuids_setter
            "#{uuids_method_name}="
          end
        end

      end

    end
  end
end
