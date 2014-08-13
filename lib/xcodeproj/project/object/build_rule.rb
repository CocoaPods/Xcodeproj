module Xcodeproj
  class Project
    module Object
      # This class represents a custom build rule of a Target.
      #
      class PBXBuildRule < AbstractObject
        # @!group Attributes

        # @return [String] the name of the rule.
        #
        attribute :name, String

        # @return [String] a string representing what compiler to use.
        #
        # @example
        #   `com.apple.compilers.proxy.script`.
        #
        attribute :compiler_spec, String

        # @return [String] the type of the files that should be processed by
        #         this rule.
        #
        # @example
        #   `pattern.proxy`.
        #
        attribute :file_type, String

        # @return [String] the pattern of the files that should be processed by
        #         this rule. This attribute is an alternative to to
        #         `file_type`.
        #
        # @example
        #   `*.css`.
        #
        attribute :file_patterns, String

        # @return [String] whether the rule is editable.
        #
        # @example
        #   `1`.
        #
        attribute :is_editable, String, '1'

        # @return [ObjectList<PBXFileReference>] the file references for the
        #         output files.
        #
        attribute :output_files, Array

        # @return [String] the content of the script to use for the build rule.
        #
        # @note   This attribute is present if the #{#compiler_spec} is
        #         `com.apple.compilers.proxy.script`
        #
        attribute :script, String
      end
    end
  end
end
