module Xcodeproj
  class Project
    module Object
      # This class represents a file system synchronized root group.
      class PBXFileSystemSynchronizedRootGroup < AbstractObject
        attribute :path, String
        attribute :source_tree, String, 'group'
        def display_name
          return path if path
          super
        end
      end
    end
  end
end
