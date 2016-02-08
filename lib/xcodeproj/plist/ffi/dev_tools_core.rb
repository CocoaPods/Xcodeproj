require 'fiddle'

module Xcodeproj
  module Plist
    module FFI
      module DevToolsCore
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

        class NSObject
          private

          def self.objc_class
            @objc_class ||= CoreFoundation.objc_getClass(name.split('::').last)
          end

          def self.image
            @image ||= Fiddle::Handle.new
          end

          def self.extern(symbol, parameter_types, return_type)
            CoreFoundation.extern_image(image, symbol, parameter_types, return_type)
          end

          def self.objc_msgSend(args, return_type = CoreFoundation::VoidPointer)
            arguments = [CoreFoundation::VoidPointer, CoreFoundation::VoidPointer] + args

            Fiddle::Function.new(image['objc_msgSend'], arguments, return_type)
          end

          def self.respondsToSelector(instance, sel)
            selector = CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString(sel))
            respondsToSelector = objc_msgSend([CoreFoundation::CharPointer], CoreFoundation::Boolean)
            result = respondsToSelector.call(
              instance,
              CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString('respondsToSelector:')),
              selector)
            result == CoreFoundation::TRUE ? true : false
          end

          Class = CoreFoundation::VoidPointer
          ID = CoreFoundation::VoidPointer
          SEL = CoreFoundation::VoidPointer

          extern :NSSelectorFromString, [CoreFoundation::CFTypeRef], SEL

          extern :objc_getClass, [CoreFoundation::CharPointer], Class
          extern :class_getName, [Class], CoreFoundation::CharPointer
        end

        XCODE_PATH = Pathname.new(`xcrun xcode-select --print-path`.strip).dirname

        def self.load_xcode_framework(framework)
          Fiddle.dlopen(XCODE_PATH.join(framework).to_s)
        rescue Fiddle::DLError
          nil
        end

        # @note The IB frameworks only seem to be necessary on Xcode 7+
        #
        def self.load_xcode_frameworks
          DevToolsCore.silence_stderr do
            load_xcode_framework('SharedFrameworks/DVTFoundation.framework/DVTFoundation')
            load_xcode_framework('SharedFrameworks/DVTServices.framework/DVTServices')
            load_xcode_framework('SharedFrameworks/DVTPortal.framework/DVTPortal')
            load_xcode_framework('SharedFrameworks/DVTSourceControl.framework/DVTSourceControl')
            load_xcode_framework('SharedFrameworks/CSServiceClient.framework/CSServiceClient')
            load_xcode_framework('Frameworks/IBFoundation.framework/IBFoundation')
            load_xcode_framework('Frameworks/IBAutolayoutFoundation.framework/IBAutolayoutFoundation')
            load_xcode_framework('Frameworks/IDEFoundation.framework/IDEFoundation')
            load_xcode_framework('PlugIns/Xcode3Core.ideplugin/Contents/MacOS/Xcode3Core')
          end
        end

        class CFDictionary < NSObject
          public

          def initialize(dictionary)
            @dictionary = dictionary
          end

          def plistDescriptionUTF8Data
            selector = 'plistDescriptionUTF8Data'
            return nil unless NSObject.respondsToSelector(@dictionary, selector)

            plistDescriptionUTF8Data = CFDictionary.objc_msgSend([])
            plistDescriptionUTF8Data.call(
              @dictionary,
              CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString(selector)))
          end

          def self.image
            @image ||= DevToolsCore.load_xcode_frameworks
          end
        end

        class NSData < NSObject
          public

          def initialize(data)
            @data = data
          end

          def writeToFileAtomically(path)
            selector = 'writeToFile:atomically:'
            return false unless NSObject.respondsToSelector(@data, selector)

            writeToFileAtomically = NSData.objc_msgSend([CoreFoundation::VoidPointer, CoreFoundation::Boolean], CoreFoundation::Boolean)
            result = writeToFileAtomically.call(
              @data,
              CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString(selector)),
              CoreFoundation.RubyStringToCFString(path),
              1)
            result == CoreFoundation::TRUE ? true : false
          end
        end

        class PBXProject < NSObject
          public

          def initialize(path)
            DevToolsCore.silence_stderr do
              CoreFoundation.IDEInitialize(1, CoreFoundation::NULL)

              # The parameter is whether UI must be initialized (which we don't need)
              CoreFoundation.XCInitializeCoreIfNeeded(0)
            end

            selector = 'projectWithFile:'

            if NSObject.respondsToSelector(PBXProject.objc_class, selector)
              projectWithFile = PBXProject.objc_msgSend([CoreFoundation::VoidPointer])
              @project = projectWithFile.call(
                PBXProject.objc_class,
                CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString(selector)),
                CoreFoundation.RubyStringToCFString(path))
            end
          end

          def close
            selector = 'close'
            return unless NSObject.respondsToSelector(@project, selector)

            close = PBXProject.objc_msgSend([], CoreFoundation::Void)
            close.call(@project, CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString(selector)))
          end

          def writeToFileSystemProjectFile
            selector = 'writeToFileSystemProjectFile:userFile:checkNeedsRevert:'
            return unless NSObject.respondsToSelector(@project, selector)

            writeToFile = PBXProject.objc_msgSend([CoreFoundation::Boolean, CoreFoundation::Boolean, CoreFoundation::Boolean], CoreFoundation::Boolean)
            result = writeToFile.call(
              @project,
              CoreFoundation.NSSelectorFromString(CoreFoundation.RubyStringToCFString(selector)),
              1,
              0,
              1)
            result == CoreFoundation::TRUE ? true : false
          end

          private

          def self.image
            @image ||= DevToolsCore.load_xcode_frameworks
          end

          extern :IDEInitialize, [CoreFoundation::Boolean, ID], CoreFoundation::Void
          extern :XCInitializeCoreIfNeeded, [CoreFoundation::Boolean], CoreFoundation::Void
        end

        # rubocop:enable Style/MethodName
        # rubocop:enable Style/VariableName
      end
    end
  end
end
