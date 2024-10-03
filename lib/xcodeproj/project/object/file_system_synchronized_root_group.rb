require 'xcodeproj/project/object/file_system_synchronized_build_file_exception_set'

module Xcodeproj
  class Project
    module Object
      # This class represents a file system synchronized root group.
      class PBXFileSystemSynchronizedRootGroup < AbstractObject
        attribute :path, String
        attribute :source_tree, String, 'group'
        has_many :exceptions, PBXFileSystemSynchronizedBuildFileExceptionSet

        def display_name
          return path if path
          super
        end
      end
    end
  end
end
