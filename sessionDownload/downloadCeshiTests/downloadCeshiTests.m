//
//  downloadCeshiTests.m
//  downloadCeshiTests
//
//  Created by 瞄财网 on 2017/3/15.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface downloadCeshiTests : XCTestCase

@end

@implementation downloadCeshiTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    time = time * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%@",@(time)];
    NSRange range = [timeString rangeOfString:@"."];
    NSLog(@"%@   %@",timeString,[timeString substringToIndex:range.location]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
