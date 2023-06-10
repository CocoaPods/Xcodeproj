module Xcodeproj
  class Project
    module Object
      # This class represents a local Swift package reference.
      #
      class XCLocalSwiftPackageReference < AbstractObject
        # @!group Attributes

        # @return [String] the repository url this Swift package was installed from.
        #
        attribute :path, String

        # @!group AbstractObject Hooks
        #--------------------------------------#

        def ascii_plist_annotation
          " #{isa} \"#{File.basename(display_name)}\" "
        end

        # @return [String] the path of the local Swift package reference.
        #
        def display_name
          return path if path
          super
        end
      end
    end
  end
end
