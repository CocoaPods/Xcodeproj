module Xcodeproj
  class Project
    module Object
      # This class represents the root object of a project document.
      #
      class PBXProject < AbstractObject
        # @!group Attributes

        # @return [ObjectList<AbstractTarget>] a list of all the targets in
        #         the project.
        #
        has_many :targets, AbstractTarget

        # @return [Hash{String => String}] attributes the attributes of the
        #         target.
        #
        # @note   The hash might contain the following keys:
        #
        #         - `CLASSPREFIX`
        #         - `LastUpgradeCheck`
        #         - `ORGANIZATIONNAME`
        #
        attribute :attributes, Hash,
                  'LastSwiftUpdateCheck' => Constants::LAST_SWIFT_UPGRADE_CHECK,
                  'LastUpgradeCheck' => Constants::LAST_UPGRADE_CHECK

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
        #         by Xcode in the Project Navigator.
        #
        has_one :main_group, PBXGroup

        # @return [PBXGroup] the group containing the references to products of
        #         the project.
        #
        has_one :product_ref_group, PBXGroup

        # @return [String] the directory of the project.
        #
        attribute :project_dir_path, String, ''

        # @return [String] the root of the project.
        #
        attribute :project_root, String, ''

        # @return [Array<ObjectDictionary>] any reference to other projects.
        #
        has_many_references_by_keys :project_references,
                                    :project_ref   => PBXFileReference,
                                    :product_group => PBXGroup
      end
    end
  end
end
