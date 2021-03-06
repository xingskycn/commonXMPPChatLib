//
//  ChatInputViewDelegate.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].applicationFrame) - 44

typedef enum {
    CHAT_INPUT_MODE_NONE,
    CHAT_INPUT_MODE_TEXT,
    CHAT_INPUT_MODE_EMO,
} CHAT_INPUT_MODE;

typedef enum {
    CHAT_SENDER_TYPE_ME,
    CHAT_SENDER_TYPE_FRIEND
} CHAT_SENDER_TYPE;

typedef enum {
    CHAT_CONTENT_TYPE_TEXT,
    CHAT_CONTENT_TYPE_IMAGE,
    CHAT_CONTENT_TYPE_VOICE
} CHAT_CONTENT_TYPE;

@protocol ChatInputViewDelegate <NSObject>

-(void)onInputViewChangeFrame:(CGRect)inputViewFrame;
-(void)onInputViewSendMessage:(NSString *)message;
-(CHAT_INPUT_MODE)chatInputMode;
-(void)onEmoButtonClick;

@end

@protocol ChatEmoViewDelegate <NSObject>

- (void) onInputEmoji: (NSString *) emoji;
- (void) onDeleteEmoji;

@end

extern NSString * const CHAT_CONNECTED_NOTIFICATION;
extern NSString * const CHAT_CONNECTING_NOTIFICATION;
extern NSString * const CHAT_DISCONNECTED_NOTIFICATION;
extern NSString * const CHAT_SEND_MESSAGE_SUCCESS_NOTIFICATION;
extern NSString * const CHAT_SEND_MESSAGE_FAILURE_NOTIFICATION;
extern NSString * const CHAT_RECEIVE_MESSAGE_NOTIFICATION;
extern NSString * const CHAT_MESSAGE_NOTIFICATION_KEY;
extern NSString * const NO_AVAILABLE_NETWORK;