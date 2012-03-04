module Xcodeproj
  class Project
    module Object

      class PBXFileReference < PBXObject
        attributes :path, :source_tree, :explicit_file_type, :last_known_file_type, :include_in_index
        has_many :build_files, :inverse_of => :file
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
          self.source_tree ||= 'SOURCE_ROOT'
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
          return if explicit_file_type || last_known_file_type
          case path
          when /\.a$/
            self.explicit_file_type = 'archive.ar'
          when /\.framework$/
            self.last_known_file_type = 'wrapper.framework'
          when /\.xcconfig$/
            self.last_known_file_type = 'text.xcconfig'
          end
        end
      end

    end
  end
end
