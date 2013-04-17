//
//  ChatMessage.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/16/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatUser.h"
#import "ChatDefinitions.h"

@interface ChatMessage : NSObject

@property (nonatomic,retain) id <ChatUser> myFriend;

@property (nonatomic) CHAT_SENDER_TYPE whoSend;

@property (nonatomic,retain) NSString* content;

@property (nonatomic) CHAT_CONTENT_TYPE contentType;

@property (nonatomic,retain) NSDate* date;

@property (nonatomic) BOOL isNew;

@end
