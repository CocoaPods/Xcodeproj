require 'rexml/document'

module Xcodeproj
      
  class XCScheme
    
    attr :doc, REXML::Document
    
    attr :container, String
    attr :build_target, Xcodeproj::Project::Object::AbstractTarget
    attr :test_target, Xcodeproj::Project::Object::AbstractTarget
    
    def initialize(container, build_target, test_target)
      @container = container
      @build_target = build_target
      @test_target = test_target
      
      @doc = REXML::Document.new
      @doc << REXML::XMLDecl.new(REXML::XMLDecl::DEFAULT_VERSION, REXML::Encoding::UTF_8)
      @doc.context[:attribute_quote] = :quote
      
      scheme = @doc.add_element 'Scheme'
      scheme.attributes['LastUpgradeVersion'] = build_target.project.root_object.attributes['LastUpgradeCheck']
      scheme.attributes['version'] = '1.3'
      
      build_action = scheme.add_element 'BuildAction'
      build_action.attributes['parallelizeBuildables'] = 'YES'
      build_action.attributes['buildImplicitDependencies'] = 'YES'
      
      if (build_target.product_type == 'com.apple.product-type.application') then
        build_action_entries = build_action.add_element 'BuildActionEntries'
        
        build_action_entry = build_action_entries.add_element 'BuildActionEntry'
        build_action_entry.attributes['buildForTesting'] = 'YES'
        build_action_entry.attributes['buildForRunning'] = 'YES'
        build_action_entry.attributes['buildForProfiling'] = 'YES'
        build_action_entry.attributes['buildForArchiving'] = 'YES'
        build_action_entry.attributes['buildForAnalyzing'] = 'YES'
      
        buildable_reference = build_action_entry.add_element 'BuildableReference'
        buildable_reference.attributes['BuildableIdentifier'] = 'primary'
        buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
        buildable_reference.attributes['BuildableName'] = "#{build_target.name}.app"
        buildable_reference.attributes['BlueprintName'] = build_target.name
        buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
      
      test_action = scheme.add_element 'TestAction'
      test_action.attributes['selectedDebuggerIdentifier'] = 'Xcode.DebuggerFoundation.Debugger.LLDB'
      test_action.attributes['selectedLauncherIdentifier'] = 'Xcode.DebuggerFoundation.Launcher.LLDB'
      test_action.attributes['shouldUseLaunchSchemeArgsEnv'] = 'YES'
      test_action.attributes['buildConfiguration'] = 'Debug'
      
      testables = test_action.add_element 'Testables'
      
      testable_reference = testables.add_element 'TestableReference'
      testable_reference.attributes['skipped'] = 'NO'
      
      buildable_reference = testable_reference.add_element 'BuildableReference'
      buildable_reference.attributes['BuildableIdentifier'] = 'primary'
      buildable_reference.attributes['BlueprintIdentifier'] = test_target.uuid
      buildable_reference.attributes['BuildableName'] = "#{test_target.name}.octest"
      buildable_reference.attributes['BlueprintName'] = test_target.name
      buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
      
      if (build_target.product_type == 'com.apple.product-type.application') then
        macro_expansion = test_action.add_element 'MacroExpansion'
      
        buildable_reference = macro_expansion.add_element 'BuildableReference'
        buildable_reference.attributes['BuildableIdentifier'] = 'primary'
        buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
        buildable_reference.attributes['BuildableName'] = "#{build_target.name}.app"
        buildable_reference.attributes['BlueprintName'] = build_target.name
        buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
      
      launch_action = scheme.add_element 'LaunchAction'
      launch_action.attributes['selectedDebuggerIdentifier'] = 'Xcode.DebuggerFoundation.Debugger.LLDB'
      launch_action.attributes['selectedLauncherIdentifier'] = 'Xcode.DebuggerFoundation.Launcher.LLDB'
      launch_action.attributes['launchStyle'] = '0'
      launch_action.attributes['useCustomWorkingDirectory'] = 'NO'
      launch_action.attributes['buildConfiguration'] = 'Debug'
      launch_action.attributes['ignoresPersistentStateOnLaunch'] = 'NO'
      launch_action.attributes['debugDocumentVersioning'] = 'YES'
      launch_action.attributes['allowLocationSimulation'] = 'YES'
      
      if (build_target.product_type == 'com.apple.product-type.application') then
        buildable_product_runnable = launch_action.add_element 'BuildableProductRunnable'
      
        buildable_reference = buildable_product_runnable.add_element 'BuildableReference'
        buildable_reference.attributes['BuildableIdentifier'] = 'primary'
        buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
        buildable_reference.attributes['BuildableName'] = "#{build_target.name}.app"
        buildable_reference.attributes['BlueprintName'] = build_target.name
        buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
      
      additional_options = launch_action.add_element 'AdditionalOptions'
      
      profile_action = scheme.add_element 'ProfileAction'
      profile_action.attributes['shouldUseLaunchSchemeArgsEnv'] = 'YES'
      profile_action.attributes['savedToolIdentifier'] = ''
      profile_action.attributes['useCustomWorkingDirectory'] = 'NO'
      profile_action.attributes['buildConfiguration'] = 'Release'
      profile_action.attributes['debugDocumentVersioning'] = 'YES'
      
      if (build_target.product_type == 'com.apple.product-type.application') then
        buildable_product_runnable = profile_action.add_element 'BuildableProductRunnable'
      
        buildable_reference = buildable_product_runnable.add_element 'BuildableReference'
        buildable_reference.attributes['BuildableIdentifier'] = 'primary'
        buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
        buildable_reference.attributes['BuildableName'] = "#{build_target.name}.app"
        buildable_reference.attributes['BlueprintName'] = build_target.name
        buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
      
      analyze_action = scheme.add_element 'AnalyzeAction'
      analyze_action.attributes['buildConfiguration'] = 'Debug'
      
      archive_action = scheme.add_element 'ArchiveAction'
      archive_action.attributes['buildConfiguration'] = 'Release'
      archive_action.attributes['revealArchiveInOrganizer'] = 'YES'
    end
    
    def set_build_target_for_running(value)
      build_action = @doc.root.elements['BuildAction']
      
      if (build_action.elements['BuildActionEntries'] == nil) then
        build_action_entries = build_action.add_element 'BuildActionEntries'
      else
        build_action_entries = build_action.elements['BuildActionEntries']
      end
      
      if (build_action_entries.elements['BuildActionEntry'] == nil) then
        build_action_entry = build_action_entries.add_element 'BuildActionEntry'
        build_action_entry.attributes['buildForTesting'] = 'YES'
        build_action_entry.attributes['buildForProfiling'] = 'NO'
        build_action_entry.attributes['buildForArchiving'] = 'NO'
        build_action_entry.attributes['buildForAnalyzing'] = 'NO'
      else
        build_action_entry = build_action.children.at('BuildActionEntry').first
      end
      
      build_action_entry.attributes['buildForRunning'] = value
      
      if (build_action_entry.elements['BuildableReference'] == nil) then
        buildable_reference = build_action_entry.add_element 'BuildableReference'
        buildable_reference.attributes['BuildableIdentifier'] = 'primary'
        buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
        buildable_reference.attributes['BuildableName'] = "#{build_target.name}.octest"
        buildable_reference.attributes['BlueprintName'] = build_target.name
        buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
    end
    
    def to_s
      formatter = REXML::Formatters::Pretty.new(2)
      formatter.compact = true
      out = ''
      formatter.write(@doc, out)
      out
    end
    
    def save_as(project_path)
      scheme_folder_path = File.join(project_path, 'xcshareddata', 'xcschemes')
      Pathname(scheme_folder_path).mkpath
      scheme_path = File.join(scheme_folder_path, "#{build_target.display_name}.xcscheme")
      File.open(scheme_path, 'w') do |f|
        f.write(self)
      end
    end
    
  end
end
