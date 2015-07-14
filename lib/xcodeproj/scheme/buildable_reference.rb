module Xcodeproj
  class XCScheme
    class BuildableReference < XMLElementWrapper

      # @param [Xcodeproj::Project::Object::AbstractTarget, REXML::Element] target_or_node
      #        Either the Xcode target to reference, 
      #        or an existing XML 'BuildableReference' node element to reference
      #
      def initialize(target_or_node)
        create_xml_element_with_fallback(target_or_node, 'BuildableReference') do
          @xml_element.attributes['BuildableIdentifier'] = 'primary'
          self.set_reference_target(target_or_node, true) if target_or_node
        end
      end

      def target_name
        @xml_element.attributes['BlueprintName']
      end

      def target_uuid
        @xml_element.attributes['BlueprintIdentifier']
      end

      def target_referenced_container
        @xml_element.attributes['ReferencedContainer']
      end

      # Set the BlueprintIdentifier (target.uuid), BlueprintName (target.name)
      #     and TerefencedContainer (URI pointing to target's projet) all at once
      #
      # @param [Xcodeproj::Project::Object::AbstractTarget] target
      #        The target this BuildableReference refers to.
      #
      # @param [Bool] override_buildable_name
      #        If true, buildable_name will also be updated by computing a name from the target
      #
      def set_reference_target(target, override_buildable_name = false)
        @xml_element.attributes['BlueprintIdentifier'] = target.uuid
        @xml_element.attributes['BlueprintName'] = target.name
        @xml_element.attributes['ReferencedContainer'] = construct_referenced_container_uri(target)
        self.buildable_name = construct_buildable_name(target) if override_buildable_name
      end

      def buildable_name
        @xml_element.attributes['BuildableName']
      end

      def buildable_name=(value)
        @xml_element.attributes['BuildableName'] = value
      end

      #-------------------------------------------------------------------------#

      private

      # @!group Private helpers

      # @param [Xcodeproj::Project::Object::AbstractTarget] target
      #
      # @return [String] The buildable name of the scheme.
      #
      def construct_buildable_name(build_target)
        case build_target.isa
        when 'PBXNativeTarget'
          File.basename(build_target.product_reference.path)
        when 'PBXAggregateTarget'
          build_target.name
        else
          raise ArgumentError, "Unsupported build target type #{build_target.isa}"
        end
      end

      # @param [Xcodeproj::Project::Object::AbstractTarget] target
      #
      # @return [String] A string in the format "container:[path to the project
      #                  file relative to the project_dir_path, always ending with
      #                  the actual project directory name]"
      #
      def construct_referenced_container_uri(target)
        project = target.project
        relative_path = project.path.relative_path_from(project.path + project.root_object.project_dir_path).to_s
        relative_path = project.path.basename if relative_path == '.'
        "container:#{relative_path}"
      end
    end
  end
end