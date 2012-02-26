// TODO
// * free memory when raising

#include "extconf.h"

#include "ruby.h"
#include "ruby/st.h"
#include "CoreFoundation/CoreFoundation.h"
#include "CoreFoundation/CFStream.h"
#include "CoreFoundation/CFPropertyList.h"

VALUE Xcodeproj = Qnil;


static VALUE
cfstr_to_str(const void *cfstr) {
  long len = (long)CFStringGetLength(cfstr);
  char *buf = (char *)malloc(len+1);
  assert(buf != NULL);
  CFStringGetCString(cfstr, buf, len+1, kCFStringEncodingUTF8);
  register VALUE str = rb_str_new(buf, len);
  free(buf);
  return str;
}

// Coerces to String as well.
static CFStringRef
str_to_cfstr(VALUE str) {
  return CFStringCreateWithCString(NULL, RSTRING_PTR(rb_String(str)), kCFStringEncodingUTF8);
}

/* Generates a UUID. The original version is truncated, so this is not 100%
 * guaranteed to be unique. However, the `PBXObject#generate_uuid` method
 * checks that the UUID does not exist yet, in the project, before using it.
 *
 * @note Meant for internal use only.
 *
 * @return [String] A 24 characters long UUID.
 */
static VALUE
generate_uuid(void) {
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  CFStringRef strRef = CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);

  CFArrayRef components = CFStringCreateArrayBySeparatingStrings(NULL, strRef, CFSTR("-"));
  CFRelease(strRef);
  strRef = CFStringCreateByCombiningStrings(NULL, components, CFSTR(""));
  CFRelease(components);

  UniChar buffer[24];
  CFStringGetCharacters(strRef, CFRangeMake(0, 24), buffer);
  CFStringRef strRef2 = CFStringCreateWithCharacters(NULL, buffer, 24);

  VALUE str = cfstr_to_str(strRef2);
  CFRelease(strRef);
  CFRelease(strRef2);
  return str;
}


static void
hash_set(const void *keyRef, const void *valueRef, void *hash) {
  VALUE key = cfstr_to_str(keyRef);
  register VALUE value = Qnil;

  CFTypeID valueType = CFGetTypeID(valueRef);
  if (valueType == CFStringGetTypeID()) {
    value = cfstr_to_str(valueRef);

  } else if (valueType == CFDictionaryGetTypeID()) {
    value = rb_hash_new();
    CFDictionaryApplyFunction(valueRef, hash_set, (void *)value);

  } else if (valueType == CFArrayGetTypeID()) {
    value = rb_ary_new();
    CFIndex i, count = CFArrayGetCount(valueRef);
    for (i = 0; i < count; i++) {
      CFStringRef x = CFArrayGetValueAtIndex(valueRef, i);
      if (CFGetTypeID(x) == CFStringGetTypeID()) {
        rb_ary_push(value, cfstr_to_str(x));
      } else {
        rb_raise(rb_eTypeError, "Plist array value contains a object type unsupported by Xcodeproj.");
      }
    }

  } else {
    rb_raise(rb_eTypeError, "Plist contains a hash value object type unsupported by Xcodeproj.");
  }

  rb_hash_aset((VALUE)hash, key, value);
}

static int
dictionary_set(st_data_t key, st_data_t value, CFMutableDictionaryRef dict) {
  CFStringRef keyRef = str_to_cfstr(key);

  CFTypeRef valueRef = NULL;
  if (TYPE(value) == T_HASH) {
    valueRef = CFDictionaryCreateMutable(NULL,
                                         0,
                                         &kCFTypeDictionaryKeyCallBacks,
                                         &kCFTypeDictionaryValueCallBacks);
    st_foreach(RHASH_TBL(value), dictionary_set, (st_data_t)valueRef);

  } else if (TYPE(value) == T_ARRAY) {
    long i, count = RARRAY_LEN(value);
    valueRef = CFArrayCreateMutable(NULL, count, &kCFTypeArrayCallBacks);
    for (i = 0; i < count; i++) {
      CFStringRef x = str_to_cfstr(RARRAY_PTR(value)[i]);
      CFArrayAppendValue((CFMutableArrayRef)valueRef, x);
      CFRelease(x);
    }

  } else {
    valueRef = str_to_cfstr(value);
  }

  CFDictionaryAddValue(dict, keyRef, valueRef);
  CFRelease(keyRef);
  CFRelease(valueRef);
  return ST_CONTINUE;
}

