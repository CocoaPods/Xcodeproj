module Xcodeproj
  class XCScheme
    # This class wraps the BuildableReference node of a .xcscheme XML file
    #
    # A BuildableReference is a reference to a buildable product (which is
    # typically is synonymous for an Xcode target)
    #
    class BuildableReference < XMLElementWrapper
      # @param [XScheme] scheme
      #        The scheme this element belongs to.
      #
      # @param [Xcodeproj::Project::Object::AbstractTarget, REXML::Element] target_or_node
      #        Either the Xcode target to reference,
      #        or an existing XML 'BuildableReference' node element to reference
      #
      def initialize(scheme, target_or_node)
        create_xml_element_with_fallback(target_or_node, 'BuildableReference', scheme) do
          @xml_element.attributes['BuildableIdentifier'] = 'primary'
          set_reference_target(target_or_node, true) if target_or_node
        end
      end

      # @return [String]
      #         The name of the target this Buildable Reference points to
      #
      def target_name
        @xml_element.attributes['BlueprintName']
      end

      # @return [String]
      #         The Unique Identifier of the target (target.uuid) this Buildable Reference points to.
      #
      # @note You can use this to `#find` the `Xcodeproj::Project::Object::AbstractTarget`
      #       instance in your Xcodeproj::Project object.
      #       e.g. `project.targets.find { |t| t.uuid == ref.target_uuid }`
      #
      def target_uuid
        @xml_element.attributes['BlueprintIdentifier']
      end

      # @return [String]
      #         The string representing the container of that target.
      #         Typically in the form of 'container:xxxx.xcodeproj'
      #
      def target_referenced_container
        @xml_element.attributes['ReferencedContainer']
      end

      # Set the BlueprintIdentifier (target.uuid), BlueprintName (target.name)
      #     and RerefencedContainer (URI pointing to target's projet) all at once
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

      # @return [String]
      #         The name of the final product when building this Buildable Reference
      #
      def buildable_name
        @xml_element.attributes['BuildableName']
      end

      # @param [String] value
      #        Set the name of the final product when building this Buildable Reference
      #
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
      #                  file relative to the bundle containing this scheme file
      #                  (ie. either a project or a workspace), always ending with
      #                  the actual project directory name]"
      #
      def construct_referenced_container_uri(target)
        project_path = target.project.path
        base = @scheme.bundle_path
        if base == nil then
          base = project_path
        end
        base = base.dirname
        relative_path = project_path.relative_path_from(base).to_s
        relative_path = project_path.basename if relative_path == "."
        "container:#{relative_path}"
      end
    end
  end
end
