//
//  XCTest+HS.h
//  VLCStreamer2
//
//  Created by Rob Jonson on 23/12/2014.
//
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@interface XCTest(HS)

- (NSString *)pathForTestResource:(NSString *)name ofType:(NSString *)ext;

@end
