module Xcodeproj
  class Project
    # This is the namespace in which all the classes that wrap the objects in
    # a Xcode project reside.
    #
    # The base class from which all classes inherit is PBXObject.
    #
    # If you need to deal with these classes directly, it's possible to include
    # this namespace into yours, making it unnecessary to prefix them with
    # Xcodeproj::Project::Object.
    #
    # @example
    #
    #     class SourceFileSorter
    #       include Xcodeproj::Project::Object
    #     end
    module Object

      # Missing constants that begin with either `PBX' or `XC' are assumed to
      # be valid classes in a Xcode project. A new PBXObject subclass is
      # created for the constant and returned.
      #
      # @return [Class]  The generated class inhertiting from PBXObject.
      def self.const_missing(name)
        if name.to_s =~ /^(PBX|XC)/
          klass = Class.new(PBXObject)
          const_set(name, klass)
          klass
        else
          super
        end
      end

      # This is the base class of all object types that can exist in a Xcode
      # project. As such it provides common behavior, but you can only use
      # instances of subclasses of PBXObject, because this class does not exist
      # in actual Xcode projects.
      class PBXObject
        def self.attribute(attribute_name, accessor_name = nil)
          attribute_name = attribute_name.to_s
          name = (accessor_name || attribute_name).to_s
          define_method(name) { @attributes[attribute_name] }
          define_method("#{name}=") { |value| @attributes[attribute_name] = value }
        end

        def self.attributes(*names)
          names.each { |name| attribute(name) }
        end

        def self.isa
          @isa ||= name.split('::').last
        end

        attr_reader :uuid, :attributes
        attributes :isa, :name

        # It is not recommended that you instantiate objects through this
        # constructor. It is much easier to use associations to create them.
        #
        # @example
        #
        #     file_reference = project.files.new('path' => 'path/to/file')
        #
        # @return [PBXObject]
        def initialize(project, uuid, attributes)
          @project, @attributes = project, attributes
          unless uuid
            # Add new objects to the main hash with a unique UUID
            uuid = generate_uuid
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

        # Generate a truly unique UUID. This is to ensure that cutting up the
        # UUID in the xcodeproj extension doesn't cause a collision.
        def generate_uuid
          begin
            uuid = Xcodeproj.generate_uuid
          end while @project.objects_hash.has_key?(uuid)
          uuid
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

require 'xcodeproj/project/associations'
require 'xcodeproj/project/object_list'

# Now load the rest of the classes which inherit from PBXObject.
require 'xcodeproj/project/object/build_phase'
require 'xcodeproj/project/object/configuration'
require 'xcodeproj/project/object/file_reference'
require 'xcodeproj/project/object/group'
require 'xcodeproj/project/object/native_target'