static CFURLRef
str_to_url(VALUE path) {
#ifdef FilePathValue
  VALUE p = FilePathValue(path);
#else
  VALUE p = rb_String(path);
#endif
  CFURLRef fileURL = CFURLCreateFromFileSystemRepresentation(NULL, RSTRING_PTR(p), RSTRING_LEN(p), false);
  if (!fileURL) {
    rb_raise(rb_eArgError, "Unable to create CFURL from `%s'.", RSTRING_PTR(rb_inspect(path)));
  }
  return fileURL;
}


/* @overload read_plist(path)
 *
 * Reads from the specified path and de-serializes the property list.
 *
 * @note Meant for internal use only.
 *
 * @note This currently only assumes to be given an Xcode project document.
 *       This means that it only accepts dictionaries, arrays, and strings in
 *       the document.
 *
 * @param [String] path  The path to the property list file.
 * @return [Hash]        The dictionary contents of the document.
 */
static VALUE
read_plist(VALUE self, VALUE path) {
  CFPropertyListRef dict;
  CFStringRef       errorString;
  CFDataRef         resourceData;
  SInt32            errorCode;

  CFURLRef fileURL = str_to_url(path);
  if (CFURLCreateDataAndPropertiesFromResource(NULL, fileURL, &resourceData, NULL, NULL, &errorCode)) {
    CFRelease(fileURL);
  }
  if (!resourceData) {
    rb_raise(rb_eArgError, "Unable to read data from `%s'", RSTRING_PTR(rb_inspect(path)));
  }

  dict = CFPropertyListCreateFromXMLData(NULL, resourceData, kCFPropertyListImmutable, &errorString);
  if (!dict) {
    rb_raise(rb_eArgError, "Unable to read plist data from `%s': %s", RSTRING_PTR(rb_inspect(path)), RSTRING_PTR(cfstr_to_str(errorString)));
  }
  CFRelease(resourceData);

  register VALUE hash = rb_hash_new();
  CFDictionaryApplyFunction(dict, hash_set, (void *)hash);
  CFRelease(dict);

  return hash;
}

/* @overload write_plist(hash, path)
 *
 * Writes the serialized contents of a property list to the specified path.
 *
 * @note Meant for internal use only.
 *
 * @note This currently only assumes to be given an Xcode project document.
 *       This means that it only accepts dictionaries, arrays, and strings in
 *       the document.
 *
 * @param [Hash] hash     The property list to serialize.
 * @param [String] path   The path to the property list file.
 * @return [true, false]  Wether or not serialization was successful.
 */
static VALUE
write_plist(VALUE self, VALUE hash, VALUE path) {
  VALUE h = rb_check_convert_type(hash, T_HASH, "Hash", "to_hash");
  if (NIL_P(h)) {
    rb_raise(rb_eTypeError, "%s can't be coerced to Hash", rb_obj_classname(hash));
  }

  CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL,
                                                          0,
                                                          &kCFTypeDictionaryKeyCallBacks,
                                                          &kCFTypeDictionaryValueCallBacks);

  st_foreach(RHASH_TBL(h), dictionary_set, (st_data_t)dict);

  CFURLRef fileURL = str_to_url(path);
  CFWriteStreamRef stream = CFWriteStreamCreateWithFile(NULL, fileURL);
  CFRelease(fileURL);

  CFIndex success = 0;
  if (CFWriteStreamOpen(stream)) {
    CFStringRef errorString;
    success = CFPropertyListWriteToStream(dict, stream, kCFPropertyListXMLFormat_v1_0, &errorString);
    if (!success) {
      CFShow(errorString);
    }
  } else {
    printf("Unable to open stream!\n");
  }

  CFRelease(dict);
  return success ? Qtrue : Qfalse;
}


void Init_xcodeproj_ext() {
  Xcodeproj = rb_define_module("Xcodeproj");
  rb_define_singleton_method(Xcodeproj, "generate_uuid", generate_uuid, 0);
  rb_define_singleton_method(Xcodeproj, "read_plist", read_plist, 1);
  rb_define_singleton_method(Xcodeproj, "write_plist", write_plist, 2);
}
