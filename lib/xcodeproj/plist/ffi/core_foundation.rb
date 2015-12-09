require 'fiddle'

module Xcodeproj
  module Plist
    module FFI
      # This module provides an interface to the CoreFoundation OS X framework.
      # Specifically it bridges the functions required to be able to read and write
      # property lists.
      #
      # Everything in here should be considered an implementation detail and thus is
      # not further documented.
      #
      # @todo Move this out into its own gem.
      #
      # @!visibility private
      #
      module CoreFoundation
        PATH = '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation'

        # rubocop:disable Style/MethodName
        # rubocop:disable Style/VariableName

        # @!group Ruby hash as property list (de)serialization
        #---------------------------------------------------------------------------#

        def self.RubyHashPropertyListWrite(hash, path)
          url = CFURLCreateFromFileSystemRepresentation(NULL,
                                                        path,
                                                        path.bytesize,
                                                        FALSE)
          stream = CFWriteStreamCreateWithFile(NULL, url)
          unless CFWriteStreamOpen(stream) == TRUE
            raise IOError, 'Unable to open stream.'
          end

          plist = RubyHashToCFDictionary(hash)

          error_ptr = CFTypeRefPointer()
          result = CFPropertyListWrite(plist,
                                       stream,
                                       KCFPropertyListXMLFormat_v1_0,
                                       0,
                                       error_ptr)
          CFWriteStreamClose(stream)

          if result == 0
            description = CFCopyDescription(error_ptr.ptr)
            raise IOError, "Unable to write plist data: #{description}"
          end
          result
        end

        def self.RubyHashPropertyListRead(path)
          url = CFURLCreateFromFileSystemRepresentation(NULL,
                                                        path,
                                                        path.bytesize,
                                                        FALSE)
          stream = CFReadStreamCreateWithFile(NULL, url)
          unless CFReadStreamOpen(stream) == TRUE
            raise IOError, 'Unable to open stream.'
          end

          error_ptr = CFTypeRefPointer()
          plist = CFPropertyListCreateWithStream(NULL,
                                                 stream,
                                                 0,
                                                 KCFPropertyListImmutable,
                                                 NULL,
                                                 error_ptr)
          CFReadStreamClose(stream)

          if plist.null?
            description = CFCopyDescription(error_ptr.ptr)
            raise IOError, "Unable to read plist data: #{description}"
          elsif CFGetTypeID(plist) != CFDictionaryGetTypeID()
            raise TypeError, 'Expected a plist with a dictionary root object.'
          end

          CFDictionaryToRubyHash(plist)
        end

        # @!group Types
        #---------------------------------------------------------------------------#

        # rubocop:disable Style/ConstantName

        NULL = Fiddle::NULL

        Void = Fiddle::TYPE_VOID
        VoidPointer = Fiddle::TYPE_VOIDP
        FunctionPointer = VoidPointer

        UInt32 = -Fiddle::TYPE_INT
        UInt8 = -Fiddle::TYPE_CHAR

        SInt32Pointer = VoidPointer
        UInt8Pointer = VoidPointer
        CharPointer = VoidPointer

        Boolean = Fiddle::TYPE_CHAR
        TRUE = 1
        FALSE = 0

        SINT64_MAX = 2**63 - 1
        SINT64_MIN = -SINT64_MAX - 1

        SIZEOF_SINT64 = 8
        SIZEOF_FLOAT64 = 8

        SINT64_PACK_TEMPLATE = 'q'
        FLOAT64_PACK_TEMPLATE = 'd'

        CFTypeRef = VoidPointer
        CFTypeRefPointer = VoidPointer
        CFIndex = Fiddle::TYPE_LONG
        CFTypeID = -Fiddle::TYPE_LONG
        CFOptionFlags = UInt32

        CFPropertyListMutabilityOptions = Fiddle::TYPE_INT
        KCFPropertyListImmutable = 0

        CFPropertyListFormat = Fiddle::TYPE_INT
        KCFPropertyListXMLFormat_v1_0 = 100
        CFPropertyListFormatPointer = VoidPointer

        CFStringEncoding = UInt32
        KCFStringEncodingUTF8 = 0x08000100

        CFNumberType = Fiddle::TYPE_INT
        KCFNumberSInt64Type = 4
        KCFNumberFloat64Type = 6

        # rubocop:enable Style/ConstantName

        private

        # @!group Helpers
        #---------------------------------------------------------------------------#

        def self.image
          @image ||= Fiddle.dlopen(PATH)
        end

        def self.free_function
          @free_function ||= Fiddle::Function.new(Fiddle::Handle.new['free'], [VoidPointer], Void)
        end

        def self.CFRelease_function
          @CFRelease ||= Fiddle::Function.new(image['CFRelease'], [CFTypeRef], Void)
        end

        def self.extern_image(image, symbol, parameter_types, return_type)
          symbol = symbol.to_s
          create_function = symbol.include?('Create')
          function_cache_key = "@__#{symbol}__"

          # Define a singleton method on the CoreFoundation module.
          define_singleton_method(symbol) do |*args|
            unless args.size == parameter_types.size
              raise ArgumentError, "wrong number of arguments (#{args.size} for " \
                                   "#{parameter_types.size})"
            end

            unless function = instance_variable_get(function_cache_key)
              function = Fiddle::Function.new(image[symbol],
                                              parameter_types,
                                              return_type)
              instance_variable_set(function_cache_key, function)
            end

            result = function.call(*args)
            create_function ? CFAutoRelease(result) : result
          end
        end

        def self.extern(symbol, parameter_types, return_type)
          extern_image(image, symbol, parameter_types, return_type)
        end

        public

        # @!group CoreFoundation function definitions
        #---------------------------------------------------------------------------#

        # CFTypeRef description
        extern :CFShow, [CFTypeRef], Void
        extern :CFCopyDescription, [CFTypeRef], CFTypeRef

        # CFType reflection
        extern :CFGetTypeID, [CFTypeRef], CFTypeID
        extern :CFDictionaryGetTypeID, [], CFTypeID
        extern :CFStringGetTypeID, [], CFTypeID
        extern :CFArrayGetTypeID, [], CFTypeID
        extern :CFBooleanGetTypeID, [], CFTypeID
        extern :CFNumberGetTypeID, [], CFTypeID

        # CFStream
        extern :CFWriteStreamCreateWithFile, [CFTypeRef, CFTypeRef], CFTypeRef
        extern :CFWriteStreamOpen, [CFTypeRef], Boolean
        extern :CFWriteStreamClose, [CFTypeRef], Void
        extern :CFReadStreamCreateWithFile, [CFTypeRef, CFTypeRef], CFTypeRef
        extern :CFReadStreamOpen, [CFTypeRef], Boolean
        extern :CFReadStreamClose, [CFTypeRef], Void

        # CFURL
        extern :CFURLCreateFromFileSystemRepresentation, [CFTypeRef, UInt8Pointer, CFIndex, Boolean], CFTypeRef

        # CFPropertyList
        extern :CFPropertyListWrite, [CFTypeRef, CFTypeRef, CFPropertyListFormat, CFOptionFlags, CFTypeRefPointer], CFIndex
        extern :CFPropertyListCreateWithStream, [CFTypeRef, CFTypeRef, CFIndex, CFOptionFlags, CFPropertyListFormatPointer, CFTypeRefPointer], CFTypeRef

        # CFString
        extern :CFStringCreateExternalRepresentation, [CFTypeRef, CFTypeRef, CFStringEncoding, UInt8], CFTypeRef
        extern :CFStringCreateWithCString, [CFTypeRef, CharPointer, CFStringEncoding], CFTypeRef

        # CFData
        extern :CFDataGetLength, [CFTypeRef], CFIndex
        extern :CFDataGetBytePtr, [CFTypeRef], VoidPointer

        # CFDictionary
        extern :CFDictionaryCreateMutable, [CFTypeRef, CFIndex, VoidPointer, VoidPointer], CFTypeRef
        extern :CFDictionaryAddValue, [CFTypeRef, CFTypeRef, CFTypeRef], VoidPointer
        extern :CFDictionaryApplyFunction, [CFTypeRef, FunctionPointer, VoidPointer], Void

        # CFArray
        extern :CFArrayCreateMutable, [CFTypeRef, CFIndex, VoidPointer], CFTypeRef
        extern :CFArrayAppendValue, [CFTypeRef, CFTypeRef], VoidPointer
        extern :CFArrayGetCount, [CFTypeRef], CFIndex
        extern :CFArrayGetValueAtIndex, [CFTypeRef, CFIndex], CFTypeRef

        # CFBoolean
        extern :CFBooleanGetValue, [CFTypeRef], Boolean

        # CFNumber
        extern :CFNumberIsFloatType, [CFTypeRef], Boolean
        extern :CFNumberGetValue, [CFTypeRef, CFNumberType, VoidPointer], Boolean
        extern :CFNumberCreate, [CFTypeRef, CFNumberType, VoidPointer], CFTypeRef

        # @!group Custom convenience functions
        #---------------------------------------------------------------------------#

        def self.CFBooleanTrue
          @CFBooleanTrue ||= Fiddle::Pointer.new(image['kCFBooleanTrue']).ptr
        end

        def self.CFBooleanFalse
          @CFBooleanFalse ||= Fiddle::Pointer.new(image['kCFBooleanFalse']).ptr
        end

        def self.CFTypeArrayCallBacks
          @CFTypeArrayCallBacks ||= image['kCFTypeArrayCallBacks']
        end

        def self.CFTypeDictionaryKeyCallBacks
          @CFTypeDictionaryKeyCallBacks ||= image['kCFTypeDictionaryKeyCallBacks']
        end

        def self.CFTypeDictionaryValueCallBacks
          @CFTypeDictionaryValueCallBacks ||= image['kCFTypeDictionaryValueCallBacks']
        end

        # This pointer will assign `CFRelease` as the free function when
        # dereferencing the pointer.
        #
        # @note This means that the object will *not* be released if it's not
        #       dereferenced, but that would be a leak anyways, so be sure to do so.
        #
        def self.CFTypeRefPointer
          pointer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INTPTR_T, free_function)
          def pointer.ptr
            ::CoreFoundation.CFAutoRelease(super)
          end
          pointer
        end

        def self.CFAutoRelease(cf_type_reference)
          cf_type_reference.free = CFRelease_function() unless cf_type_reference.null?
          cf_type_reference
        end

        def self.CFDictionaryApplyBlock(dictionary, &applier)
          param_types = [CFTypeRef, CFTypeRef, VoidPointer]
          closure = Fiddle::Closure::BlockCaller.new(Void, param_types, &applier)
          closure_function = Fiddle::Function.new(closure, param_types, Void)
          CFDictionaryApplyFunction(dictionary, closure_function, NULL)
        end

        def self.CFArrayApplyBlock(array)
          CFArrayGetCount(array).times do |index|
            yield CFArrayGetValueAtIndex(array, index)
          end
        end

        # @!group CFTypeRef to Ruby value conversion
        #---------------------------------------------------------------------------#

        def self.CFTypeRefToRubyValue(cf_type_reference)
          case CFGetTypeID(cf_type_reference)
          when CFStringGetTypeID()
            CFStringToRubyString(cf_type_reference)
          when CFDictionaryGetTypeID()
            CFDictionaryToRubyHash(cf_type_reference)
          when CFArrayGetTypeID()
            CFArrayToRubyArray(cf_type_reference)
          when CFBooleanGetTypeID()
            CFBooleanToRubyBoolean(cf_type_reference)
          when CFNumberGetTypeID()
            CFNumberToRubyNumber(cf_type_reference)
          else
            description = CFStringToRubyString(CFCopyDescription(cf_type_reference))
            raise TypeError, "Unknown type: #{description}"
          end
        end

        def self.CFStringToRubyString(string)
          data = CFStringCreateExternalRepresentation(NULL,
                                                      string,
                                                      KCFStringEncodingUTF8,
                                                      0)
          if data.null?
            raise TypeError, 'Unable to convert CFStringRef.'
          end
          bytes_ptr = CFDataGetBytePtr(data)
          result = bytes_ptr.to_str(CFDataGetLength(data))
          result.force_encoding(Encoding::UTF_8)
          result
        end

        def self.CFDictionaryToRubyHash(dictionary)
          result = {}
          CFDictionaryApplyBlock(dictionary) do |key, value|
            result[CFStringToRubyString(key)] = CFTypeRefToRubyValue(value)
          end
          result
        end

        def self.CFArrayToRubyArray(array)
          result = []
          CFArrayApplyBlock(array) do |element|
            result << CFTypeRefToRubyValue(element)
          end
          result
        end

        def self.CFBooleanToRubyBoolean(boolean)
          CFBooleanGetValue(boolean) == TRUE
        end

        def self.CFNumberToRubyNumber(number)
          if CFNumberIsFloatType(number) == FALSE
            value_type = KCFNumberSInt64Type
            pack_template = SINT64_PACK_TEMPLATE
            size = SIZEOF_SINT64
          else
            value_type = KCFNumberFloat64Type
            pack_template = FLOAT64_PACK_TEMPLATE
            size = SIZEOF_FLOAT64
          end
          ptr = Fiddle::Pointer.malloc(size)
          CFNumberGetValue(number, value_type, ptr)
          ptr.to_str.unpack(pack_template).first
        end

        # @!group Ruby value to CFTypeRef conversion
        #---------------------------------------------------------------------------#

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
                   when Numeric
                     RubyNumberToCFNumber(value)
                   else
                     RubyStringToCFString(value.to_s)
                   end
          if result.null?
            raise TypeError, "Unable to convert Ruby value `#{value.inspect}' " \
                             'into a CFTypeRef.'
          end
          result
        end

        def self.RubyStringToCFString(string)
          CFStringCreateWithCString(NULL,
                                    Fiddle::Pointer[string.encode('UTF-8')],
                                    KCFStringEncodingUTF8)
        end

        def self.RubyHashToCFDictionary(hash)
          result = CFDictionaryCreateMutable(NULL,
                                             0,
                                             CFTypeDictionaryKeyCallBacks(),
                                             CFTypeDictionaryValueCallBacks())
          hash.each do |key, value|
            key = RubyStringToCFString(key.to_s)
            value = RubyValueToCFTypeRef(value)
            CFDictionaryAddValue(result, key, value)
          end
          result
        end

        def self.RubyArrayToCFArray(array)
          result = CFArrayCreateMutable(NULL, 0, CFTypeArrayCallBacks())
          array.each do |element|
            element = RubyValueToCFTypeRef(element)
            CFArrayAppendValue(result, element)
          end
          result
        end

        def self.RubyNumberToCFNumber(value)
          case value
          when Float
            value_type = KCFNumberFloat64Type
            pack_template = FLOAT64_PACK_TEMPLATE
          when SINT64_MIN..SINT64_MAX
            value_type = KCFNumberSInt64Type
            pack_template = SINT64_PACK_TEMPLATE
          else # the value is too big to be stored in a CFNumber so store it as a CFString
            return RubyStringToCFString(value.to_s)
          end
          ptr = Fiddle::Pointer.to_ptr([value].pack(pack_template))
          CFNumberCreate(NULL, value_type, ptr)
        end

        def self.RubyBooleanToCFBoolean(value)
          value ? CFBooleanTrue() : CFBooleanFalse()
        end

        # rubocop:enable Style/MethodName
        # rubocop:enable Style/VariableName
      end
    end
  end
end
