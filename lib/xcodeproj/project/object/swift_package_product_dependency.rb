module Xcodeproj
  class Project
    module Object
      # This class represents a Swift package product dependency.
      #
      class XCSwiftPackageProductDependency < AbstractObject
        # @!group Attributes

        # @return [XCRemoteSwiftPackageReference] the Swift package reference.
        #
        has_one :package, XCRemoteSwiftPackageReference

        # @return [String] the product name of this Swift package.
        #
        attribute :product_name, String
      end
    end
  end
end
