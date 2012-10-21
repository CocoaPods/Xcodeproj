//
//  GetMetadataForFile.m
//  Cocoa ApplicationImporter
//
//  Created by Fabio Pelosin on 09/10/12.
//  Copyright (c) 2012 CocoaPods. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <CoreData/CoreData.h>
#import "MySpotlightImporter.h"

Boolean GetMetadataForFile(void *thisInterface, CFMutableDictionaryRef attributes, CFStringRef contentTypeUTI, CFStringRef pathToFile);

//==============================================================================
//
//	Get metadata attributes from document files
//
//	The purpose of this function is to extract useful information from the
//	file formats for your document, and set the values into the attribute
//  dictionary for Spotlight to include.
//
//==============================================================================

Boolean GetMetadataForFile(void *thisInterface, CFMutableDictionaryRef attributes, CFStringRef contentTypeUTI, CFStringRef pathToFile)
{
    // Pull any available metadata from the file at the specified path
    // Return the attribute keys and attribute values in the dict
    // Return TRUE if successful, FALSE if there was no data provided
	// The path could point to either a Core Data store file in which
	// case we import the store's metadata, or it could point to a Core
	// Data external record file for a specific record instances

    Boolean ok = FALSE;
    @autoreleasepool {
        NSError *error = nil;
        
        if ([(__bridge NSString *)contentTypeUTI isEqualToString:@"YOUR_STORE_FILE_UTI"]) {
            // import from store file metadata
            
            // Create the URL, then attempt to get the meta-data from the store
            NSURL *url = [NSURL fileURLWithPath:(__bridge NSString *)pathToFile];
            NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:url error:&error];
            
            // If there is no error, add the info
            if (error == NULL) {
                // Get the information you are interested in from the dictionary
                // "YOUR_INFO" should be replaced by key(s) you are interested in
                
                NSObject *contentToIndex = metadata[@"YOUR_INFO"];
                if (contentToIndex != nil) {
                    // Add the metadata to the text content for indexing
                    ((__bridge NSMutableDictionary *)attributes)[(NSString *)kMDItemTextContent] = contentToIndex;
                    ok = TRUE;
                }
            }
            
        } else if ([(__bridge NSString *)contentTypeUTI isEqualToString:@"YOUR_EXTERNAL_RECORD_UTI"]) {
            // import from an external record file
            
            MySpotlightImporter *importer = [[MySpotlightImporter alloc] init];
            
            ok = [importer importFileAtPath:(__bridge NSString *)pathToFile attributes:(__bridge NSMutableDictionary *)attributes error:&error];
        }
    }
    
	// Return the status
    return ok;
}
