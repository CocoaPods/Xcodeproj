require 'fiddle'

module Xcodeproj
  def self.read_plist(path)
    PlistHelper.read(path)
  end

  def self.write_plist(hash, path)
    PlistHelper.write(hash, path)
  end

  # Provides support for loading and serializing property list files.
  #
  module PlistHelper
    class << self
      # Serializes a hash as an XML property list file.
      #
      # @param  [#to_hash] hash
      #         The hash to store.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def write(hash, path)
        unless hash.is_a?(Hash)
          if hash.respond_to?(:to_hash)
            hash = hash.to_hash
          else
            raise TypeError, "The given `#{hash.inspect}` must be a hash or " \
                             "respond to #to_hash'."
          end
        end

        unless path.is_a?(String) || path.is_a?(Pathname)
          raise TypeError, "The given `#{path}` must be a string or 'pathname'."
        end

        url = CoreFoundation.CFURLCreateFromFileSystemRepresentation(path.to_s)
        stream = CoreFoundation.CFWriteStreamCreateWithFile(url)
        unless CoreFoundation.CFWriteStreamOpen(stream) == CoreFoundation::TRUE
          raise "Unable to open stream!"
        end
        begin
          plist = CoreFoundation.RubyHashToCFDictionary(hash)
          CoreFoundation.CFPropertyListWriteToStream(plist, stream)
        ensure
          CoreFoundation.CFWriteStreamClose(stream)
        end

        true
      end

      # @return [String] Returns the native objects loaded from a property list
      #         file.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def read(path)
        path = path.to_s
        unless File.exist?(path)
          raise ArgumentError, "The plist file at path `#{path}` doesn't exist."
        end

        url = CoreFoundation.CFURLCreateFromFileSystemRepresentation(path)
        data = CoreFoundation.CFURLCreateDataAndPropertiesFromResource(url)
        plist = CoreFoundation.CFPropertyListCreateFromXMLData(data)
        unless CoreFoundation.CFGetTypeID(plist) == CoreFoundation.CFDictionaryGetTypeID()
          raise "Expected a plist with a dictionary root object!"
        end

        #require 'pp'
        result = CoreFoundation.CFDictionaryToRubyHash(plist)
        #pp result
        result
      end

      private

      module CoreFoundation
        CFTypeRef = Fiddle::TYPE_VOIDP
        CFTypeRefPointer = Fiddle::TYPE_VOIDP
        SInt32Pointer = Fiddle::TYPE_VOIDP
        UInt8Pointer = Fiddle::TYPE_VOIDP
        CharPointer = Fiddle::TYPE_VOIDP
        CFIndex = Fiddle::TYPE_LONG
        CFTypeID = -Fiddle::TYPE_LONG

        CFPropertyListMutabilityOptions = Fiddle::TYPE_INT
        KCFPropertyListImmutable = 0

        CFPropertyListFormat = Fiddle::TYPE_INT
        KCFPropertyListXMLFormat_v1_0 = 100

        UInt32 = -Fiddle::TYPE_INT
        UInt8 = -Fiddle::TYPE_CHAR

        CFStringEncoding = UInt32
        KCFStringEncodingUTF8 = 0x08000100

        Boolean = Fiddle::TYPE_CHAR
        TRUE = 1
        FALSE = 0

        FunctionPointer = Fiddle::TYPE_VOIDP

        def self.image
          @image ||= Fiddle.dlopen('/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation')
        end

        def self.CFShow(ref)
          function = Fiddle::Function.new(
            image['CFShow'],
            [CFTypeRef],
            Fiddle::TYPE_VOID
          )
          function.call(ref)
        end

        # C Ruby's free() function
        def self.free_function
          Fiddle::Function.new(Fiddle::RUBY_FREE, [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)
        end

        def self.CFRelease_function
          Fiddle::Function.new(image['CFRelease'], [CFTypeRef], Fiddle::TYPE_VOID)
        end

        # Made up function that assigns `CFRelease` as the function that should be
        # used to free the memory once Ruby's GC deems the object out of scope.
        def self.CFAutoRelease(ref)
          ref.free = CFRelease_function() unless ref.null?
          ref
        end

        # Actual function wrappers

        def self.CFWriteStreamCreateWithFile(url)
          function = Fiddle::Function.new(
            image['CFWriteStreamCreateWithFile'],
            [CFTypeRef, CFTypeRef],
            CFTypeRef
          )
          CFAutoRelease(function.call(Fiddle::NULL, url))
        end

        def self.CFWriteStreamOpen(stream)
          function = Fiddle::Function.new(
            image['CFWriteStreamOpen'],
            [CFTypeRef],
            Boolean
          )
          function.call(stream)
        end

        def self.CFWriteStreamClose(stream)
          function = Fiddle::Function.new(
            image['CFWriteStreamClose'],
            [CFTypeRef],
            Fiddle::TYPE_VOID
          )
          function.call(stream)
        end

        # TODO will be deprecated
        def self.CFPropertyListWriteToStream(plist, stream)
          function = Fiddle::Function.new(
            image['CFPropertyListWriteToStream'],
            [CFTypeRef, CFTypeRef, CFPropertyListFormat, CFTypeRefPointer],
            CFIndex
          )
          error_string_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INTPTR_T, free_function)
          result = function.call(plist, stream, KCFPropertyListXMLFormat_v1_0, error_string_ptr)
          if result == 0
            error_string = CFAutoRelease(error_string_ptr.ptr)
            CFShow(error_string)
            raise "Unable to write plist data!"
          end
          result
        end

        def self.CFURLCreateFromFileSystemRepresentation(path)
          function = Fiddle::Function.new(
            image['CFURLCreateFromFileSystemRepresentation'],
            [CFTypeRef, UInt8Pointer, CFIndex, Boolean],
            CFTypeRef
          )
          CFAutoRelease(function.call(Fiddle::NULL, path, path.bytesize, FALSE))
        end

        # NOTE: Has been deprecated since 10.9
        def self.CFURLCreateDataAndPropertiesFromResource(url)
          function = Fiddle::Function.new(
            image['CFURLCreateDataAndPropertiesFromResource'],
            [CFTypeRef, CFTypeRef, CFTypeRefPointer, CFTypeRefPointer, CFTypeRef, SInt32Pointer],
            Boolean
          )
          data_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INTPTR_T, free_function)
          error_code_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, free_function)
          success = function.call(Fiddle::NULL, url, data_ptr, Fiddle::NULL, Fiddle::NULL, error_code_ptr)
          if success == TRUE
            CFAutoRelease(data_ptr.ptr)
          else
            raise "Unable to read data. Error: #{error_code_ptr[0]}"
          end
        end

        # NOTE: Will be deprecated soon
        def self.CFPropertyListCreateFromXMLData(data)
          function = Fiddle::Function.new(
            image['CFPropertyListCreateFromXMLData'],
            [CFTypeRef, CFTypeRef, CFPropertyListMutabilityOptions, CFTypeRefPointer],
            CFTypeRef
          )
          error_string_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INTPTR_T, free_function)
          plist = CFAutoRelease(function.call(Fiddle::NULL, data, KCFPropertyListImmutable, error_string_ptr))
          error_string = CFAutoRelease(error_string_ptr.ptr)
          unless error_string.null?
            CFShow(error_string)
            raise "Unable to read plist data!"
          end
          plist
        end

        def self.CFDictionaryApplyFunction(dictionary, &callback)
          raise "Callback block required!" if callback.nil?

          param_types = [CFTypeRef, CFTypeRef, Fiddle::TYPE_VOIDP]
          callback_closure = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOID, param_types, &callback)
          callback_function = Fiddle::Function.new(callback_closure, param_types, Fiddle::TYPE_VOID)

          function = Fiddle::Function.new(
            image['CFDictionaryApplyFunction'],
            [CFTypeRef, FunctionPointer, Fiddle::TYPE_VOIDP],
            Fiddle::TYPE_VOID
          )
          function.call(dictionary, callback_function, Fiddle::NULL)
        end

        def self.CFArrayGetCount(array)
          function = Fiddle::Function.new(
            image['CFArrayGetCount'],
            [CFTypeRef],
            CFIndex
          )
          function.call(array)
        end

        def self.CFArrayGetValueAtIndex(array, index)
          function = Fiddle::Function.new(
            image['CFArrayGetValueAtIndex'],
            [CFTypeRef, CFIndex],
            CFTypeRef
          )
          function.call(array, index)
        end

        # TODO Couldn't figure out how to pass a CFRange struct by reference to the
        #      real `CFArrayApplyFunction` function, so cheating by implementing our
        #      own version.
        def self.CFArrayApplyFunction(array)
          raise "Callback block required!" unless block_given?
          CFArrayGetCount(array).times do |index|
            yield CFArrayGetValueAtIndex(array, index)
          end
        end

        def self.CFGetTypeID(ref)
          function = Fiddle::Function.new(
            image['CFGetTypeID'],
            [CFTypeRef],
            CFTypeID
          )
          function.call(ref)
        end

        def self.CFDictionaryGetTypeID()
          function = Fiddle::Function.new(
            image['CFDictionaryGetTypeID'],
            [],
            CFTypeID
          )
          function.call
        end

        def self.CFStringGetTypeID()
          function = Fiddle::Function.new(
            image['CFStringGetTypeID'],
            [],
            CFTypeID
          )
          function.call
        end

        def self.CFArrayGetTypeID()
          function = Fiddle::Function.new(
            image['CFArrayGetTypeID'],
            [],
            CFTypeID
          )
          function.call
        end

        def self.CFBooleanGetTypeID()
          function = Fiddle::Function.new(
            image['CFBooleanGetTypeID'],
            [],
            CFTypeID
          )
          function.call
        end

        def self.CFStringCreateExternalRepresentation(string, encoding, replacement)
          function = Fiddle::Function.new(
            image['CFStringCreateExternalRepresentation'],
            [CFTypeRef, CFTypeRef, CFStringEncoding, UInt8],
            CFTypeRef
          )
          CFAutoRelease(function.call(Fiddle::NULL, string, encoding, replacement))
        end

        def self.CFStringCreateWithCString(cstr, encoding)
          function = Fiddle::Function.new(
            image['CFStringCreateWithCString'],
            [CFTypeRef, CharPointer, CFStringEncoding],
            CFTypeRef
          )
          CFAutoRelease(function.call(Fiddle::NULL, cstr, encoding))
        end

        def self.CFDataGetLength(data)
          function = Fiddle::Function.new(
            image['CFDataGetLength'],
            [CFTypeRef],
            CFIndex
          )
          function.call(data)
        end

        def self.CFDataGetBytePtr(data)
          function = Fiddle::Function.new(
            image['CFDataGetBytePtr'],
            [CFTypeRef],
            Fiddle::TYPE_VOIDP
          )
          function.call(data)
        end

        def self.CFDictionaryCreateMutable
          function = Fiddle::Function.new(
            image['CFDictionaryCreateMutable'],
            [CFTypeRef, CFIndex, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
            CFTypeRef
          )
          CFAutoRelease(function.call(Fiddle::NULL, 0, image['kCFTypeDictionaryKeyCallBacks'], image['kCFTypeDictionaryValueCallBacks']))
        end

        def self.CFDictionaryAddValue(dictionary, key, value)
          function = Fiddle::Function.new(
            image['CFDictionaryAddValue'],
            [CFTypeRef, CFTypeRef, CFTypeRef],
            Fiddle::TYPE_VOIDP
          )
          function.call(dictionary, key, value)
        end

        def self.CFArrayCreateMutable
          function = Fiddle::Function.new(
            image['CFArrayCreateMutable'],
            [CFTypeRef, CFIndex, Fiddle::TYPE_VOIDP],
            CFTypeRef
          )
          CFAutoRelease(function.call(Fiddle::NULL, 0, image['kCFTypeArrayCallBacks']))
        end

        def self.CFArrayAppendValue(array, element)
          function = Fiddle::Function.new(
            image['CFArrayAppendValue'],
            [CFTypeRef, CFTypeRef],
            Fiddle::TYPE_VOIDP
          )
          function.call(array, element)
        end

        def self.CFCopyDescription(ref)
          function = Fiddle::Function.new(
            image['CFCopyDescription'],
            [CFTypeRef],
            CFTypeRef
          )
          CFAutoRelease(function.call(ref))
        end

        def self.CFBooleanGetValue(boolean)
          function = Fiddle::Function.new(
            image['CFBooleanGetValue'],
            [CFTypeRef],
            Boolean
          )
          function.call(boolean)
        end

        # CFTypeRef to Ruby conversions

        def self.CFTypeRefToRubyValue(ref)
          case CFGetTypeID(ref)
          when CFStringGetTypeID()
            CFStringToRubyString(ref)
          when CFDictionaryGetTypeID()
            CFDictionaryToRubyHash(ref)
          when CFArrayGetTypeID()
            CFArrayToRubyArray(ref)
          when CFBooleanGetTypeID()
            CFBooleanToRubyBoolean(ref)
          else
            description = CFStringToRubyString(CFCopyDescription(ref))
            raise TypeError, "Unknown type: #{description}"
          end
        end

        # TODO Does Pointer#to_str actually copy the data as expected?
        def self.CFStringToRubyString(string)
          data = CFStringCreateExternalRepresentation(string, KCFStringEncodingUTF8, 0)
          if data.null?
            raise "Unable to convert string!"
          end
          bytes_ptr = CFDataGetBytePtr(data)
          s = bytes_ptr.to_str(CFDataGetLength(data))
          s.force_encoding(Encoding::UTF_8)
          s
        end

        def self.CFDictionaryToRubyHash(dictionary)
          result = {}
          CFDictionaryApplyFunction(dictionary) do |key, value|
            result[CFStringToRubyString(key)] = CFTypeRefToRubyValue(value)
          end
          result
        end

        def self.CFArrayToRubyArray(array)
          result = []
          CFArrayApplyFunction(array) do |element|
            result << CFTypeRefToRubyValue(element)
          end
          result
        end

        def self.CFBooleanToRubyBoolean(boolean)
          CFBooleanGetValue(boolean) == TRUE
        end

        # Ruby to CFTypeRef conversions

        def self.RubyValueToCFTypeRef(value)
          result = case value
                   when String
                     RubyStringToCFString(value)
                   when Hash
                     RubyHashToCFDictionary(value)
                   when Array
                     RubyArrayToCFArray(value)
                   when true, false
                     RubyBooleanToCFBoolean(value)
                   else
                     RubyStringToCFString(value.to_s)
                   end
          if result.null?
            raise TypeError, "Unable to convert Ruby value `#{value.inspect}' into a CFTypeRef."
          end
          result
        end

        def self.RubyStringToCFString(string)
          CFStringCreateWithCString(Fiddle::Pointer[string], KCFStringEncodingUTF8)
        end

        def self.RubyHashToCFDictionary(hash)
          dictionary = CFDictionaryCreateMutable()
          hash.each do |key, value|
            key = RubyStringToCFString(key.to_s)
            value = RubyValueToCFTypeRef(value)
            CFDictionaryAddValue(dictionary, key, value)
          end
          dictionary
        end

        def self.RubyArrayToCFArray(array)
          result = CFArrayCreateMutable()
          array.each do |element|
            element = RubyValueToCFTypeRef(element)
            CFArrayAppendValue(result, element)
          end
          result
        end

        # Ah yeah, CFBoolean, it's not a CFNumber, it’s not a CFTypeRef. The
        # only way to get them easily is by using the constants, so load their
        # addresses as pointers and dereference them.
        def self.RubyBooleanToCFBoolean(value)
          Fiddle::Pointer.new(value ? image['kCFBooleanTrue'] : image['kCFBooleanFalse']).ptr
        end
      end

    end
  end
end

