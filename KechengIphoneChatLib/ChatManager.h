//
//  ChatManager.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/15/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"

@interface ChatManager : NSObject

+(ChatManager*) sharedInstance;

@property (retain, nonatomic) NSString* serverHost;

@property (nonatomic) UInt16 serverPort;

@property (retain, nonatomic) NSString* chatDBPath;

@property (retain, nonatomic) id <ChatUser> me;

- (void) sendMessage:(NSString*)message toUser:(id <ChatUser>)chatUser withComplete:(void (^)(BOOL bSuccess))block;

- (void) login;

- (void) logout;

@end
