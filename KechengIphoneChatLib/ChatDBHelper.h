//
//  ChatDBHelper.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/16/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"
#import "ChatUser.h"

@interface ChatDBHelper : NSObject

@property (nonatomic, retain) NSString* chatDBPath;

+(ChatDBHelper*)sharedInstance;

-(BOOL)createChatMessageTable;

-(BOOL)insertChatMessage:(ChatMessage *)message;

-(NSMutableArray *)MessagesAboutMyFriend:(id<ChatUser>)chatFriend page:(int)page;

-(NSMutableArray *)unreadMessagesAboutMyFriend:(id<ChatUser>)chatFriend;

-(BOOL)unreadMessage2readMessage:(id<ChatUser>)chatFriend;

@end
