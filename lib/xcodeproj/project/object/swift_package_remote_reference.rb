module Xcodeproj
  class Project
    module Object
      # This class represents a Swift package reference.
      #
      class XCRemoteSwiftPackageReference < AbstractObject
        # @!group Attributes

        # @return [String] the repository url this Swift package was installed from.
        #
        attribute :repositoryURL, String

        # @return [Hash] the version requirements for this Swift package.
        #
        attribute :requirement, Hash
      end
    end
  end
end
