begin
  require 'fiddle'
rescue LoadError
  message = 'Xcodeproj relies on a library called `fiddle` to read and write ' \
            'Xcode project files. Ensure your Ruby installation includes ' \
            '`fiddle` and try again.'
  raise Xcodeproj::Informative, message
end

module Xcodeproj
  # TODO: Delete me (compatibility with Ruby 1.8.7 C ext bundle)
  def self.read_plist(path)
    PlistHelper.read(path)
  end

  # TODO: Delete me (compatibility with Ruby 1.8.7 C ext bundle)
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
      def write(possible_hash, path)
        if possible_hash.respond_to?(:to_hash)
          hash = possible_hash.to_hash
        else
          raise TypeError, "The given `#{possible_hash.inspect}` must respond " \
                            "to #to_hash'."
        end

        unless path.is_a?(String) || path.is_a?(Pathname)
          raise TypeError, "The given `#{path}` must be a string or 'pathname'."
        end
        path = path.to_s
        raise IOError, 'Empty path.' if path == ''

        if DevToolsCore.load_xcode_frameworks && path.end_with?('pbxproj')
          ruby_hash_write_xcode(hash, path)
        else
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
      def read(path)
        path = path.to_s
        unless File.exist?(path)
          raise Informative, "The plist file at path `#{path}` doesn't exist."
        end
        if file_in_conflict?(path)
          raise Informative, "The file `#{path}` is in a merge conflict."
        end
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
        input = File.open(filename, 'rb') { |file| file.read }
        input.unpack('U*').each do |codepoint|
          if codepoint > 127 # ASCII is 7-bit, so 0-127 are valid characters
            output << "&##{codepoint};"
          else
            output << codepoint.chr
          end
        end
        File.open(filename, 'wb') { |file| file.write(output) }
      end

      # @return [Bool] Checks whether there are merge conflicts in the file.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def file_in_conflict?(path)
        file = File.open(path)
        file.each_line.any? { |l| l.match(/^(<|=|>){7}/) }
      ensure
        file.close
      end

      # Serializes a hash as an ASCII plist, using Xcode.
      #
      # @param  [Hash] hash
      #         The hash to store.
      #
      # @param  [String] path
      #         The path of the file.
      #
      def ruby_hash_write_xcode(hash, path)
        path = File.expand_path(path)
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

        CoreFoundation.RubyHashPropertyListWrite(hash, path) unless success
      end
    end
  end
end

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
  extern :CFNumberCreate,  [CFTypeRef, CFNumberType, VoidPointer], CFTypeRef

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
                              Fiddle::Pointer[string],
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
