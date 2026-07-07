require 'xcodeproj/project/object_attributes'
require 'xcodeproj/project/object/helpers/groupable_helper'

module Xcodeproj
  class Project
    module Object
      # This class represents a file system synchronized build file exception set.
      class PBXFileSystemSynchronizedBuildFileExceptionSet < AbstractObject
        # @return [AbstractTarget] The target to which this exception set applies.
        #
        has_one :target, AbstractTarget

        # @return [Array<String>] The list of files in the group that are excluded from the target.
        #
        attribute :membership_exceptions, Array

        # @return [Array<String>] The list of public headers.
        #
        attribute :public_headers, Array

        # @return [Array<String>] The list of private headers.
        #
        attribute :private_headers, Array

        # @return [Hash] The files with specific compiler flags.
        #
        attribute :additional_compiler_flags_by_relative_path, Hash

        # @return [Hash] The files with on demand resource tags.
        #
        attribute :asset_tags_by_relative_path, Hash

        # @return [Hash] The files with specific attributes.
        #
        attribute :attributes_by_relative_path, Hash

        # @return [Hash] The files with a platform filter.
        #
        attribute :platform_filters_by_relative_path, Hash

        # Xcode builds the comment by combining the referencing root group (folder)
        # with the target name, as `Exceptions for "<folder>" folder in "<target>" target`.
        def display_name
          root_group = referrers.find { |referrer| referrer.is_a?(PBXFileSystemSynchronizedRootGroup) }
          if root_group && target
            %(Exceptions for "#{root_group.display_name}" folder in "#{target.display_name}" target)
          else
            'PBXFileSystemSynchronizedBuildFileExceptionSet'
          end
        end
      end

      # This class represents a file system synchronized group build phase membership exception set.
      class PBXFileSystemSynchronizedGroupBuildPhaseMembershipExceptionSet < AbstractObject
        # @return [PBXSourcesBuildPhase, PBXCopyFilesBuildPhase] The build phase to which this exception set applies.
        #
        has_one :build_phase, [PBXSourcesBuildPhase, PBXCopyFilesBuildPhase]

        # @return [Array<String>] The list of files in the group that are excluded from the build phase.
        #
        attribute :membership_exceptions, Array

        # @return [Hash] The files with specific attributes.
        #
        attribute :attributes_by_relative_path, Hash

        # @return [Hash] The files with a platform filter.
        #
        attribute :platform_filters_by_relative_path, Hash

        # Xcode builds the comment by combining the root group (folder), the build
        # phase, and the target that owns the build phase, as
        # `Exceptions for "<folder>" folder in "<phase>" phase from "<target>" target`.
        def display_name
          root_group = referrers.find { |referrer| referrer.is_a?(PBXFileSystemSynchronizedRootGroup) }
          phase_target = build_phase && build_phase.referrers.find { |referrer| referrer.is_a?(AbstractTarget) }
          if root_group && build_phase && phase_target
            %(Exceptions for "#{root_group.display_name}" folder in "#{build_phase.display_name}" phase from "#{phase_target.display_name}" target)
          else
            'PBXFileSystemSynchronizedGroupBuildPhaseMembershipExceptionSet'
          end
        end
      end
    end
  end
end
