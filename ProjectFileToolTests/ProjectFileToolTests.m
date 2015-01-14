//
//  LocalisationToolTests.m
//  LocalisationToolTests
//
//  Created by Rob Jonson on 07/01/2015.
//  Copyright (c) 2015 HobbyistSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "ProjectParser.h"
#import "XCTest+HS.h"

@interface ProjectFileToolTests : XCTestCase

@property (retain) ProjectParser *parser;

@end

@implementation ProjectFileToolTests

- (void)setUp {
    [super setUp];
    
    ProjectParser *parser=[[ProjectParser new] autorelease];
    
    NSString *projectFile=[self pathForTestResource:@"LocalisationTestSubject" ofType:@""];
    projectFile=[projectFile stringByAppendingPathComponent:@"LocalisationTestSubject.xcodeproj"];
    
    [parser setXcodeProjPath:projectFile];
    [parser loadPlist];
    
    self.parser=parser;
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    self.parser=NULL;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(NSString*)testProjectLocation
{
    return @"/Users/rob/Documents/Development/Mac/MacDesktop/LocalisationTool/LocalisationToolTests/LocalisationTestSubject";
}

-(NSSet*)objectValuesForKey:(NSString*)infoKey fromDictionary:(NSDictionary*)dictionary lastPathComponent:(BOOL)lastPath
{
    NSMutableSet *values=[NSMutableSet set];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *value=[obj objectForKey:infoKey];
        if (lastPath)
        {
            value=[value lastPathComponent];
        }
        [values addObject:value];
    }];
    
    return values;
}



-(void)testFilesInTest
{
    [self.parser setAllowedTargets:@[@"TestTarget"]];
    
    NSSet *expectedNames=[NSSet setWithArray: @[@"ViewController.m",@"Tests.m"]];
    NSDictionary *filesAndPaths=[self.parser pathsAndFiles];
    NSSet *actualNames=[NSSet setWithArray:[filesAndPaths allValues]];
    
    XCTAssertEqualObjects(expectedNames,actualNames,@"TestTargetFiles");
}

-(void)testAbsolutePath
{
    NSDictionary *filesAndPaths=[self.parser pathsAndFiles];
    
    NSArray *paths=[filesAndPaths allKeysForObject:@"Absolute.m"];
    NSString *path=[paths firstObject];
    
    NSString *expectedPath=[self testProjectLocation];
    expectedPath=[expectedPath stringByAppendingPathComponent:@"Absolute.m"];
    
    XCTAssertEqualObjects(path, expectedPath,@"absolute");
    
    
    paths=[filesAndPaths allKeysForObject:@"Absolute1.m"];
    path=[paths firstObject];
    
    expectedPath=[self testProjectLocation];
    expectedPath=[expectedPath stringByAppendingPathComponent:@"Folder1/Absolute1.m"];
    
    XCTAssertEqualObjects(path, expectedPath,@"absolute1");
}

-(void)checkFileFor:(NSString*)file
{
    NSDictionary *filesAndPaths=[self.parser pathsAndFiles];
    
    NSArray *paths=[filesAndPaths allKeysForObject:file];
    NSString *path=[paths firstObject];
    
    NSString *lastComponent=[path lastPathComponent];
    XCTAssertEqualObjects(lastComponent, file,@"last component matches");
    
    BOOL exists=[[NSFileManager defaultManager] fileExistsAtPath:path];
    XCTAssertTrue(exists,@"file exists: %@",path);
}

-(void)testRelativePathBase
{
    [self checkFileFor:@"RelToGroup.m"];
}

-(void)testRelativePath1
{
    [self checkFileFor:@"RelToGroup1.m"];
}

-(void)testRelativePath2
{
    [self checkFileFor:@"RelToGroup2.m"];
}

-(void)testGroupForFileRef
{
    NSDictionary *group=[self.parser groupForFileRef:@"D43892521A5D796D009D7E1F"];
    NSArray *keys=[group allKeys];
    NSArray *values=[group allValues];
    
    XCTAssertEqual(1, [keys count]);
    XCTAssertEqual(1,[values count]);
    
    XCTAssertEqualObjects([keys firstObject], @"D438922E1A5D791A009D7E1F");
    
    NSDictionary *groupInfo=[[group allValues] firstObject];
    NSString *path=[groupInfo objectForKey:@"path"];
    NSString *tree=[groupInfo objectForKey:@"sourceTree"];
    
    XCTAssertEqualObjects(path, @"LocalisationTestSubject");
    XCTAssertEqualObjects(tree, @"<group>");
    
}

-(void)testExtractProjectInfo
{
    [self.parser extractProjectInfo];
    
    XCTAssertEqualObjects(self.parser.mainGroupRef, @"D43892231A5D7919009D7E1F");
}


-(void)testExpectedTargets
{
    [self.parser extractTargets];
    

    NSSet *expectedNames=[NSSet setWithArray:@[@"BaseTarget",@"TestTarget"]];

    NSSet *actualNames=[self objectValuesForKey:@"name"
                                        fromDictionary:[self.parser targets]
                                     lastPathComponent:NO];
    
    XCTAssertEqualObjects(expectedNames,actualNames,@"matching targets");
}




@end
