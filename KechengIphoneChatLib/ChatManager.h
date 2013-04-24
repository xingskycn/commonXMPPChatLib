//
//  ChatManager.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/15/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"
#import "XMPP.h"
#import "ChatDBHelper.h"

@interface ChatManager : NSObject <XMPPStreamDelegate>

+(ChatManager*) sharedInstance;

@property (retain, nonatomic) NSString* serverHost;

@property (nonatomic) UInt16 serverPort;

@property (retain, nonatomic) NSString* chatDBPath;

@property (retain, nonatomic) id <ChatUser> me;

- (void) sendMessage:(ChatMessage*)message withComplete:(void (^)(BOOL bSuccess))block;

- (void) login;

- (void) logout;

- (BOOL) checkConnectionAvailable;

@end
