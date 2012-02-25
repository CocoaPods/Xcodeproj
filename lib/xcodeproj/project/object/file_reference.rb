module Xcodeproj
  class Project
    module Object

      class PBXFileReference < PBXObject
        attributes :path, :sourceTree, :explicitFileType, :lastKnownFileType, :includeInIndex
        has_many :buildFiles, :inverse_of => :file
        has_one :group, :inverse_of => :children

        def self.new_static_library(project, productName)
          new(project, nil, {
            "path"             => "lib#{productName}.a",
            "includeInIndex"   => "0", # no idea what this is
            "sourceTree"       => "BUILT_PRODUCTS_DIR",
          })
        end

        def initialize(project, uuid, attributes)
          is_new = uuid.nil?
          super
          self.path = path if path # sets default name
          self.sourceTree ||= 'SOURCE_ROOT'
          if is_new
            @project.main_group.children << self
          end
          set_default_file_type!
        end

        alias_method :_path=, :path=
        def path=(path)
          self._path = path
          self.name ||= pathname.basename.to_s
          path
        end

        def pathname
          Pathname.new(path)
        end

        def set_default_file_type!
          return if explicitFileType || lastKnownFileType
          case path
          when /\.a$/
            self.explicitFileType = 'archive.ar'
          when /\.framework$/
            self.lastKnownFileType = 'wrapper.framework'
          when /\.xcconfig$/
            self.lastKnownFileType = 'text.xcconfig'
          end
        end
      end

    end
  end
end
