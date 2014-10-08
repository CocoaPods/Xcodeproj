require 'fiddle'

module Xcodeproj
  class Project
    module XCProjHelper
      class << self
        # @return [Bool] Whether the xcproj tool is available.
        #
        def available?
          true
        end

        # Touches the project at the given path if the xcproj tool is
        # available.
        #
        # @return [void]
        #
        def touch(path)
          if available?
            command = "xcproj --project \"#{path}\" touch"
            success, output = execute(command)
            unless success
              message = 'The `xcproj` tool has failed to touch the project. ' \
                        'Check whether your installation of `xcproj` is ' \
                        "functional.\n\n"
              message << command << "\n"
              message << output
              UI.warn(message)
            end
          project = PBXProject.new(path)
          project.writeToFileSystemProjectFile
        end
      end

      private

      # @!group Private Helpers
      #---------------------------------------------------------------------#

      def self.silence_stderr
        begin
          orig_stderr = $stderr.clone
          $stderr.reopen File.new('/dev/null', 'w')
          retval = yield
        ensure
          $stderr.reopen orig_stderr
        end
        retval
      end

      # rubocop:disable Style/MethodName
      # rubocop:disable Style/VariableName

      class PBXProject
        public

        def initialize(path)
          XCProjHelper.silence_stderr do
            CoreFoundation.IDEInitialize(1, CoreFoundation::NULL)
            CoreFoundation.XCInitializeCoreIfNeeded(1)
          end

          projectWithFile = PBXProject.objc_msgSend([CoreFoundation::VoidPointer])
          @project = projectWithFile.call(
            PBXProject.objc_class,
            CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString('projectWithFile:')),
            CoreFoundation.RubyStringToCFString(path))
        end

        def writeToFileSystemProjectFile
          writeToFile = PBXProject.objc_msgSend([CoreFoundation::Boolean, CoreFoundation::Boolean, CoreFoundation::Boolean], CoreFoundation::Boolean)
          writeToFile.call(
            @project,
            CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString('writeToFileSystemProjectFile:userFile:checkNeedsRevert:')),
            1,
            0,
            0)
        end

        private

        def self.objc_class
          @objc_class ||= CoreFoundation.objc_getClass('PBXProject')
        end

        XCODE_PATH = Pathname.new(`xcrun xcode-select -p`.strip).dirname

        def self.image
          Fiddle.dlopen(XCODE_PATH.join('SharedFrameworks/DVTFoundation.framework/DVTFoundation').to_s)
          Fiddle.dlopen(XCODE_PATH.join('SharedFrameworks/DVTSourceControl.framework/DVTSourceControl').to_s)
          Fiddle.dlopen(XCODE_PATH.join('Frameworks/IDEFoundation.framework/IDEFoundation').to_s)
          @image ||= Fiddle.dlopen(XCODE_PATH.join('PlugIns/Xcode3Core.ideplugin/Contents/MacOS/Xcode3Core').to_s)
        end

        def self.extern(symbol, parameter_types, return_type)
          CoreFoundation.extern_image(image, symbol, parameter_types, return_type)
        end

        def self.objc_msgSend(args, return_type = CoreFoundation::VoidPointer)
          arguments = [CoreFoundation::VoidPointer, CoreFoundation::VoidPointer] + args

          Fiddle::Function.new(image['objc_msgSend'], arguments, return_type)
        end

        Class = CoreFoundation::VoidPointer
        id = CoreFoundation::VoidPointer
        SEL = CoreFoundation::VoidPointer

        extern :NSSelectorFromString, [CoreFoundation::CFTypeRef], SEL

        extern :IDEInitialize, [CoreFoundation::Boolean, id], CoreFoundation::Void
        extern :XCInitializeCoreIfNeeded, [CoreFoundation::Boolean], CoreFoundation::Void

        extern :objc_getClass, [CoreFoundation::CharPointer], Class
        extern :class_getName, [Class], CoreFoundation::CharPointer
      end

      # rubocop:enable Style/MethodName
      # rubocop:enable Style/VariableName
    end
  end
end
