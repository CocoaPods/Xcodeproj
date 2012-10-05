require 'active_support/inflector'

module Xcodeproj
  class Project
    # This is the namespace in which all the classes that wrap the objects in
    # a Xcode project reside.
    #
    # The base class from which all classes inherit is AbstractPBXObject.
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
      # be valid classes in a Xcode project. A new AbstractPBXObject subclass is
      # created for the constant and returned.
      #
      # @return [Class]  The generated class inhertiting from AbstractPBXObject.
      def self.const_missing(name)
        if name.to_s =~ /^(PBX|XC)/
          klass = Class.new(AbstractPBXObject)
          const_set(name, klass)
          klass
        else
          super
        end
      end

      # This is the base class of all object types that can exist in a Xcode
      # project. As such it provides common behavior, but you can only use
      # instances of subclasses of AbstractPBXObject, because this class does
      # not exist in actual Xcode projects.
      class AbstractPBXObject

        # This defines accessor methods for a key-value pair which occurs in the
        # attributes hash that the object wraps.
        #
        #
        # @example
        #
        #     # Create getter and setter methods named after the key it corresponds to
        #     # in the attributes hash:
        #
        #     class PBXBuildPhase < AbstractPBXObject
        #       attribute :settings
        #     end
        #
        #     build_phase.attributes # => { 'settings' => { 'COMPILER_FLAGS' => '-fobjc-arc' }, ... }
        #     build_phase.settings # => { 'COMPILER_FLAGS' => '-fobjc-arc' }
        #
        #     build_phase.settings = { 'COMPILER_FLAGS' => '-fobjc-no-arc' }
        #     build_phase.attributes # => { 'settings' => { 'COMPILER_FLAGS' => '-fobjc-no-arc' }, ... }
        #
        #     # Or with a custom getter and setter methods:
        #
        #     class PBXCopyFilesBuildPhase < AbstractPBXObject
        #       attribute :dst_path, :as => :destination_path
        #     end
        #
        #     build_phase.attributes # => { 'dstPath' => 'some/path', ... }
        #     build_phase.destination_path # => 'some/path'
        #
        #     build_phase.destination_path = 'another/path'
        #     build_phase.attributes # => { 'dstPath' => 'another/path', ... }
        #
        #
        # @param [Symbol, String] attribute_name  The key in snake case.
        # @option options [Symbol String] :as     An optional custom name for
        #                                         the getter and setter methods.
        def self.attribute(name, options = {})
          accessor_name  = (options[:as] || name).to_s
          attribute_name = name.to_s.camelize(:lower) # change `foo_bar' to `fooBar'
          define_method(accessor_name) { @attributes[attribute_name] }
          define_method("#{accessor_name}=") { |value| @attributes[attribute_name] = value }
        end

        def self.isa
          @isa ||= name.split('::').last
        end

        attr_reader :uuid, :attributes, :project

        # [Array<PBXObjectList>] an array of PBXObjectList that refers to this object
        attr_reader :referrers

        # [String] the object's class name
        attribute :isa

        # [String] the object's name
        attribute :name

        # It is not recommended that you instantiate objects through this
        # constructor. It is much easier to use associations to create them.
        #
        # @example
        #
        #     file_reference = project.files.new('path' => 'path/to/file')
        #
        # @return [AbstractPBXObject]
        def initialize(project, uuid, attributes)
          @project, @attributes = project, attributes
          self.isa ||= self.class.isa
          unless uuid
            # Add new objects to the main hash with a unique UUID
            uuid = generate_uuid
            @project.add_object_hash(uuid, @attributes)
          end
          @uuid = uuid
          @referrers = Array.new
        end

        def destroy
          @project.objects_hash.delete(uuid)
          @referrers.each { |referrer| referrer.delete(self) }
        end

        def ==(other)
          other.is_a?(AbstractPBXObject) && self.uuid == other.uuid
        end

        def <=>(other)
          self.uuid <=> other.uuid
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

        # Returns a PBXObjectList instance of objects in the `uuid_list`.
        #
        # By default this list will scope the list by objects matching the
        # specified class and add objects, pushed onto the list, to the given
        # `uuid_list` array.
        #
        # If a block is given the list instance is yielded so that the default
        # callbacks can be overridden.
        #
        # @param  [Array] uuid_list          The UUID array instance which is
        #                                    part of the internal data. If this
        #                                    would be an arbitrary array and an
        #                                    object is added, then it doesn't
        #                                    actually modify the internal data,
        #                                    meaning the change is lost.
        #
        # @param  [AbstractPBXObject] klass  The AbstractPBXObject subclass to
        #                                    which the list should be scoped.
        #
        # @yield  [PBXObjectList]            The list instance, allowing you to
        #                                    easily override the callbacks.
        #
        # @return [PBXObjectList<klass>]     The list of matching objects.
        def list_by_class(uuid_list, klass)
          PBXObjectList.new(klass, @project) do |list|
            list.let(:uuid_scope) do
              # TODO why does this not work? should be more efficient.
              #uuid_list.select do |uuid|
                #@project.objects_hash[uuid]['isa'] == klass.isa
              #end
              uuid_list.map { |uuid| @project.objects[uuid] }.select { |o| o.is_a?(klass) }.map(&:uuid)
            end
            list.let(:push) do |new_object|
              # Add the uuid of a newly created object to the uuids list
              uuid_list << new_object.uuid
            end
            yield list if block_given?
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
      end

    end
  end
end

require 'xcodeproj/project/association'
require 'xcodeproj/project/object_list'

# Now load the rest of the classes which inherit from AbstractPBXObject.
require 'xcodeproj/project/object/build_phase'
require 'xcodeproj/project/object/configuration'
require 'xcodeproj/project/object/file_reference'
require 'xcodeproj/project/object/group'
require 'xcodeproj/project/object/native_target'
