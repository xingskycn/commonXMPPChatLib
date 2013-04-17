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
-(void)inputViewSendMessage:(NSString *)message;
-(void)inputViewSetInputMode:(CHAT_INPUT_MODE) inputMode;

@end

@protocol ChatEmoViewDelegate <NSObject>

- (void) handleInput: (NSString *) emoji;
- (void) handleDelete;

@end
