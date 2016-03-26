//
//  CCZCacheDemoTests.m
//  CCZCacheDemoTests
//
//  Created by 郑雨阳 on 16/3/21.
//  Copyright © 2016年 cuocuo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCZCache.h"

@interface CCZCacheDemoTests : XCTestCase
@property (nonatomic, strong) CCZMemoryCache *memoryCache;
@end

@implementation CCZCacheDemoTests

- (void)setUp {
    [super setUp];
    _memoryCache = [CCZMemoryCache memoryCacheWithType:CCZMemoryCacheTypeLRU];
    _memoryCache.maxCountLimit = 100;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        
    }];
}

@end
