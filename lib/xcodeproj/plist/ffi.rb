
module Xcodeproj
  module Plist
    # Provides support for loading and serializing property list files via
    # Fiddle and CoreFoundation / Xcode.
    #
    module FFI
      autoload :CoreFoundation, 'xcodeproj/plist/ffi/core_foundation'
      autoload :DevToolsCore,   'xcodeproj/plist/ffi/dev_tools_core'

      class << self
        # Attempts to load the `fiddle` and Xcode based plist serializer.
        #
        # @return [String,Nil] The loading error message, or `nil` if loading
        #         was successful.
        #
        def attempt_to_load!
          return @attempt_to_load if defined?(@attempt_to_load)
          @attempt_to_load = begin
            require 'fiddle'
            nil
          rescue LoadError
            'Xcodeproj relies on a library called `fiddle` to read and write ' \
            'Xcode project files. Ensure your Ruby installation includes ' \
            '`fiddle` and try again.'
          end
        end

        # Serializes a hash as an XML property list file.
        #
        # @param  [#to_hash] hash
        #         The hash to store.
        #
        # @param  [#to_s] path
        #         The path of the file.
        #
        def write_to_path(hash, path)
          raise ThreadError, 'Can only write plists from the main thread.' unless Thread.current == Thread.main

          path = File.expand_path(path)

          should_fork = ENV['FORK_XCODE_WRITING']
          success = ruby_hash_write_xcode(hash, path, should_fork)

          unless success
            CoreFoundation.RubyHashPropertyListWrite(hash, path)
            fix_encoding(path)
          end
        end

        # @return [Hash] Returns the native objects loaded from a property list
        #         file.
        #
        # @param  [#to_s] path
        #         The path of the file.
        #
        def read_from_path(path)
          CoreFoundation.RubyHashPropertyListRead(path)
        end

        private

        # Simple workaround to escape characters which are outside of ASCII
        # character-encoding. Relies on the fact that there are no XML characters
        # which would need to be escaped.
        #
        # @note   This is necessary because Xcode (4.6 currently) uses the MacRoman
        #         encoding unless the `// !$*UTF8*$!` magic comment is present. It
        #         is not possible to serialize a plist using the NeXTSTEP format
        #         without access to the private classes of Xcode and that comment
        #         is not compatible with the XML format. For the complete
        #         discussion see CocoaPods/CocoaPods#926.
        #
        #
        # @note   Sadly this hack is not sufficient for supporting Emoji.
        #
        # @param  [String, Pathname] The path of the file which needs to be fixed.
        #
        # @return [void]
        #
        def fix_encoding(filename)
          output = ''
          input = File.open(filename, 'rb', &:read)
          input.unpack('U*').each do |codepoint|
            if codepoint > 127 # ASCII is 7-bit, so 0-127 are valid characters
              output << "&##{codepoint};"
            else
              output << codepoint.chr
            end
          end
          File.open(filename, 'wb') { |file| file.write(output) }
        end

        # Serializes a hash as an ASCII plist, using Xcode.
        #
        # @param  [Hash] hash
        #         The hash to store.
        #
        # @param  [String] path
        #         The path of the file.
        #
        def ruby_hash_write_xcode(hash, path, should_fork)
          return false unless path.end_with?('pbxproj')
          if should_fork
            require 'open3'
            _output, status = Open3.capture2e(Gem.ruby, '-e', <<-RUBY, path, :stdin_data => Marshal.dump(hash))
            $LOAD_PATH.replace #{$LOAD_PATH}
            path = ARGV.first
            hash = Marshal.load(STDIN)
            require "xcodeproj"
            require "xcodeproj/plist/ffi"
            ffi = Xcodeproj::Plist::FFI
            success = ffi::DevToolsCore.load_xcode_frameworks && ffi.send(:ruby_hash_write_devtoolscore, hash, path)
            exit(success ? 0 : 1)
            RUBY

            status.success?
          else
            monkey_patch_chdir
            success = DevToolsCore.load_xcode_frameworks && ruby_hash_write_devtoolscore(hash, path)

            success
          end
        end

        def ruby_hash_write_devtoolscore(hash, path)
          success = true

          begin
            plist = DevToolsCore::CFDictionary.new(CoreFoundation.RubyHashToCFDictionary(hash))
            data = DevToolsCore::NSData.new(plist.plistDescriptionUTF8Data)
            success &= data.writeToFileAtomically(path)

            project = DevToolsCore::PBXProject.new(path)
            success &= project.writeToFileSystemProjectFile
            project.close
          rescue Fiddle::DLError
            success = false
          end

          success
        end

        def monkey_patch_chdir
          require 'xcodeproj/plist/ffi/chdir_override'
          Dir.class_eval do
            class << Dir
              alias_method :chdir, :cp_chdir
            end
          end
        end
      end
    end
  end
end
