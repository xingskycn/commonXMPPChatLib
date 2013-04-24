//
//  ChatEmojis.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatEmojis : NSObject
{
    NSArray* _allEmojis;
}

//return our big list of hard-coded emojis
-(NSArray*)allEmojis;

@end
