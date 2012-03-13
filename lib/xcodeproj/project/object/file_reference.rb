require 'xcodeproj/project/object/group'

module Xcodeproj
  class Project
    module Object

      # @todo Add a list of all possible file types for `explicit_file_type`
      #       and `last_known_file_type`.
      class PBXFileReference < AbstractGroupEntry
        # [String] the path to the file relative to the source tree
        attribute :path

        # [String] the source tree to which the file is relative. It can be one
        #          of `SOURCE_ROOT` or `SDKROOT`
        attribute :source_tree

        # [String] the file type regardless of what Xcode might think it is
        attribute :explicit_file_type

        # [String] the file type guessed by Xcode
        attribute :last_known_file_type

        # [String] wether of not this file should be indexed. This can be
        #          either "0" or "1".
        attribute :include_in_index

        has_many :build_files, :inverse_of => :file

        def self.new_static_library(project, product_name)
          new(project, nil,
            "includeInIndex" => "0",
            "sourceTree" => "BUILT_PRODUCTS_DIR",
            "path" => "lib#{product_name}.a"
          )
        end

        def initialize(*)
          super
          self.path = path if path # sets default name
          self.source_tree ||= 'SOURCE_ROOT'
          self.include_in_index ||= "1"
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
