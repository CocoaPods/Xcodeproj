require 'rexml/document'

require 'xcodeproj/scheme/build_action'
require 'xcodeproj/scheme/test_action'
require 'xcodeproj/scheme/launch_action'
require 'xcodeproj/scheme/profile_action'
require 'xcodeproj/scheme/analyze_action'
require 'xcodeproj/scheme/archive_action'

require 'xcodeproj/scheme/buildable_product_runnable'
require 'xcodeproj/scheme/buildable_reference'
require 'xcodeproj/scheme/macro_expansion'

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

    # @return [Pathname] bundle_path
    #         The path to the bundle where the scheme is saved,
    #         or nil when the scheme file is not in a project or a workspace.
    #
    attr_reader :bundle_path
    
    # Return the path to the .xcscheme file.
    #
    # @param [String] name
    #        The name of the .xcscheme file where this scheme will be save!'ed
    #
    # @param [Boolean] shared
    #        true  => if the scheme must be a shared scheme (default value)
    #        false => if the scheme must be a user scheme
    def file_path(name,shared=true)
      scheme_folder_path = if shared
                             self.class.shared_data_dir(@bundle_path)
                           else
                             self.class.user_data_dir(@bundle_path)
                           end
      scheme_folder_path.mkpath
      scheme_folder_path + "#{name}.xcscheme"
    end

  
    # Sets the bundle_path and the file_path of the scheme
    #
    # @param [String, Pathname] path
    #        The path to the bundle (workspace or project) where this scheme will be save!'ed
    #
    # @param [String] name
    #        The name of the .xcscheme file where this scheme will be save!'ed
    #
    # @param [Boolean] shared
    #        true  => if the scheme must be a shared scheme (default value)
    #        false => if the scheme must be a user scheme
    #
    #
    # When the scheme is saved in workspace, and makes reference to
    # targets in projects that are not stored in the same directory as
    # the workspace, the container: fields must contain a path to the
    # project relative to the directory where the workspace is stored.
    # For this, we need to set the bundlePath (and give the scheme
    # name and shared flag to build the scheme file name at the same
    # time) before we add the targets, so they XML is created
    # correctly.  Example:
    #
    #       scheme = Xcodeproj::XCScheme.new
    #       scheme.setBundlePathAndName workspacePath,schemeName,true
    #       scheme.add_build_target targets[0]
    #       scheme.save!
    #
    def setBundlePathAndName(path,name,shared=true)
      @bundle_path=Pathname.new(path)
      @file_path=self.file_path(name,shared)
    end
    
    # Create a XCScheme either from scratch or using an existing file
    #
    # @param [String] file_path
    #        The path of the existing .xcscheme file. If nil will create an empty scheme
    #
    def initialize(file_path = nil)
      if file_path
        @file_path = Pathname.new(file_path)
        updateBundlePath
        @doc = REXML::Document.new(File.new(file_path))
        @doc.context[:attribute_quote] = :quote

        @scheme = @doc.elements['Scheme']
      else
        @doc = REXML::Document.new
        @doc.context[:attribute_quote] = :quote
        @doc << REXML::XMLDecl.new(REXML::XMLDecl::DEFAULT_VERSION, 'UTF-8')

        @scheme = @doc.add_element 'Scheme'
        @scheme.attributes['LastUpgradeVersion'] = Constants::LAST_UPGRADE_CHECK
        @scheme.attributes['version'] = Xcodeproj::Constants::XCSCHEME_FORMAT_VERSION

        self.build_action   = BuildAction.new(self)
        self.test_action    = TestAction.new(self)
        self.launch_action  = LaunchAction.new(self)
        self.profile_action = ProfileAction.new(self)
        self.analyze_action = AnalyzeAction.new(self)
        self.archive_action = ArchiveAction.new(self)
      end
    end

    # Convenience method to quickly add app and test targets to a new scheme.
    #
    # It will add the runnable_target to the Build, Launch and Profile actions
    # and the test_target to the Build and Test actions
    #
    # @param [Xcodeproj::Project::Object::PBXAbstractTarget] runnable_target
    #        The target to use for the 'Run', 'Profile' and 'Analyze' actions
    #
    # @param [Xcodeproj::Project::Object::PBXAbstractTarget] test_target
    #        The target to use for the 'Test' action
    #
    def configure_with_targets(runnable_target, test_target)
      build_action.add_entry BuildAction::Entry.new(self,runnable_target) if runnable_target
      build_action.add_entry BuildAction::Entry.new(self,test_target) if test_target

      test_action.add_testable TestAction::TestableReference.new(self,test_target) if test_target
      launch_action.buildable_product_runnable = BuildableProductRunnable.new(self,runnable_target, 0) if runnable_target
      profile_action.buildable_product_runnable = BuildableProductRunnable.new(self,runnable_target) if runnable_target
    end

    public

    # @!group Access Action nodes

    # @return [XCScheme::BuildAction]
    #         The Build Action associated with this scheme
    #
    def build_action
      @build_action ||= BuildAction.new(self,@scheme.elements['BuildAction'])
    end

    # @param [XCScheme::BuildAction] action
    #        The Build Action to associate to this scheme
    #
    def build_action=(action)
      @scheme.delete_element('BuildAction')
      @scheme.add_element(action.xml_element)
      @build_action = action
    end

    # @return [XCScheme::TestAction]
    #         The Test Action associated with this scheme
    #
    def test_action
      @test_action ||= TestAction.new(self,@scheme.elements['TestAction'])
    end

    # @param [XCScheme::TestAction] action
    #        The Test Action to associate to this scheme
    #
    def test_action=(action)
      @scheme.delete_element('TestAction')
      @scheme.add_element(action.xml_element)
      @test_action = action
    end

    # @return [XCScheme::LaunchAction]
    #         The Launch Action associated with this scheme
    #
    def launch_action
      @launch_action ||= LaunchAction.new(self,@scheme.elements['LaunchAction'])
    end

    # @param [XCScheme::LaunchAction] action
    #        The Launch Action to associate to this scheme
    #
    def launch_action=(action)
      @scheme.delete_element('LaunchAction')
      @scheme.add_element(action.xml_element)
      @launch_action = action
    end

    # @return [XCScheme::ProfileAction]
    #         The Profile Action associated with this scheme
    #
    def profile_action
      @profile_action ||= ProfileAction.new(self,@scheme.elements['ProfileAction'])
    end

    # @param [XCScheme::ProfileAction] action
    #        The Profile Action to associate to this scheme
    #
    def profile_action=(action)
      @scheme.delete_element('ProfileAction')
      @scheme.add_element(action.xml_element)
      @profile_action = action
    end

    # @return [XCScheme::AnalyzeAction]
    #         The Analyze Action associated with this scheme
    #
    def analyze_action
      @analyze_action ||= AnalyzeAction.new(self,@scheme.elements['AnalyzeAction'])
    end

    # @param [XCScheme::AnalyzeAction] action
    #        The Analyze Action to associate to this scheme
    #
    def analyze_action=(action)
      @scheme.delete_element('AnalyzeAction')
      @scheme.add_element(action.xml_element)
      @analyze_action = action
    end

    # @return [XCScheme::ArchiveAction]
    #         The Archive Action associated with this scheme
    #
    def archive_action
      @archive_action ||= ArchiveAction.new(self,@scheme.elements['ArchiveAction'])
    end

    # @param [XCScheme::ArchiveAction] action
    #        The Archive Action to associate to this scheme
    #
    def archive_action=(action)
      @scheme.delete_element('ArchiveAction')
      @scheme.add_element(action.xml_element)
      @archive_action = action
    end

    # @!group Target methods

    # Add a target to the list of targets to build in the build action.
    #
    # @param [Xcodeproj::Project::Object::AbstractTarget] build_target
    #        A target used by scheme in the build step.
    #
    # @param [Bool] build_for_running
    #        Whether to build this target in the launch action. Often false for test targets.
    #
    def add_build_target(build_target, build_for_running = true)
      entry = BuildAction::Entry.new(self,build_target)

      entry.build_for_testing   = true
      entry.build_for_running   = build_for_running
      entry.build_for_profiling = true
      entry.build_for_archiving = true
      entry.build_for_analyzing = true

      build_action.add_entry(entry)
    end

    # Add a target to the list of targets to build in the build action.
    #
    # @param [Xcodeproj::Project::Object::AbstractTarget] test_target
    #        A target used by scheme in the test step.
    #
    def add_test_target(test_target)
      testable = TestAction::TestableReference.new(self,test_target)
      test_action.add_testable(testable)
    end

    # Sets a runnable target to be the target of the launch action of the scheme.
    #
    # @param [Xcodeproj::Project::Object::AbstractTarget] build_target
    #        A target used by scheme in the launch step.
    #
    def set_launch_target(build_target)
      launch_runnable = BuildableProductRunnable.new(self,build_target, 0)
      launch_action.buildable_product_runnable = launch_runnable

      profile_runnable = BuildableProductRunnable.new(self,build_target)
      profile_action.buildable_product_runnable = profile_runnable

      macro_exp = MacroExpansion.new(self,build_target)
      test_action.add_macro_expansion(macro_exp)
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
      from = user_data_dir(project_path, user) + "#{scheme_name}.xcscheme"
      FileUtils.mv(from, to)
    end

    # @return [Pathname]
    #
    def self.shared_data_dir(bundle_path)
      bundle_path = Pathname.new(bundle_path)
      bundle_path + 'xcshareddata/xcschemes'
    end

    # @return [Pathname]
    #
    def self.user_data_dir(bundle_path, user = nil)
      bundle_path = Pathname.new(bundle_path)
      user ||= ENV['USER']
      bundle_path + "xcuserdata/#{user}.xcuserdatad/xcschemes"
    end

    public

    # @!group Serialization

    #-------------------------------------------------------------------------#

    # Serializes the current state of the object to a String.
    #
    # @note   The goal of the string representation is to match Xcode output as
    #         close as possible to aide comparison.
    #
    # @return [String] the XML string value of the current state of the object.
    #
    def to_s
      formatter = XMLFormatter.new(2)
      formatter.compact = false
      out = ''
      formatter.write(@doc, out)
      out.gsub!("<?xml version='1.0' encoding='UTF-8'?>", '<?xml version="1.0" encoding="UTF-8"?>')
      out << "\n"
      out
    end

    # Serializes the current state of the object to a ".xcscheme" file.
    #
    # @param [String, Pathname] bundle_path
    #        The path where the ".xcscheme" file should be stored.
    #        This can be a project (.xcodeproj) or a workspace (.xcworkspace) bundle.
    #
    # @param [String] name
    #        The name of the scheme, to have ".xcscheme" appended.
    #
    # @param [Boolean] shared
    #        true  => if the scheme must be a shared scheme (default value)
    #        false => if the scheme must be a user scheme
    #
    # @return [String or Pathname] the path of the scheme file.
    #
    # @example Saving a scheme
    #   scheme.save_as('path/to/Project.xcodeproj') #=> true
    #   scheme.save_as('path/to/Workspace.xcworkspace') #=> true
    #
    def save_as(bundle_path, name, shared = true)
      @bundle_path = Pathname.new(bundle_path)
      scheme_path = self.file_path(name,shared)
      File.open(scheme_path, 'w') do |f|
        f.write(to_s)
      end
      scheme_path
    end

    # Serializes the current state of the object to the original ".xcscheme"
    # file this XCScheme was created from, overriding the original file.
    #
    # Requires that the XCScheme object was initialized using a file path.
    #
    def save!
      raise Informative, 'This XCScheme object was not initialized ' \
        'using a file path. Use save_as instead.' unless @file_path
      updateBundlePath # save_as may have been called before save!
      File.open(@file_path, 'w') do |f|
        f.write(to_s)
      end
    end

    
    #-------------------------------------------------------------------------#

    # XML formatter which closely mimics the output generated by Xcode.
    #
    class XMLFormatter < REXML::Formatters::Pretty
      def write_element(node, output)
        @indentation = 3
        output << ' ' * @level
        output << "<#{node.expanded_name}"

        @level += @indentation
        node.attributes.each_attribute do |attr|
          output << "\n"
          output << ' ' * @level
          output << attr.to_string.sub(/=/, ' = ')
        end unless node.attributes.empty?

        output << '>'

        output << "\n"
        node.children.each do |child|
          next if child.is_a?(REXML::Text) && child.to_s.strip.length == 0
          write(child, output)
          output << "\n"
        end
        @level -= @indentation
        output << ' ' * @level
        output << "</#{node.expanded_name}>"
      end
    end

    #-------------------------------------------------------------------------#

    private

    def updateBundlePath
      components=[]
      @file_path.each_filename {|component| components.push(component) }
      if (components[-3]=='xcuserdata') or
          ((components[-2]=='xcschemes') and
           (components[-3]=='xcshareddata')) then
        @bundle_path = @file_path.dirname.dirname.dirname
        if @bundle_path == '' ; then
          @bundle_path = '.'
        end
      else
        @bundle_path = nil
      end
    end
    

  end
end
