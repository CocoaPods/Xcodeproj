require 'nokogiri'

module Xcodeproj
      
  class XCScheme
    
    attr :doc, Nokogiri::XML::Document
    
    attr :container, String
    attr :build_target, Xcodeproj::Project::Object::AbstractTarget
    attr :test_target, Xcodeproj::Project::Object::AbstractTarget
    
    def initialize(container, build_target, test_target)
      @container = container
      @build_target = build_target
      @test_target = test_target
      
      @doc = Nokogiri::XML::Document.new
      @doc.encoding = 'UTF-8'
      
      scheme = @doc << '<Scheme/>'
      scheme['LastUpgradeVersion'] = build_target.project.root_object.attributes['LastUpgradeCheck']
      scheme['version'] = '1.3'
      
      build_action = scheme.add_child('<BuildAction/>').first
      build_action['parallelizeBuildables'] = 'YES'
      build_action['buildImplicitDependencies'] = 'YES'
      
      if (build_target.product_type == 'com.apple.product-type.application') then
        build_action_entries = build_action.add_child('<BuildActionEntries/>').first
        
        build_action_entry = build_action_entries.add_child('<BuildActionEntry/>').first
        build_action_entry['buildForTesting'] = 'YES'
        build_action_entry['buildForRunning'] = 'YES'
        build_action_entry['buildForProfiling'] = 'YES'
        build_action_entry['buildForArchiving'] = 'YES'
        build_action_entry['buildForAnalyzing'] = 'YES'
      
        buildable_reference = build_action_entry.add_child('<BuildableReference/>').first
        buildable_reference['BuildableIdentifier'] = 'primary'
        buildable_reference['BlueprintIdentifier'] = build_target.uuid
        buildable_reference['BuildableName'] = "#{build_target.name}.app"
        buildable_reference['BlueprintName'] = build_target.name
        buildable_reference['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
      
      test_action = scheme.add_child('<TestAction/>').first
      test_action['selectedDebuggerIdentifier'] = 'Xcode.DebuggerFoundation.Debugger.LLDB'
      test_action['selectedLauncherIdentifier'] = 'Xcode.DebuggerFoundation.Launcher.LLDB'
      test_action['shouldUseLaunchSchemeArgsEnv'] = 'YES'
      test_action['buildConfiguration'] = 'Debug'
      
      testables = test_action.add_child('<Testables/>').first
      
      testable_reference = testables.add_child('<TestableReference/>').first
      testable_reference['skipped'] = 'NO'
      
      buildable_reference = testable_reference.add_child('<BuildableReference/>').first
      buildable_reference['BuildableIdentifier'] = 'primary'
      buildable_reference['BlueprintIdentifier'] = test_target.uuid
      buildable_reference['BuildableName'] = "#{test_target.name}.octest"
      buildable_reference['BlueprintName'] = test_target.name
      buildable_reference['ReferencedContainer'] = "container:#{container}.xcodeproj"
      
      if (build_target.product_type == 'com.apple.product-type.application') then
        macro_expansion = test_action.add_child('<MacroExpansion/>').first
      
        buildable_reference = macro_expansion.add_child('<BuildableReference/>').first
        buildable_reference['BuildableIdentifier'] = 'primary'
        buildable_reference['BlueprintIdentifier'] = build_target.uuid
        buildable_reference['BuildableName'] = "#{build_target.name}.app"
        buildable_reference['BlueprintName'] = build_target.name
        buildable_reference['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
      
      launch_action = scheme.add_child('<LaunchAction/>').first
      launch_action['selectedDebuggerIdentifier'] = 'Xcode.DebuggerFoundation.Debugger.LLDB'
      launch_action['selectedLauncherIdentifier'] = 'Xcode.DebuggerFoundation.Launcher.LLDB'
      launch_action['launchStyle'] = '0'
      launch_action['useCustomWorkingDirectory'] = 'NO'
      launch_action['buildConfiguration'] = 'Debug'
      launch_action['ignoresPersistentStateOnLaunch'] = 'NO'
      launch_action['debugDocumentVersioning'] = 'YES'
      launch_action['allowLocationSimulation'] = 'YES'
      
      if (build_target.product_type == 'com.apple.product-type.application') then
        buildable_product_runnable = launch_action.add_child('<BuildableProductRunnable/>').first
      
        buildable_reference = buildable_product_runnable.add_child('<BuildableReference/>').first
        buildable_reference['BuildableIdentifier'] = 'primary'
        buildable_reference['BlueprintIdentifier'] = build_target.uuid
        buildable_reference['BuildableName'] = "#{build_target.name}.app"
        buildable_reference['BlueprintName'] = build_target.name
        buildable_reference['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
      
      additional_options = launch_action.add_child('<AdditionalOptions/>').first
      
      profile_action = scheme.add_child('<ProfileAction/>').first
      profile_action['shouldUseLaunchSchemeArgsEnv'] = 'YES'
      profile_action['savedToolIdentifier'] = ''
      profile_action['useCustomWorkingDirectory'] = 'NO'
      profile_action['buildConfiguration'] = 'Release'
      profile_action['debugDocumentVersioning'] = 'YES'
      
      if (build_target.product_type == 'com.apple.product-type.application') then
        buildable_product_runnable = profile_action.add_child('<BuildableProductRunnable/>').first
      
        buildable_reference = buildable_product_runnable.add_child('<BuildableReference/>').first
        buildable_reference['BuildableIdentifier'] = 'primary'
        buildable_reference['BlueprintIdentifier'] = build_target.uuid
        buildable_reference['BuildableName'] = "#{build_target.name}.app"
        buildable_reference['BlueprintName'] = build_target.name
        buildable_reference['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
      
      analyze_action = scheme.add_child('<AnalyzeAction/>').first
      analyze_action['buildConfiguration'] = 'Debug'
      
      archive_action = scheme.add_child('<ArchiveAction/>').first
      archive_action['buildConfiguration'] = 'Release'
      archive_action['revealArchiveInOrganizer'] = 'YES'
    end
    
    def set_build_target_for_running(value)
      build_action = @doc.root.children.at('BuildAction')
      
      if (build_action.children.at('BuildActionEntries') == nil) then
        build_action_entries = build_action.add_child('<BuildActionEntries/>').first
      else
        build_action_entries = build_action.children.at('BuildActionEntries').first
      end
      
      if (build_action_entries.children.at('BuildActionEntry') == nil) then
        build_action_entry = build_action_entries.add_child('<BuildActionEntry/>').first
        build_action_entry['buildForTesting'] = 'YES'
        build_action_entry['buildForProfiling'] = 'NO'
        build_action_entry['buildForArchiving'] = 'NO'
        build_action_entry['buildForAnalyzing'] = 'NO'
      else
        build_action_entry = build_action.children.at('BuildActionEntry').first
      end
      
      build_action_entry['buildForRunning'] = value
      
      if (build_action_entry.children.at('BuildableReference') == nil) then
        buildable_reference = build_action_entry.add_child('<BuildableReference/>').first
        buildable_reference['BuildableIdentifier'] = 'primary'
        buildable_reference['BlueprintIdentifier'] = build_target.uuid
        buildable_reference['BuildableName'] = "#{build_target.name}.octest"
        buildable_reference['BlueprintName'] = build_target.name
        buildable_reference['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
    end
    
    def to_s
      @doc.to_xml
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
