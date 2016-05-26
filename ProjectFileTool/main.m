//
//  main.m
//  LocalisationTool
//
//  Created by Rob Jonson on 14/01/2015.
//  Copyright (c) 2015 HobbyistSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandHandler.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSMutableArray *arguments=[NSMutableArray array];
        for (int i=0; i<argc; i++)
        {
            NSString *str = [NSString stringWithUTF8String:argv[i]];
            //NSLog(@"argv[%d] = '%@'", i, str);
            [arguments addObject:str];
        }
        
        CommandHandler *handler=[CommandHandler new];
        BOOL result=[handler runWithArguments:arguments];
        
        return result;
        
    }
}


