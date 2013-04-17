//
//  ChatInputView.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatDefinitions.h"

@interface ChatInputView : UIView

@property (retain, nonatomic) IBOutlet UIImageView *textViewBgImageView;

@property (retain, nonatomic) IBOutlet UITextView *inputView;

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *emoButton;

@property (retain, nonatomic) id <ChatInputViewDelegate> delegate;

@property (nonatomic) CHAT_INPUT_MODE inputMode;

- (IBAction)emoButtonClick:(id)sender;

- (IBAction)sendButtonClick:(id)sender;

@end
