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

-(NSMutableArray *)MessagesAboutMyFriend:(id<ChatUser>)chatFriend page:(int)page;

-(NSMutableArray *)unreadMessagesAboutMyFriend:(id<ChatUser>)chatFriend;

-(BOOL)unreadMessage2ReadMessage:(id<ChatUser>)chatFriend;

-(BOOL)resendChatMessageSucceed:(ChatMessage *)message;

-(NSMutableArray *)MessagesForMessageCenter:(id<ChatUser>)me;

//Chat friends
-(BOOL)createChatFriendsTable;

-(BOOL)insertOrUpdateChatFriend:(id<ChatUser>)chatUser;

-(BOOL)getChatUserInformation:(id<ChatUser>)chatUser;

-(BOOL)deleteAllFriendInformation;
@end
