module Xcodeproj
  class Project
    module Object
      # This class represents a remote Swift package reference.
      #
      class XCRemoteSwiftPackageReference < AbstractObject
        # @!group Attributes

        # @return [String] the repository url this Swift package was installed from.
        #
        attribute :repositoryURL, String

        # @return [Hash] the version requirements for this Swift package.
        #
        attribute :requirement, Hash

        # @!group AbstractObject Hooks
        #--------------------------------------#

        def ascii_plist_annotation
          name = extract_package_name(display_name)
          " #{isa} \"#{name}\" "
        end

        # @return [String] the name of the remote Swift package reference.
        #
        def display_name
          return repositoryURL if repositoryURL
          super
        end

        private

        # Extracts package name from repository URL
        # Handles different URL formats:
        # - https://github.com/owner/repo.git -> repo
        # - https://github.com/owner/socket.io-client-swift -> socket
        # - git@github.com:owner/repo.git -> repo
        # - github.com/owner/repo -> repo
        # - domain.xyz (custom registry) -> xyz
        def extract_package_name(url)
          return url unless url

          # Remove .git extension first
          name = url.sub(/\.git$/, '')

          # Check if it's a URL with path (contains /)
          if name.include?('/')
            # Extract last path component (handle both / and :)
            name = name.split(/[\/:]/).last
            # If name contains a dot, use only the part before the first dot
            # e.g., socket.io-client-swift -> socket
            name = name.split('.').first if name.include?('.')
          elsif name.include?('.')
            # For other URLs (e.g., custom registry like domain.xyz), split by . and use last component
            name = name.split('.').last
          end

          name
        end
      end
    end
  end
end
