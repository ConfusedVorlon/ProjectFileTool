//
//  ProjectParser.h
//  LocalisationTool
//
//  Created by Rob Jonson on 07/01/2015.
//  Copyright (c) 2015 HobbyistSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectParser : NSObject

@property (strong) NSString *xcodeProjPath;
@property (strong) NSArray *allowedTargets;


-(NSDictionary*)pathsAndFiles;
-(NSArray*)getTargets;

//exposed for testing
@property (strong) NSDictionary *targets;
@property (strong) NSDictionary *buildPhases;
@property (strong) NSString *mainGroupRef;

-(void)loadPlist;
-(void)extractTargets;
-(void)extractProjectInfo;
-(NSDictionary*)groupForFileRef:(NSString*)reference;

@end
