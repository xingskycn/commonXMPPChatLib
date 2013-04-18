//
//  ChatInputViewDelegate.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

-(void)inputViewRectChangeFrame:(CGRect)nowRect;
-(void)onInputViewHeightChanged:(CGFloat)changedHeight;
-(void)inputViewSendMessage:(NSString *)message;
-(CHAT_INPUT_MODE)chatInputMode;
-(void)onEmoButtonClick;

@end

@protocol ChatEmoViewDelegate <NSObject>

- (void) handleInput: (NSString *) emoji;
- (void) handleDelete;

@end

#define SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].applicationFrame) - 44
