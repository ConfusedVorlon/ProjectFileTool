//
//  XCTest+HS.m
//  VLCStreamer2
//
//  Created by Rob Jonson on 23/12/2014.
//
//

#import "XCTest+HS.h"

@implementation XCTest(HS)

- (NSString *)pathForTestResource:(NSString *)name ofType:(NSString *)ext
{
    NSBundle *testBundle=[NSBundle bundleForClass:self.class];
    return [testBundle pathForResource:name ofType:ext];
}

@end
