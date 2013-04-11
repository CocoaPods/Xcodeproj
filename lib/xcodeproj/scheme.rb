require 'rexml/document'

module Xcodeproj
      
  # This class represents a Scheme document represented by a ".xcscheme" file usually stored
  # in a xcuserdata or xcshareddata (for a shared scheme) folder.
  # 
  class XCScheme
    
    # @return [REXML::Document] the XML object that will be manipulated to save the scheme file after.
    #
    attr_reader :doc
    
    # @return [String] the name of the container (the project name file without the extension) that have the targets
    # used by the scheme.
    #
    attr_reader :container

    # @return [Xcodeproj::Project::Object::AbstractTarget] the target used by scheme in the build step.
    #
    attr_reader :build_target

    # @return [Xcodeproj::Project::Object::AbstractTarget] the target used by scheme in the test step.
    #
    attr_reader :test_target

    # Share a User Scheme. Basically this method move the xcscheme file from the xcuserdata folder to xcshareddata
    # folder.
    #
    # @param project_path [String] Path of the .xcodeproj folder.
    #
    # @param scheme_name [String] The name of scheme that will be shared.
    #
    # @param user [String] The user name that have the scheme
    #
    def self.share_scheme(project_path, scheme_name, user = ENV['USER'])
      from = File.join project_path, 'xcuserdata', "#{user}.xcuserdatad", 'xcschemes', "#{scheme_name}.xcscheme"
      to_folder = File.join project_path, 'xcshareddata', 'xcschemes'
      Pathname(to_folder).mkpath
      to = File.join to_folder, "#{scheme_name}.xcscheme"
      FileUtils.mv from, to
    end

    # Create a new XCScheme instance
    #
    # @param [String] container
    #        The name of the container (the project name file without the extension) that have the targets used by the
    #        scheme.
    #
    # @param [Xcodeproj::Project::Object::AbstractTarget] build_target
    #        The target used by scheme in the build step.
    #
    # @param [Xcodeproj::Project::Object::AbstractTarget] test_target
    #        The target used by scheme in the test step.
    #
    # @example
    #   Xcodeproj::XCScheme.new 'Cocoa Application', project.targets[0], project.targets[1]
    #
    def initialize(container, build_target, test_target = nil)
      @container = container
      @build_target = build_target
      @test_target = test_target
      
      @doc = REXML::Document.new
      @doc << REXML::XMLDecl.new(REXML::XMLDecl::DEFAULT_VERSION, 'UTF-8')
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

      if (test_target != nil) then
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

    # Returns the current value if the build target must be runned during the build step.
    #
    # @return [Boolean]
    #         true  => run during the build step
    #         false => not run during the build step
    #
    def build_target_for_running?
      build_target_for_running = ''

      if build_action = @doc.root.elements['BuildAction']
        if build_action_entries = build_action.elements['BuildActionEntries']
          if build_action_entry = build_action_entries.elements['BuildActionEntry']
            build_target_for_running = build_action_entry.attributes['buildForRunning']
          end
        end
      end

      build_target_for_running == 'YES'
    end
    
    # Set the build target to run or not run during the build step.
    # Useful for cases where the build target is a unit test bundle.
    #
    # @param [Boolean] build_target_for_running
    #        true  => run during the build step
    #        false => not run during the build step
    #
    def build_target_for_running=(build_target_for_running)
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
        build_action_entry = build_action_entries.elements['BuildActionEntry']
      end
      
      build_action_entry.attributes['buildForRunning'] = build_target_for_running ? 'YES' : 'NO'
      
      if (build_action_entry.elements['BuildableReference'] == nil) then
        buildable_reference = build_action_entry.add_element 'BuildableReference'
        buildable_reference.attributes['BuildableIdentifier'] = 'primary'
        buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
        buildable_reference.attributes['BuildableName'] = "#{build_target.name}.octest"
        buildable_reference.attributes['BlueprintName'] = build_target.name
        buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
    end
    
    # Serializes the current state of the object to a String
    #
    # @return [String] the XML string value of the current state of the object
    #
    def to_s
      formatter = REXML::Formatters::Pretty.new(2)
      formatter.compact = true
      out = ''
      formatter.write(@doc, out)
      out
    end
    
    # Serializes the current state of the object to a ".xcscheme" file.
    #
    # @param [String, Pathname] project_path
    #        The path where the ".xcscheme" file should be stored.
    #
    # @param [Boolean] shared
    #        true  => if the scheme must be a shared scheme (default value)
    #        false => if the scheme must be a user scheme
    #
    # @return [void]
    #
    # @example Saving a scheme
    #   scheme.save_as('path/to/Project.xcodeproj') #=> true
    #
    def save_as(project_path, shared = true)
      if shared then
        scheme_folder_path = File.join(project_path, 'xcshareddata', 'xcschemes')
      else
        scheme_folder_path = File.join(project_path, 'xcuserdata', "#{ENV['USER']}.xcuserdatad", 'xcschemes')
      end
      Pathname(scheme_folder_path).mkpath
      scheme_path = File.join(scheme_folder_path, "#{build_target.display_name}.xcscheme")
      File.open(scheme_path, 'w') do |f|
        f.write(self)
      end
    end
    
  end
end
