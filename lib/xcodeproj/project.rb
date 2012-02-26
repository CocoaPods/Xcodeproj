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
  # Internally, the document is stored as a hash.
  class Project
    module Object
      class PBXProject < PBXObject
        has_many :targets, :class => PBXNativeTarget
        has_one :products, :singular_name => :products, :uuid => :productRefGroup, :class => PBXGroup
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
        self.root_object = objects.add(Object::PBXProject, {
          'attributes' => { 'LastUpgradeCheck' => '0420' },
          'compatibilityVersion' => 'Xcode 3.2',
          'developmentRegion' => 'English',
          'hasScannedForEncodings' => '0',
          'knownRegions' => ['en'],
          'mainGroup' => groups.new.uuid,
          'projectDirPath' => '',
          'projectRoot' => '',
          'targets' => []
        })
      end
    end

    # @return [Hash]  The internal data.
    def to_hash
      @plist
    end

    # @return [Hash]  The `objects` part of the internal data.
    def objects_hash
      @plist['objects']
    end

    # @return [PBXProject]  The root object of the project.
    def root_object
      objects[@plist['rootObject']]
    end

    # @param [PBXProject] object  The object to assign as the root object.
    def root_object=(object)
      @plist['rootObject'] = object.uuid
    end

    # @return [PBXObjectList<PBXObject>]  A list of all the objects in the
    #                                     project.
    def objects
      @objects ||= PBXObjectList.new(Object::PBXObject, self, objects_hash)
    end

    # @return [PBXObjectList<PBXGroup>]  A list of all the groups in the
    #                                    project.
    def groups
      objects.select_by_class(Object::PBXGroup)
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
      objects.select_by_class(Object::PBXFileReference)
    end

    # Adds a file reference for a system framework to the project.
    #
    # @example
    #
    #     project.add_system_framework('QuartzCore')
    #
    # @param [String] name        The name of a framework in the SDK System
    #                             directory.
    # @return [PBXFileReference]  The file reference object.
    def add_system_framework(name)
      files.new({
        'name' => "#{name}.framework",
        'path' => "System/Library/Frameworks/#{name}.framework",
        'sourceTree' => 'SDKROOT'
      })
    end

    def add_shell_script_build_phase(name, script_path)
      objects.add(Object::PBXShellScriptBuildPhase, {
        'name' => name,
        'files' => [],
        'inputPaths' => [],
        'outputPaths' => [],
        'shellPath' => '/bin/sh',
        'shellScript' => script_path
      })
    end

    def build_files
      objects.select_by_class(Object::PBXBuildFile)
    end

    def targets
      # Better to check the project object for targets to ensure they are
      # actually there so the project will work
      root_object.targets
    end

    def products
      root_object.products
    end

    # @private
    IGNORE_GROUPS = ['Frameworks', 'Products', 'Supporting Files']

    def source_files
      source_files = {}
      groups.each do |group|
        next if group.name.nil? || IGNORE_GROUPS.include?(group.name)
        source_files[group.name] = group.source_files.map(&:pathname)
      end
      source_files
    end

    def save_as(projpath)
      projpath = projpath.to_s
      FileUtils.mkdir_p(projpath)
      Xcodeproj.write_plist(@plist, File.join(projpath, 'project.pbxproj'))
    end
  end
end
