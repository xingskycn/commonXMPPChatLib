//
//  ChatInputViewDelegate.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CHAT_INPUT_MODE_TEXT,
    CHAT_INPUT_MODE_EMO,
} CHAT_INPUT_MODE;

@protocol ChatInputViewDelegate <NSObject>

-(void)inputViewRectChangeFrame:(CGRect)nowRect;
-(void)inputViewSendMessage:(NSString *)message;
-(void)inputViewSetInputMode:(CHAT_INPUT_MODE) inputMode;

@end

@protocol ChatEmoViewDelegate <NSObject>

- (void) handleInput: (NSString *) emoji;
- (void) handleDelete;

@end
