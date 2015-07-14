require 'xcodeproj/scheme/xml_element_wrapper'

module Xcodeproj
  class XCScheme
    # Scheme action for "Build"
    #
    # Note: It's not a AbstractSchemeAction like the others because it is
    # a special case of action (with no build_configuration, etc)
    #
    class BuildAction < XMLElementWrapper
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'BuildAction') do
          self.parallelize_buildables = true
          self.build_implicit_dependencies = true
        end
      end

      def parallelize_buildables?
        string_to_bool(@xml_element.attributes['parallelizeBuildables'])
      end

      def parallelize_buildables=(flag)
        @xml_element.attributes['parallelizeBuildables'] = bool_to_string(flag)
      end

      def build_implicit_dependencies?
        bool_to_string(@xml_element.attributes['buildImplicitDependencies'])
      end

      def build_implicit_dependencies=(flag)
        @xml_element.attributes['buildImplicitDependencies'] = bool_to_string(flag)
      end

      # [Array<BuildAction::Entry>]
      #
      def entries
        @xml_element.elements['BuildActionEntries'].get_elements('BuildActionEntry').map do |entry_node|
          BuildAction::Entry.new(entry_node)
        end
      end

      # @param [BuildAction::Entry] entry
      #
      def add_entry(entry)
        entries = @xml_element.elements['BuildActionEntries'] || @xml_element.add_element('BuildActionEntries')
        entries.add_element(entry.xml_element)
      end

      #-------------------------------------------------------------------------#

      class Entry < XMLElementWrapper
        # @param [Xcodeproj::Project::Object::AbstractTarget, REXML::Element] target_or_node
        #        Either the Xcode target to reference,
        #        or an existing XML 'BuildActionEntry' node element to reference,
        #        or nil to create an new, empty Entry with default values
        #
        def initialize(target_or_node = nil)
          create_xml_element_with_fallback(target_or_node, 'BuildActionEntry') do
            # Check target type to configure the default entry attributes accordingly
            is_test_target, is_app_target = [false, false]
            if target_or_node && target_or_node.is_a?(::Xcodeproj::Project::Object::PBXNativeTarget)
              test_types = [Constants::PRODUCT_TYPE_UTI[:octest_bundle], Constants::PRODUCT_TYPE_UTI[:unit_test_bundle]]
              app_types = [Constants::PRODUCT_TYPE_UTI[:application]]
              is_test_target = test_types.include?(target_or_node.product_type)
              is_app_target = app_types.include?(target_or_node.product_type)
            end

            self.build_for_analyzing = true
            self.build_for_testing   = is_test_target
            self.build_for_running   = is_app_target
            self.build_for_profiling = is_app_target
            self.build_for_archiving = is_app_target

            add_buildable_reference BuildableReference.new(target_or_node) if target_or_node
          end
        end

        def build_for_testing?
          string_to_bool(@xml_element.attributes['buildForTesting'])
        end

        def build_for_testing=(flag)
          @xml_element.attributes['buildForTesting'] = bool_to_string(flag)
        end

        def build_for_running?
          string_to_bool(@xml_element.attributes['buildForRunning'])
        end

        def build_for_running=(flag)
          @xml_element.attributes['buildForRunning'] = bool_to_string(flag)
        end

        def build_for_profiling?
          string_to_bool(@xml_element.attributes['buildForProfiling'])
        end

        def build_for_profiling=(flag)
          @xml_element.attributes['buildForProfiling'] = bool_to_string(flag)
        end

        def build_for_archiving?
          string_to_bool(@xml_element.attributes['buildForArchiving'])
        end

        def build_for_archiving=(flag)
          @xml_element.attributes['buildForArchiving'] = bool_to_string(flag)
        end

        def build_for_analyzing?
          string_to_bool(@xml_element.attributes['buildForAnalyzing'])
        end

        def build_for_analyzing=(flag)
          @xml_element.attributes['buildForAnalyzing'] = bool_to_string(flag)
        end

        # @return [Array<BuildableReference>]
        #
        def buildable_references
          @xml_element.get_elements('BuildableReference').map do |node|
            BuildableReference.new(node)
          end
        end

        # @param [BuildableReference] ref
        #
        def add_buildable_reference(ref)
          @xml_element.add_element(ref.xml_element)
        end
      end
    end
  end
end
