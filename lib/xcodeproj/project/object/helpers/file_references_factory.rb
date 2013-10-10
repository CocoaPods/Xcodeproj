require 'xcodeproj/project/object/helpers/groupable_helper'

module Xcodeproj
  class Project
    module Object
      class FileReferencesFactory
        class << self

          # Creates a new reference with the given path and adds it to the
          # given group. The reference is configured according to the extension
          # of the path.
          #
          # @param  [PBXGroup] group
          #         The group to which to add the reference.
          #
          # @param  [#to_s] path
          #         The, preferably absolute, path of the reference.
          #
          # @param  [Symbol] source_tree
          #         The source tree key to use to configure the path (@see
          #         GroupableHelper::SOURCE_TREES_BY_KEY).
          #
          # @return [PBXFileReference, XCVersionGroup] The new reference.
          #
          def new_reference(group, path, source_tree)
            if File.extname(path).downcase == '.xcdatamodeld'
              ref = new_xcdatamodeld(group, path, source_tree)
            else
              ref = new_file_reference(group, path, source_tree)
            end

            configure_defaults_for_file_reference(ref)
            ref
          end

          # Creates a file reference to a static library and adds it to the
          # given group.
          #
          # @param  [PBXGroup] group
          #         The group to which to add the reference.
          #
          # @param  [#to_s] product_name
          #         The name of the static library.
          #
          # @return [PBXFileReference] The new file reference.
          #
          def new_product_ref_for_target(group, target_name, product_type)
            if product_type == :static_library
              prefix = 'lib'
            end
            extension = Constants::PRODUCT_UTI_EXTENSIONS[product_type]
            ref = new_reference(group, "#{prefix}#{target_name}.#{extension}", :built_products)
            ref.include_in_index = '0'
            ref.set_explicit_file_type
            ref
          end

          # Creates a file reference to a new bundle and adds it to the given
          # group.
          #
          # @param  [PBXGroup] group
          #         The group to which to add the reference.
          #
          # @param  [#to_s] product_name
          #         The name of the bundle.
          #
          # @return [PBXFileReference] The new file reference.
          #
          def new_bundle(group, product_name)
            ref = new_reference(group, "#{product_name}.bundle", :built_products)
            ref.include_in_index = '0'
            ref.set_explicit_file_type("wrapper.cfbundle")
            ref
          end


          private

          # @group Private Helpers
          #-------------------------------------------------------------------#

          # Creates a new file reference with the given path and adds it to the
          # given group.
          #
          # @param  [PBXGroup] group
          #         The group to which to add the reference.
          #
          # @param  [#to_s] path
          #         The, preferably absolute, path of the reference.
          #
          # @param  [Symbol] source_tree
          #         The source tree key to use to configure the path (@see
          #         GroupableHelper::SOURCE_TREES_BY_KEY).
          #
          # @return [PBXFileReference] The new file reference.
          #
          def new_file_reference(group, path, source_tree)
            path = Pathname.new(path)
            ref = group.project.new(PBXFileReference)
            group.children << ref
            GroupableHelper.set_path_with_source_tree(ref, path, source_tree)
            ref.set_last_known_file_type
            ref
          end

          # Creates a new version group reference to an xcdatamodeled adding
          # the xcdatamodel files included in the wrapper as children file
          # references.
          #
          # @param  [PBXGroup] group
          #         The group to which to add the reference.
          #
          # @param  [#to_s] path
          #         The, preferably absolute, path of the reference.
          #
          # @param  [Symbol] source_tree
          #         The source tree key to use to configure the path (@see
          #         GroupableHelper::SOURCE_TREES_BY_KEY).
          #
          # @note  To match Xcode behaviour the current version is read from
          #         the .xccurrentversion file, if it doesn't exist the last
          #         xcdatamodel according to its path is set as the current
          #         version.
          #
          # @return [XCVersionGroup] The new reference.
          #
          def new_xcdatamodeld(group, path, source_tree)
            path = Pathname.new(path)
            ref = group.project.new(XCVersionGroup)
            group.children << ref
            GroupableHelper.set_path_with_source_tree(ref, path, source_tree)
            ref.version_group_type = 'wrapper.xcdatamodel'

            current_version_name = nil
            if path.exist?
              path.children.each do |child_path|
                if File.extname(child_path) == '.xcdatamodel'
                  child_ref = new_file_reference(ref, child_path, :group)
                  last_child_ref = child_ref
                elsif File.basename(child_path) == '.xccurrentversion'
                  full_path = path + File.basename(child_path)
                  xccurrentversion = Xcodeproj.read_plist(full_path)
                  current_version_name = xccurrentversion['_XCCurrentVersionName']
                end
              end

              if current_version_name
                ref.current_version = ref.children.find do |obj|
                    obj.path.split('/').last == current_version_name
                end
              end
            end

            ref
          end

          # Configures a file reference according to the extension to math
          # Xcode behaviour.
          #
          # @param  [PBXFileReference] ref
          #         The file reference to configure.
          #
          # @note   To closely match the Xcode behaviour the name attribute of
          #         the file reference is set only if the path of the file is
          #         not equal to the path of the group.
          #
          # @return [void]
          #
          def configure_defaults_for_file_reference(ref)
            if ref.path.include?('/')
              ref.name = ref.path.split('/').last
            end

            if File.extname(ref.path).downcase == '.framework'
              ref.include_in_index = nil
            end
          end

          #-------------------------------------------------------------------#

        end
      end
    end
  end
end

