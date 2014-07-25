// * OS X: mkdir -p obj && clang -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk -ObjC -framework Foundation plutil.m -o obj/plutil
//
// * Linux: apt-get install libgnustep-base-dev && make
//
// Test:
//
//   $ ./plutil -convert xml1 '../fixtures/Sample Project/Cocoa Application.xcodeproj/project.pbxproj' -o - | ./plutil -convert xml1 - -o test.plist

#import <Foundation/Foundation.h>
#include <unistd.h>

static NSData *
DictToXMLPlist(NSDictionary *dict)
{
  NSError *error = nil;
  NSData *data = [NSPropertyListSerialization dataWithPropertyList:dict
                                                            format:NSPropertyListXMLFormat_v1_0
                                                           options:0
                                                             error:&error];
  if (data == nil) {
    fprintf(stderr, "An error occurred: %s\n", [[error description] UTF8String]);
  }
  return data;
}

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  BOOL success = YES;

  NSArray *args = [[NSProcessInfo processInfo] arguments];
  if ([args count] == 6
      && [[args objectAtIndex:1] isEqualToString:@"-convert"]
      && [[args objectAtIndex:2] isEqualToString:@"xml1"]
      && [[args objectAtIndex:4] isEqualToString:@"-o"]
      && [[args objectAtIndex:5] isEqualToString:@"-"]) {
    NSString *path = [args objectAtIndex:3];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSData *data = DictToXMLPlist(dict);
    if (data != nil) {
      write(fileno(stdout), [data bytes], [data length]);
    }
    else {
      success = NO;
    }
  }
  else if ([args count] == 6
      && [[args objectAtIndex:1] isEqualToString:@"-convert"]
      && [[args objectAtIndex:2] isEqualToString:@"xml1"]
      && [[args objectAtIndex:3] isEqualToString:@"-"]
      && [[args objectAtIndex:4] isEqualToString:@"-o"]) {
    NSString *path = [args objectAtIndex:5];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleWithStandardInput];
    NSData *data = [fileHandle readDataToEndOfFile];
    NSError *error = nil;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data
                                                                   options:NSPropertyListImmutable
                                                                    format:NULL
                                                                     error:&error];
    if (dict == nil) {
      fprintf(stderr, "An error occurred: %s\n", [[error description] UTF8String]);
      success = NO;
    }
    else {
      data = DictToXMLPlist(dict);
      if (data != nil) {
        [data writeToFile:path atomically:YES];
      }
      else {
        success = NO;
      }
    }
  }
  else {
    fprintf(stderr, "Incorrect invocation! Should be either one of:\n" \
                    "* plutil -convert xml1 PATH -o -\n" \
                    "* plutil -convert xml1 - -o PATH\n");
    success = NO;
  }

  [pool drain];
  exit(success ? 0 : 1);
}
