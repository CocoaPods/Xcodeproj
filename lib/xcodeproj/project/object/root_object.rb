module Xcodeproj
  class Project
    module Object

      # This class represents the root object of a project document.
      #
      class PBXProject < AbstractObject

        # @return [ObjectList<PBXNativeTarget>] a list of all the targets in
        #   the project.
        #
        has_many :targets, PBXNativeTarget

        # @return [Hash{String => String}] attributes the attributes of the
        #   target.
        #
        #   The hash might contain the following keys:
        #
        #   - `CLASSPREFIX`
        #   - `LastUpgradeCheck`
        #   - `ORGANIZATIONNAME`
        #
        attribute :attributes, Hash, {'LastUpgradeCheck' => '0450'}

        # @return [XCConfigurationList] the configuration list of the project.
        #
        has_one :build_configuration_list, XCConfigurationList

        # @return [String] the compatibility version of the project.
        #
        attribute :compatibility_version, String, 'Xcode 3.2'

        # @return [String] the development region of the project.
        #
        attribute :development_region, String, 'English'

        # @return [String] whether the project has scanned for encodings.
        #
        attribute :has_scanned_for_encodings, String, '0'

        # @return [Array<String>] the list of known regions.
        #
        attribute :known_regions, Array, ['en']

        # @return [PBXGroup] the main group of the project. The one displayed
        #   by Xcode in the Project Navigator.
        #
        has_one :main_group, PBXGroup

        # @return [PBXGroup] the group containing the references to products of
        #   the project.
        #
        has_one :product_ref_group, PBXGroup

        # @return [String] the directory of the project.
        #
        attribute :project_dir_path, String

        # @return [String] the root of the project.
        #
        attribute :project_root, String

      end
    end
  end
end
