require 'xcodeproj/project/object/file_system_synchronized_exception_set'

module Xcodeproj
  class Project
    module Object
      # This class represents a file system synchronized root group.
      class PBXFileSystemSynchronizedRootGroup < AbstractObject
        # @return [String] the directory to which the path is relative.
        #
        # @note   The accepted values are:
        #         - `<absolute>` for absolute paths
        #         - `<group>` for paths relative to the group
        #         - `SOURCE_ROOT` for paths relative to the project
        #         - `DEVELOPER_DIR` for paths relative to the developer
        #           directory.
        #         - `BUILT_PRODUCTS_DIR` for paths relative to the build
        #           products directory.
        #         - `SDKROOT` for paths relative to the SDK directory.
        #
        attribute :source_tree, String, '<group>'

        # @return [String] the path to a folder in the file system.
        #
        attribute :path, String

        # @return [String] Whether Xcode should use tabs for text alignment.
        #
        # @example
        #   `1`
        #
        attribute :uses_tabs, String

        # @return [String] The width of the indent.
        #
        # @example
        #   `2`
        #
        attribute :indent_width, String

        # @return [String] The width of the tabs.
        #
        # @example
        #   `2`
        #
        attribute :tab_width, String

        # @return [String] Whether Xcode should wrap lines.
        #
        # @example
        #   `1`
        #
        attribute :wraps_lines, String

        # @return [Array<PBXFileSystemSynchronizedBuildFileExceptionSet, PBXFileSystemSynchronizedGroupBuildPhaseMembershipExceptionSet>]
        #         The list of exceptions applying to this group.
        #
        has_many :exceptions, [PBXFileSystemSynchronizedBuildFileExceptionSet, PBXFileSystemSynchronizedGroupBuildPhaseMembershipExceptionSet]

        # @return [Hash] The files in the group that have a file type defined explicitly.
        #
        attribute :explicit_file_types, Hash

        # @return [Array] The folders in the group that are defined explicitly.
        #
        attribute :explicit_folders, Array

        def display_name
          return path if path
          super
        end

        def to_hash_as(method = :to_hash)
          hash_as = super
          excluded_keys_for_serialization_when_empty.each do |key|
            if !hash_as[key].nil? && hash_as[key].empty?
              hash_as.delete(key)
            end
          end
          hash_as
        end

        # @return [Array<String>] array of keys to exclude from serialization when the value is empty
        def excluded_keys_for_serialization_when_empty
          %w(exceptions)
        end
      end
    end
  end
end
