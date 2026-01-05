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
        # - git@github.com:owner/repo.git -> repo
        # - domain.xyz (custom registry) -> xyz
        def extract_package_name(url)
          return url unless url

          # Remove .git extension first
          name = url.sub(/\.git$/, '')
          
          # Check if it's a URL with https:// or git@ prefix
          if name.start_with?('https://') || name.start_with?('git@')
            # Extract last path component (handle both / and :)
            name = name.split(/[\/:]/).last
          else
            # For other URLs (e.g., custom registry), split by . and use last component
            name = name.split('.').last if name.include?('.')
          end
          
          name
        end
      end
    end
  end
end
