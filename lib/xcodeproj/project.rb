require 'fileutils'
require 'pathname'
require 'xcodeproj/xcodeproj_ext'

require 'xcodeproj/project/object'

module Xcodeproj
  # This class represents a Xcode project document.
  #
  # It can be used to manipulate existing documents or even create new ones
  # from scratch.
  #
  # The Project API returns instances of AbstractPBXObject which wrap the objects
  # described in the Xcode project document.
  class Project
    module Object
      class PBXProject < AbstractPBXObject
        has_many :targets, :class => PBXNativeTarget
        has_one :products_group, :uuid => :product_ref_group, :class => PBXGroup
        has_one :build_configuration_list, :class => XCConfigurationList
      end
    end

    include Object

    # Opens a Xcode project document if a path to one is given, otherwise a new
    # Project is created.
    #
    # @param [Pathname, String] xcodeproj  The path to the Xcode project
    #                                      document (xcodeproj).
    #
    # @return [Project]                    A new Project instance or one with
    #                                      the data of an existing Xcode
    #                                      document.
    def initialize(xcodeproj = nil)
      if xcodeproj
        file = File.join(xcodeproj, 'project.pbxproj')
        @plist = Xcodeproj.read_plist(file.to_s)
      else
        @plist = {
          'archiveVersion' => '1',
          'classes' => {},
          'objectVersion' => '46',
          'objects' => {}
        }
        main_group = groups.new
        self.root_object = objects.add(PBXProject, {
          'attributes' => { 'LastUpgradeCheck' => '0450' },
          'compatibilityVersion' => 'Xcode 3.2',
          'developmentRegion' => 'English',
          'hasScannedForEncodings' => '0',
          'knownRegions' => ['en'],
          'mainGroup' => main_group.uuid,
          'productRefGroup' => main_group.groups.new('name' => 'Products').uuid,
          'projectDirPath' => '',
          'projectRoot' => '',
          'targets' => []
        })

        config_list = objects.add(XCConfigurationList)
        config_list.default_configuration_name = 'Release'
        config_list.default_configuration_is_visible = '0'
        config_list.build_configurations.new('name' => 'Debug')
        config_list.build_configurations.new('name' => 'Release')
        self.root_object.build_configuration_list = config_list

        # TODO make this work
        #self.root_object.product_reference = groups.new('name' => 'Products').uuid
      end
    end

    # @return [Hash]  The internal data.
    def to_hash
      @plist
    end

    def ==(other)
      other.respond_to?(:to_hash) && @plist == other.to_hash
    end

    # This gives access to the objects part of the internal data hash. It is,
    # however, **not** recommended to use this to add a hash for an object, for
    # that see `add_object_hash`.
    #
    # @return [Hash]  The `objects` part of the internal data.
    def objects_hash
      @plist['objects']
    end

    # This is the preferred way to add an object attributes hash to the objects
    # hash, as it validates the data before inserting it.
    #
    # @param [String] uuid        The UUID of the object.
    # @param [Hash]   attributes  The attributes of the object.
    #
    # @raise [ArgumentError]      Raised if the value of the `isa` key is equal
    #                             to `AbstractPBXObject`.
    #
    # @todo Ideally we would do more validation here, but I don't think we know
    #       of all classes that can exist yet.
    def add_object_hash(uuid, attributes)
      if attributes['isa'] !~ /^(PBX|XC)/
        raise ArgumentError, "Attempted to insert a `#{attributes['isa']}' instance into the objects hash, which is not allowed."
      end
      objects_hash[uuid] = attributes
    end

    # @return [PBXProject]  The root object of the project.
    def root_object
      objects[@plist['rootObject']]
    end

    # @param [PBXProject] object  The object to assign as the root object.
    def root_object=(object)
      @plist['rootObject'] = object.uuid
    end

    # @return [PBXObjectList<AbstractPBXObject>]  A list of all the objects in the
    #                                     project.
    def objects
      PBXObjectList.new(AbstractPBXObject, self) do |list|
        list.let(:uuid_scope) { objects_hash.keys }
      end
    end

    # @return [PBXObjectList<PBXGroup>]  A list of all the groups in the
    #                                    project.
    def groups
      objects.list_by_class(PBXGroup)
    end

    # Tries to find a group with the given name.
    #
    # @param [String] name     The name of the group to find.
    # @return [PBXGroup, nil]  The PBXgroup, if found.
    def group(name)
      groups.object_named(name)
    end

    # @return [PBXGroup]  The main top-level group.
    def main_group
      objects[root_object.attributes['mainGroup']]
    end

    # @return [PBXObjectList<PBXFileReference>]  A list of all the files in the
    #                                            project.
    def files
      objects.list_by_class(PBXFileReference)
    end

    # Adds a file reference for a system framework to the project.
    #
    # The file reference can then be added to the buildFiles of a
    # PBXFrameworksBuildPhase.
    #
    # @example
    #
    #     framework = project.add_system_framework('QuartzCore')
    #
    #     target = project.targets.first
    #     build_phase = target.frameworks_build_phases.first
    #     build_phase.files << framework.buildFiles.new
    #
    # @todo Make it possible to do: `build_phase << framework`
    #
    # @param [String] name        The name of a framework in the SDK System
    #                             directory.
    # @return [PBXFileReference]  The file reference object.
    def add_system_framework(name)
      path = "System/Library/Frameworks/#{name}.framework"
      if file = files.where(:path => path)
        file
      else
        group = groups.where('name' => 'Frameworks') || groups.new('name' => 'Frameworks')
        group.files.new({
          'name' => "#{name}.framework",
          'path' => path,
          'sourceTree' => 'SDKROOT'
        })
      end
    end

    # @return [PBXObjectList<XCBuildConfiguration>]  A list of project wide
    #                                                build configurations.
    def build_configurations
      root_object.build_configuration_list.build_configurations
    end

    # @param [String] name  The name of a project wide build configuration.
    #
    # @return [Hash]        The build settings of the project wide build
    #                       configuration with the given name.
    def build_settings(name)
      root_object.build_configuration_list.build_settings(name)
    end

    # @todo There are probably other target types too. E.g. an aggregate.
    #
    # @return [PBXObjectList<PBXNativeTarget>]  A list of all the targets in
    #                                           the project.
    def targets
      # Better to check the project object for targets to ensure they are
      # actually there so the project will work
      root_object.targets
    end

    # @return [PBXGroup]  The group which holds the product file references.
    def products_group
      root_object.products_group
    end

    # @return [PBXObjectList<PBXFileReference>]  A list of the product file
    #                                            references.
    def products
      products_group.children
    end

    # @private
    IGNORE_GROUPS = ['Frameworks', 'Products', 'Supporting Files']

    # @todo I think this is here because of easier testing in CocoaPods. Move
    #       this extension to the CocoaPods specs.
    #
    # @return [Hash]  A list of all the groups and their source files.
    def source_files
      source_files = {}
      groups.each do |group|
        next if group.name.nil? || IGNORE_GROUPS.include?(group.name)
        source_files[group.name] = group.source_files.map(&:pathname)
      end
      source_files
    end

    # Serializes the internal data as a property list and stores it on disk at
    # the given path.
    #
    # @example
    #
    #     project.save_as("path/to/Project.xcodeproj") # => true
    #
    # @param [String, Pathname] projpath  The path where the data should be
    #                                     stored.
    #
    # @return [true, false]               Returns whether or not saving was
    #                                     successful.
    def save_as(projpath)
      projpath = projpath.to_s
      FileUtils.mkdir_p(projpath)
      Xcodeproj.write_plist(@plist, File.join(projpath, 'project.pbxproj'))
    end
  end
end
