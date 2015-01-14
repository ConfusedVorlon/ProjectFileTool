//
//  ProjectParser.m
//  LocalisationTool
//
//  Created by Rob Jonson on 07/01/2015.
//  Copyright (c) 2015 HobbyistSoftware. All rights reserved.
//

#import "ProjectParser.h"



@interface ProjectParser ()

@property (retain) NSDictionary *plistObjects;

@end

@implementation ProjectParser

-(void)loadPlist
{
    NSString *projectPath=[self.xcodeProjPath stringByAppendingPathComponent:@"project.pbxproj"];
    
    NSDictionary *plist=[[NSMutableDictionary alloc] initWithContentsOfFile:projectPath];
    NSDictionary *objects=[plist objectForKey:@"objects"];
    
    self.plistObjects=objects;
}

-(NSString*)sourceRoot
{
    return [self.xcodeProjPath stringByDeletingLastPathComponent];
}

-(void)extractBuildPhases
{
    NSArray *interestingExtensions=@[@"PBXSourcesBuildPhase",@"PBXResourcesBuildPhase"];
    
    NSMutableDictionary *interestingObjects=[NSMutableDictionary dictionary];
    
    [self.plistObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *details=obj;
        NSString *type=[details objectForKey:@"isa"];
        if ([interestingExtensions containsObject:type])
        {
            [interestingObjects setObject:obj forKey:key];
        }
    }];
    
    self.buildPhases=interestingObjects;
}


-(void)extractTargets
{
    NSMutableDictionary *interestingObjects=[NSMutableDictionary dictionary];
    
    [self.plistObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *details=obj;
        NSString *type=[details objectForKey:@"isa"];
        if ([type isEqualToString:@"PBXNativeTarget"])
        {
            [interestingObjects setObject:obj forKey:key];
        }
    }];
    
    self.targets=interestingObjects;
}

-(void)extractProjectInfo
{
    [self.plistObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *details=obj;
        NSString *type=[details objectForKey:@"isa"];
        if ([type isEqualToString:@"PBXProject"])
        {
            self.mainGroupRef=[details objectForKey:@"mainGroup"];
            *stop=YES;
        }
    }];
    
}


/** returns key and dictionary as value */
-(NSDictionary*)fileForFileReference:(NSString*)reference
{
    NSDictionary *fileRef=[self.plistObjects objectForKey:reference];
    NSString *fileKey=[fileRef objectForKey:@"fileRef"];
    NSDictionary *fileObject=[self.plistObjects objectForKey:fileKey];
    
    return [NSDictionary dictionaryWithObject:fileObject
                                       forKey:fileKey];
}

-(NSDictionary *)filesFromTargetObject:(NSDictionary*)targetObject
{
    NSMutableDictionary *targetFiles=[NSMutableDictionary dictionary];
    
    NSArray *buildPhaseRefs=[targetObject objectForKey:@"buildPhases"];
    
    [buildPhaseRefs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *buildPhase=[self.buildPhases objectForKey:obj];
        NSString *buildType=[buildPhase objectForKey:@"isa"];
        
        if (buildPhase)
        {
            NSArray *files=[buildPhase objectForKey:@"files"];
            [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *file=[self fileForFileReference:obj];
                
                NSArray *interestingExtensions=@[@"xib",@"m",@"storyboard",@"swift"];
                if ([buildType isEqualToString:@"PBXResourcesBuildPhase"])
                {
                    interestingExtensions=@[@"xib",@"storyboard"];
                }
                
                NSDictionary *fileObject=[[file allValues] firstObject];
                NSString *fileType=[[[fileObject objectForKey:@"path"] pathExtension] lowercaseString];
                
                if ([interestingExtensions containsObject:fileType])
                {
                    [targetFiles addEntriesFromDictionary:file];
                }
            }];
            
        }
    }];
    
    return targetFiles;
}

