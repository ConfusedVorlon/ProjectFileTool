//
//  CommandHandler.h
//  LocalisationTool
//
//  Created by Rob Jonson on 13/01/2015.
//  Copyright (c) 2015 HobbyistSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandHandler : NSObject

-(BOOL)runWithArguments:(NSArray*)arguments;

@end
