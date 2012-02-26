require 'fileutils'
require 'pathname'
require 'xcodeproj/xcodeproj_ext'

require 'xcodeproj/project/object'

module Xcodeproj
  class Project
    module Object
      class PBXProject < PBXObject
        has_many :targets, :class => PBXNativeTarget
        has_one :products, :singular_name => :products, :uuid => :productRefGroup, :class => PBXGroup
      end
    end

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

    def to_hash
      @plist
    end

    def objects_hash
      @plist['objects']
    end

    def objects
      @objects ||= PBXObjectList.new(Object::PBXObject, self, objects_hash)
    end

    def root_object
      objects[@plist['rootObject']]
    end

    def root_object=(object)
      @plist['rootObject'] = object.uuid
    end

    def groups
      objects.select_by_class(Object::PBXGroup)
    end
    
    def group(name)
      groups.object_named(name)
    end
    
    def main_group
      objects[root_object.attributes['mainGroup']]
    end

    def files
      objects.select_by_class(Object::PBXFileReference)
    end

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
