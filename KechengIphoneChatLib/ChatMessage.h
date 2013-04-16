//
//  ChatMessage.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/16/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatUser.h"

typedef enum {
    senderTypeMe,
    senderTypeFriend
} senderType;

typedef enum {
    contentTypeText,
    contentTypeImage,
    contentTypeFile
} contentType;

@interface ChatMessage : NSObject

@property (nonatomic,retain) id <ChatUser> myFriend;

@property (nonatomic) senderType whoSend;

@property (nonatomic,retain) NSString* content;

@property (nonatomic) contentType contentType;

@property (nonatomic,retain) NSDate* date;

@property (nonatomic) BOOL isNew;

@end
