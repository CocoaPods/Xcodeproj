require 'rexml/document'

module Xcodeproj

  # This class represents a Scheme document represented by a ".xcscheme" file
  # usually stored in a xcuserdata or xcshareddata (for a shared scheme)
  # folder.
  #
  class XCScheme

    # @return [REXML::Document] the XML object that will be manipulated to save
    #         the scheme file after.
    #
    attr_reader :doc

    # Create a new XCScheme instance
    #
    def initialize
      @doc = REXML::Document.new
      @doc << REXML::XMLDecl.new(REXML::XMLDecl::DEFAULT_VERSION, 'UTF-8')
      @doc.context[:attribute_quote] = :quote

      @scheme = @doc.add_element 'Scheme'
      @scheme.attributes['LastUpgradeVersion'] = Constants::LAST_UPGRADE_CHECK
      @scheme.attributes['version'] = '1.3'

      @build_action = @scheme.add_element 'BuildAction'
      @build_action.attributes['parallelizeBuildables'] = 'YES'
      @build_action.attributes['buildImplicitDependencies'] = 'YES'
      @build_action_entries = nil

      @test_action = @scheme.add_element 'TestAction'
      @test_action.attributes['selectedDebuggerIdentifier'] = 'Xcode.DebuggerFoundation.Debugger.LLDB'
      @test_action.attributes['selectedLauncherIdentifier'] = 'Xcode.DebuggerFoundation.Launcher.LLDB'
      @test_action.attributes['shouldUseLaunchSchemeArgsEnv'] = 'YES'
      @test_action.attributes['buildConfiguration'] = 'Debug'

      @testables = @test_action.add_element 'Testables'

      @launch_action = @scheme.add_element 'LaunchAction'
      @launch_action.attributes['selectedDebuggerIdentifier'] = 'Xcode.DebuggerFoundation.Debugger.LLDB'
      @launch_action.attributes['selectedLauncherIdentifier'] = 'Xcode.DebuggerFoundation.Launcher.LLDB'
      @launch_action.attributes['launchStyle'] = '0'
      @launch_action.attributes['useCustomWorkingDirectory'] = 'NO'
      @launch_action.attributes['buildConfiguration'] = 'Debug'
      @launch_action.attributes['ignoresPersistentStateOnLaunch'] = 'NO'
      @launch_action.attributes['debugDocumentVersioning'] = 'YES'
      @launch_action.attributes['allowLocationSimulation'] = 'YES'
      additional_options = @launch_action.add_element 'AdditionalOptions'

      @profile_action = @scheme.add_element 'ProfileAction'
      @profile_action.attributes['shouldUseLaunchSchemeArgsEnv'] = 'YES'
      @profile_action.attributes['savedToolIdentifier'] = ''
      @profile_action.attributes['useCustomWorkingDirectory'] = 'NO'
      @profile_action.attributes['buildConfiguration'] = 'Release'
      @profile_action.attributes['debugDocumentVersioning'] = 'YES'

      analyze_action = @scheme.add_element 'AnalyzeAction'
      analyze_action.attributes['buildConfiguration'] = 'Debug'

      archive_action = @scheme.add_element 'ArchiveAction'
      archive_action.attributes['buildConfiguration'] = 'Release'
      archive_action.attributes['revealArchiveInOrganizer'] = 'YES'
    end

    public

    # @!group Target methods

    # Add a target to the list of targets to build in the build action.
    #
    # @param [Xcodeproj::Project::Object::AbstractTarget] build_target
    #        A target used by scheme in the build step.
    #
    # @param [String] container
    #        The name of the container (the project name file without the extension) that has this target.
    #
    # @param [Bool] build_for_running
    #        Whether to build this target in the launch action. Often false for test targets.
    #
    def add_build_target(build_target, container, build_for_running = true)
      if !@build_action_entries then
        @build_action_entries = @build_action.add_element 'BuildActionEntries'
      end

      build_action_entry = @build_action_entries.add_element 'BuildActionEntry'
      build_action_entry.attributes['buildForTesting'] = 'YES'
      build_action_entry.attributes['buildForRunning'] = build_for_running ? 'YES' : 'NO'
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

    # Add a target to the list of targets to build in the build action.
    #
    # @param [Xcodeproj::Project::Object::AbstractTarget] test_target
    #        A target used by scheme in the test step.
    #
    # @param [String] container
    #        The name of the container (the project name file without the extension) that has this target.
    #
    def add_test_target(test_target, container)
      testable_reference = @testables.add_element 'TestableReference'
      testable_reference.attributes['skipped'] = 'NO'

      buildable_reference = testable_reference.add_element 'BuildableReference'
      buildable_reference.attributes['BuildableIdentifier'] = 'primary'
      buildable_reference.attributes['BlueprintIdentifier'] = test_target.uuid
      buildable_reference.attributes['BuildableName'] = "#{test_target.name}.octest"
      buildable_reference.attributes['BlueprintName'] = test_target.name
      buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
    end

    # Sets a runnable target target to be the target of the launch action of the scheme.
    #
    # @param [Xcodeproj::Project::Object::AbstractTarget] build_target
    #        A target used by scheme in the launch step.
    #
    # @param [String] container
    #        The name of the container (the project name file without the extension) that has this target.
    #
    def set_launch_target(build_target, container)
      launch_product_runnable = @launch_action.add_element 'BuildableProductRunnable'

      launch_buildable_reference = launch_product_runnable.add_element 'BuildableReference'
      launch_buildable_reference.attributes['BuildableIdentifier'] = 'primary'
      launch_buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
      launch_buildable_reference.attributes['BuildableName'] = "#{build_target.name}.app"
      launch_buildable_reference.attributes['BlueprintName'] = build_target.name
      launch_buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"

      profile_product_runnable = @profile_action.add_element 'BuildableProductRunnable'

      profile_buildable_reference = profile_product_runnable.add_element 'BuildableReference'
      profile_buildable_reference.attributes['BuildableIdentifier'] = 'primary'
      profile_buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
      profile_buildable_reference.attributes['BuildableName'] = "#{build_target.name}.app"
      profile_buildable_reference.attributes['BlueprintName'] = build_target.name
      profile_buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"

      if build_target.product_type == 'com.apple.product-type.application' then
        macro_expansion = @test_action.add_element 'MacroExpansion'

        buildable_reference = macro_expansion.add_element 'BuildableReference'
        buildable_reference.attributes['BuildableIdentifier'] = 'primary'
        buildable_reference.attributes['BlueprintIdentifier'] = build_target.uuid
        buildable_reference.attributes['BuildableName'] = "#{build_target.name}.app"
        buildable_reference.attributes['BlueprintName'] = build_target.name
        buildable_reference.attributes['ReferencedContainer'] = "container:#{container}.xcodeproj"
      end
    end

    # @!group Class methods

    #-------------------------------------------------------------------------#

    # Share a User Scheme. Basically this method move the xcscheme file from
    # the xcuserdata folder to xcshareddata folder.
    #
    # @param  [String] project_path
    #         Path of the .xcodeproj folder.
    #
    # @param  [String] scheme_name
    #         The name of scheme that will be shared.
    #
    # @param  [String] user
    #         The user name that have the scheme.
    #
    def self.share_scheme(project_path, scheme_name, user = nil)
      to_folder = shared_data_dir(project_path)
      to_folder.mkpath
      to = to_folder + "#{scheme_name}.xcscheme"
      from = self.user_data_dir(project_path, user) + "#{scheme_name}.xcscheme"
      FileUtils.mv(from, to)
    end

    # @return [Pathname]
    #
    def self.shared_data_dir(project_path)
      project_path = Pathname.new(project_path)
      project_path + 'xcshareddata/xcschemes'
    end

    # @return [Pathname]
    #
    def self.user_data_dir(project_path, user = nil)
      project_path = Pathname.new(project_path)
      user ||= ENV['USER']
      project_path + "xcuserdata/#{user}.xcuserdatad/xcschemes"
    end

    public

    # @!group Serialization

    #-------------------------------------------------------------------------#

    # Serializes the current state of the object to a String.
    #
    # @return [String] the XML string value of the current state of the object.
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
    # @param [String] name
    #        The name of the scheme, to have ".xcscheme" appended.
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
    def save_as(project_path, name, shared = true)
      if shared
        scheme_folder_path = self.class.shared_data_dir(project_path)
      else
        scheme_folder_path = self.class.user_data_dir(project_path)
      end
      scheme_folder_path.mkpath
      scheme_path = scheme_folder_path + "#{name}.xcscheme"
      File.open(scheme_path, 'w') do |f|
        f.write(to_s)
      end
    end

    #-------------------------------------------------------------------------#

  end
end
