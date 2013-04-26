//
//  ChatUser.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/16/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatUser <NSObject>

-(int)chatUserId;

-(NSString*)xmppPassword;

-(NSString*)xmppUserName;

+(NSString*)userNameFromXmppUserName:(NSString*) xmppUserName;

-(NSString*)tinyAvatarUrl;

-(NSString*)chatUserName;

-(void)setTinyAvatarUrl:(NSString*)tinyAvatarUrl;

-(void)setChatUserName:(NSString*)chatUserName;

-(id<ChatUser>)buildChatUserFromXmppUserName:(NSString*) xmppUserName;

-(id<ChatUser>)buildChatUserFromUserId:(int)userId;

@end
