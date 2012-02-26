module Xcodeproj
  class Project
    module Object

      # Missing constants that begin with either `PBX' or `XC' are assumed to be
      # valid classes in a Xcode project. A new PBXObject subclass is created
      # for the constant and returned.
      def self.const_missing(name)
        if name.to_s =~ /^(PBX|XC)/
          klass = Class.new(PBXObject)
          const_set(name, klass)
          klass
        else
          super
        end
      end

      class PBXObject
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

        def self.reflections
          @reflections ||= []
        end

        def self.create_reflection(name, options)
          (reflections << AssociationReflection.new(name, options)).last
        end

        def self.reflection(name)
          reflections.find { |r| r.name.to_s == name.to_s }
        end

        def self.attribute(attribute_name, accessor_name = nil)
          attribute_name = attribute_name.to_s
          name = (accessor_name || attribute_name).to_s
          define_method(name) { @attributes[attribute_name] }
          define_method("#{name}=") { |value| @attributes[attribute_name] = value }
        end

        def self.attributes(*names)
          names.each { |name| attribute(name) }
        end

        def self.has_many(plural_attr_name, options = {}, &block)
          reflection = create_reflection(plural_attr_name, options)
          if reflection.inverse?
            define_method(reflection.name) do
              scoped = @project.objects.select_by_class(reflection.klass).select do |object|
                object.send(reflection.inverse.uuid_getter) == self.uuid
              end
              PBXObjectList.new(reflection.klass, @project, scoped) do |object|
                object.send(reflection.inverse.uuid_setter, self.uuid)
              end
            end
          else
            attribute(reflection.name, reflection.uuids_getter)
            define_method(reflection.name) do
              uuids = send(reflection.uuids_getter)
              if block
                # Evaluate the block, which was specified at the class level, in
                # the instance’s context.
                list_by_class(uuids, reflection.klass) do |object|
                  instance_exec(object, &block)
                end
              else
                list_by_class(uuids, reflection.klass)
              end
            end
            define_method(reflection.plural_setter) do |objects|
              send(reflection.uuids_setter, objects.map(&:uuid))
            end
          end
        end

        def self.has_one(singular_attr_name, options = {})
          reflection = create_reflection(singular_attr_name, options)
          if reflection.inverse?
            define_method(reflection.name) do
              # Loop over all objects of the class and find the one that includes
              # this object in the specified uuid list.
              @project.objects.select_by_class(reflection.klass).find do |object|
                object.send(reflection.inverse.uuids_getter).include?(self.uuid)
              end
            end
            define_method(reflection.singular_setter) do |object|
              # Remove this object from the uuid list of the target
              # that this object was associated to.
              if previous = send(reflection.name)
                previous.send(reflection.inverse.uuids_getter).delete(self.uuid)
              end
              # Now assign this object to the new object
              object.send(reflection.inverse.uuids_getter) << self.uuid if object
            end
          else
            attribute(reflection.uuid_attribute, reflection.uuid_getter)
            define_method(reflection.name) do
              @project.objects[send(reflection.uuid_getter)]
            end
            define_method(reflection.singular_setter) do |object|
              send(reflection.uuid_setter, object.uuid)
            end
          end
        end

        def self.isa
          @isa ||= name.split('::').last
        end

        attr_reader :uuid, :attributes
        attributes :isa, :name

        def initialize(project, uuid, attributes)
          @project, @attributes = project, attributes
          unless uuid
            # Add new objects to the main hash with a unique UUID
            begin; uuid = generate_uuid; end while @project.objects_hash.has_key?(uuid)
            @project.objects_hash[uuid] = @attributes
          end
          @uuid = uuid
          self.isa ||= self.class.isa
        end

        def ==(other)
          other.is_a?(PBXObject) && self.uuid == other.uuid
        end

        def inspect
          "#<#{isa} UUID: `#{uuid}', name: `#{name}'>"
        end
        
        def matches_attributes?(attributes)
          attributes.all? do |attribute, expected_value| 
            return nil unless respond_to?(attribute)

            if expected_value.is_a?(Hash)
              send(attribute).matches_attributes?(expected_value)
            else
              send(attribute) == expected_value
            end
          end
        end

        private

        def generate_uuid
          Xcodeproj.generate_uuid
        end

        def list_by_class(uuids, klass, scoped = nil, &block)
          unless scoped
            scoped = uuids.map { |uuid| @project.objects[uuid] }.select { |o| o.is_a?(klass) }
          end
          if block
            PBXObjectList.new(klass, @project, scoped, &block)
          else
            PBXObjectList.new(klass, @project, scoped) do |object|
              # Add the uuid of a newly created object to the uuids list
              uuids << object.uuid
            end
          end
        end
      end

    end
  end
end

require 'xcodeproj/project/object_list'

# Now load the rest of the classes which inherit from PBXObject.
require 'xcodeproj/project/object/build_phase'
require 'xcodeproj/project/object/configuration'
require 'xcodeproj/project/object/file_reference'
require 'xcodeproj/project/object/group'
require 'xcodeproj/project/object/native_target'
