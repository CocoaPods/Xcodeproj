module Xcodeproj
  class Project
    module Object

      # This class represents a custom build rule of a Target.
      #
      class PBXBuildRule < AbstractObject

        # @return [String] the name of the rule.
        #
        attribute :name, String

        # @return [String] a string representing what compiler to use.
        #
        #   E.g. `com.apple.compilers.proxy.script`.
        #
        attribute :compiler_spec, String

        # @return [String] the type of the files that should be processed by
        #   this rule.
        #
        #   E.g. `pattern.proxy`.
        #
        attribute :file_type, String

        # @return [String] whether the rule is editable.
        #
        #   E.g. `1`.
        #
        attribute :is_editable, String, '1'

        # @return [ObjectList<PBXFileReference>] the file references for the
        #   output files.
        #
        has_many :output_files, PBXFileReference

        # @return [String] the content of the script to use for the build rule.
        #
        #   Present if the #{#compiler_spec} is `com.apple.compilers.proxy.script`
        #
        attribute :script, String

      end
    end
  end
end
