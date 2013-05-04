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

//Chat message
-(BOOL)createChatMessageTable;

-(BOOL)insertChatMessage:(ChatMessage *)message;

-(NSMutableArray *)MessagesAboutMyFriend:(id<ChatUser>)chatFriend startIndex:(int)startIndex;

-(NSMutableArray *)unreadMessagesAboutMyFriend:(id<ChatUser>)chatFriend;

-(BOOL)unreadMessage2ReadMessage:(id<ChatUser>)chatFriend;

-(BOOL)resendChatMessageSucceed:(ChatMessage *)message;

-(int)unreadMessageCountOfMyFriend:(id<ChatUser>)chatFriend;

-(int)unreadMessageCount;
-(ChatMessage*)lastMessageOfMyFriend:(id<ChatUser>)chatFriend;

-(NSMutableArray *)MessagesForMessageCenter:(id<ChatUser>)me;

@end
