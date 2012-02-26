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

require 'xcodeproj/project/associations'
require 'xcodeproj/project/object_list'

# Now load the rest of the classes which inherit from PBXObject.
require 'xcodeproj/project/object/build_phase'
require 'xcodeproj/project/object/configuration'
require 'xcodeproj/project/object/file_reference'
require 'xcodeproj/project/object/group'
require 'xcodeproj/project/object/native_target'
