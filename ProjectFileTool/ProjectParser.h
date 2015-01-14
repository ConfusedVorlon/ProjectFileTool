//
//  ProjectParser.h
//  LocalisationTool
//
//  Created by Rob Jonson on 07/01/2015.
//  Copyright (c) 2015 HobbyistSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectParser : NSObject

@property (retain) NSString *xcodeProjPath;
@property (retain) NSArray *allowedTargets;


-(NSDictionary*)pathsAndFiles;
-(NSArray*)getTargets;

//exposed for testing
@property (retain) NSDictionary *targets;
@property (retain) NSDictionary *buildPhases;
@property (retain) NSString *mainGroupRef;

-(void)loadPlist;
-(void)extractTargets;
-(void)extractProjectInfo;
-(NSDictionary*)groupForFileRef:(NSString*)reference;

@end