-(NSDictionary*)groupForFileRef:(NSString*)reference
{
    __block NSDictionary *foundGroup=NULL;
    
    [self.plistObjects enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* obj, BOOL *stop) {
        NSString *type=[obj objectForKey:@"isa"];
        if ([type isEqualToString:@"PBXGroup"])
        {
            NSArray *children=[obj objectForKey:@"children"];
            if ([children containsObject:reference])
            {
                NSDictionary *group=[[NSDictionary dictionaryWithObject:obj forKey:key] retain];
                *stop=YES;
                foundGroup = group;
            }
        }
        
    }];
    
    
    return [foundGroup autorelease];
}

-(NSString*)groupPathForFileRef:(NSString*)reference
{
    NSString *fullPath=NULL;
    
    NSDictionary *groupForFileRef=[self groupForFileRef:reference];
    if (groupForFileRef)
    {
        NSString *groupRef=[[groupForFileRef allKeys] firstObject];
        if ([groupRef isEqualToString:self.mainGroupRef])
        {
            fullPath = [self sourceRoot];
        }
        else
        {
            NSDictionary *groupInfo=[[groupForFileRef allValues] firstObject];
            
            NSString *groupPath=[groupInfo objectForKey:@"path"];
            if (!groupPath)
            {
                groupPath=@"";
            }
            
            NSString *groupAntecedantPath=[self pathForFileRef:groupRef];
            if (!groupAntecedantPath)
            {
                groupAntecedantPath=@"";
            }
            
            fullPath=[groupAntecedantPath stringByAppendingPathComponent:groupPath];
        }
    }
    
    return fullPath;
}

-(NSString*)pathForFileRef:(NSString*)reference
{
    NSDictionary *fileInfo=[self.plistObjects objectForKey:reference];
    NSString *path=[fileInfo objectForKey:@"path"];
    NSString *referenceType=[fileInfo objectForKey:@"sourceTree"];
    
    if ([referenceType isEqualToString:@"SDKROOT"])
    {
        path=[@"SDKROOT" stringByAppendingPathComponent:path];
    }
    else if ([referenceType isEqualToString:@"DEVELOPER_DIR"])
    {
        path=[@"DEVELOPER_DIR" stringByAppendingPathComponent:path];
    }
    else if ([referenceType isEqualToString:@"SOURCE_ROOT"])
    {
        path=[[self sourceRoot] stringByAppendingPathComponent:path];
    }
    else if ([referenceType isEqualToString:@"<group>"])
    {
        NSString *groupPath=[self groupPathForFileRef:reference];
        
        NSString *type=[fileInfo objectForKey:@"isa"];
        if ([type isEqualToString:@"PBXFileReference"])
        {
            path=[groupPath stringByAppendingPathComponent:path];
        }
        else
        {
            path=groupPath;
        }
        
    }
    
    path=[path stringByStandardizingPath];
    
    //NSLog(@"Reference: %@ - standardizedPath: %@\n",referenceType,path);
    
    return path;
}

/** returns dictionary with path as key, and filename as value **/
-(NSDictionary*)pathsAndFiles;
{
    [self loadPlist];
    [self extractTargets];
    [self extractBuildPhases];
    [self extractProjectInfo];
    
    NSMutableDictionary *filesUsedByTargets=[NSMutableDictionary dictionary];
    
    [self.targets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *targetInfo=obj;
        NSString *targetName=[targetInfo objectForKey:@"name"];
        if (!self.allowedTargets || [self.allowedTargets containsObject:targetName])
        {
            [filesUsedByTargets addEntriesFromDictionary:[self filesFromTargetObject:targetInfo]];
        }
    }];
    
    NSMutableDictionary *pathsAndFiles=[NSMutableDictionary dictionary];
    
    [filesUsedByTargets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *filename=[[obj objectForKey:@"path"] lastPathComponent];

        NSString *path=[self pathForFileRef:key];
        
        [pathsAndFiles setObject:filename forKey:path];
    }];
    
    return pathsAndFiles;
}

-(NSArray*)getTargets
{
    [self loadPlist];
    [self extractTargets];
    
    NSMutableArray *targets=[NSMutableArray array];
    
    [self.targets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *targetInfo=obj;
        NSString *targetName=[targetInfo objectForKey:@"name"];
        [targets addObject:targetName];
    }];
    
    return targets;
}

@end
