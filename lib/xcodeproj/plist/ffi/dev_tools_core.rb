require 'fiddle'

# Since Xcode 8 beta 4, calling `PBXProject.projectWithFile` does break subsequent calls to
# `chdir`. While sounding ridiculous, this is unfortunately true and debugging it from the
# userland side showed no difference at all to successful calls to `chdir`, but the working
# directory is simply not changed in the end. This workaround is even more absurd, monkey
# patching all calls to `chdir` to use `__pthread_chdir` which does appear to work just fine.
class Dir
  def self.chdir(path)
    old_dir = Dir.getwd
    res = actually_chdir(path)

    if block_given?
      begin
        return yield
      ensure
        actually_chdir(old_dir)
      end
    end

    res
  end

  private

  def self.actually_chdir(path)
    libc = Fiddle.dlopen '/usr/lib/libc.dylib'
    f = Fiddle::Function.new(libc['__pthread_chdir'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
    f.call(path.to_s)
  end
end

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
        XCODE_VERSION = Gem::Version.new(`xcodebuild -version`.split(' ')[1])

        def self.load_xcode_framework(framework)
          Fiddle.dlopen(XCODE_PATH.join(framework).to_s)
        rescue Fiddle::DLError
          nil
        end

        # @note The IB frameworks only seem to be necessary on Xcode 7+
        #
        def self.load_xcode_frameworks
          is_80_or_later = XCODE_VERSION >= Gem::Version.new('8.0')

          DevToolsCore.silence_stderr do
            load_xcode_framework('SharedFrameworks/DVTFoundation.framework/DVTFoundation')
            load_xcode_framework('SharedFrameworks/DVTServices.framework/DVTServices')
            load_xcode_framework('SharedFrameworks/DVTPortal.framework/DVTPortal')
            load_xcode_framework('SharedFrameworks/DVTSourceControl.framework/DVTSourceControl')
            load_xcode_framework('SharedFrameworks/CSServiceClient.framework/CSServiceClient') unless is_80_or_later
            load_xcode_framework('Frameworks/IBFoundation.framework/IBFoundation')
            load_xcode_framework('Frameworks/IBAutolayoutFoundation.framework/IBAutolayoutFoundation')
            if is_80_or_later
              load_xcode_framework('SharedFrameworks/DVTAnalyticsClient.framework/DVTAnalyticsClient')
              load_xcode_framework('SharedFrameworks/DVTAnalytics.framework/DVTAnalytics')
              load_xcode_framework('SharedFrameworks/DVTDocumentation.framework/DVTDocumentation')
              load_xcode_framework('SharedFrameworks/SourceKit.framework/SourceKit')
            end
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
