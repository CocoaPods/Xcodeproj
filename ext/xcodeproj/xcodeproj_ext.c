// TODO
// * raise when there are objects other than string, hash, or array in the given list
// * there should only be arrays with strings in a pbxproj! raise if there are other types


#include "ruby.h"
#include "ruby/st.h"
#include <CoreFoundation/CoreFoundation.h>

VALUE Xcodeproj = Qnil;

static VALUE
cfstr_to_str(const void *cfstr) {
  long len = (long)CFStringGetLength(cfstr);
  char buf[len+1];
  CFStringGetCString(cfstr, buf, len+1, kCFStringEncodingUTF8);
  return rb_str_new(buf, len);
}

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
  VALUE value = Qnil;

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
      rb_ary_push(value, cfstr_to_str(x));
    }

  } else {
    // TODO raise!
    printf("Unknown type in property list.\n");
    abort();
  }

  rb_hash_aset((VALUE)hash, key, value);
}

// TODO handle errors
static VALUE
read_plist(VALUE self, VALUE path) {
  CFPropertyListRef dict;
  CFStringRef       errorString;
  CFDataRef         resourceData;
  Boolean           status;
  SInt32            errorCode;

  CFURLRef fileURL = CFURLCreateFromFileSystemRepresentation(NULL, RSTRING_PTR(path), RSTRING_LEN(path), false);
  status = CFURLCreateDataAndPropertiesFromResource(NULL, fileURL, &resourceData, NULL, NULL, &errorCode);
  CFRelease(fileURL);

  dict = CFPropertyListCreateFromXMLData(NULL, resourceData, kCFPropertyListImmutable, &errorString);
  CFRelease(resourceData);

  VALUE hash = rb_hash_new();
  CFDictionaryApplyFunction(dict, hash_set, (void *)hash);
  CFRelease(dict);

  return hash;
}

#define STR_TO_CFSTR(str) CFStringCreateWithCString(NULL, RSTRING_PTR(str), kCFStringEncodingUTF8)

static int
dictionary_set(st_data_t key, st_data_t value, CFMutableDictionaryRef dict) {
  CFStringRef keyRef = STR_TO_CFSTR(key);

  CFTypeRef valueRef = NULL;
  if (TYPE(value) == T_STRING) {
    valueRef = STR_TO_CFSTR(value);

  } else if (TYPE(value) == T_HASH) {
    valueRef = CFDictionaryCreateMutable(NULL,
                                         0,
                                         &kCFTypeDictionaryKeyCallBacks,
                                         &kCFTypeDictionaryValueCallBacks);
    st_foreach(RHASH_TBL(value), dictionary_set, (st_data_t)valueRef);

  } else if (TYPE(value) == T_ARRAY) {
    long i, count = RARRAY_LEN(value);
    valueRef = CFArrayCreateMutable(NULL, count, &kCFTypeArrayCallBacks);
    for (i = 0; i < count; i++) {
      CFStringRef x = STR_TO_CFSTR(RARRAY_PTR(value)[i]);
      CFArrayAppendValue((CFMutableArrayRef)valueRef, x);
      CFRelease(x);
    }

  } else {
    printf("SOMETHING ELSE!\n");
    abort();
  }

  CFDictionaryAddValue(dict, keyRef, valueRef);
  CFRelease(keyRef);
  CFRelease(valueRef);
  return ST_CONTINUE;
}

static VALUE
write_plist(VALUE self, VALUE hash, VALUE path) {
  CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL,
                                                          0,
                                                          &kCFTypeDictionaryKeyCallBacks,
                                                          &kCFTypeDictionaryValueCallBacks);
  st_foreach(RHASH_TBL(hash), dictionary_set, (st_data_t)dict);

  CFURLRef fileURL = CFURLCreateFromFileSystemRepresentation(NULL, RSTRING_PTR(path), RSTRING_LEN(path), false);
  CFWriteStreamRef stream = CFWriteStreamCreateWithFile(NULL, fileURL);

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
