//
//  Objc_OSX_FrameworkTests.m
//  Objc_OSX_FrameworkTests
//
//  Created by Kyle Fuller on 27/10/2014.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface Objc_OSX_FrameworkTests : XCTestCase

@end

@implementation Objc_OSX_FrameworkTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
