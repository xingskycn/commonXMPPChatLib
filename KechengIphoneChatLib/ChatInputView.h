//
//  ChatInputView.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatDefinitions.h"

@interface ChatInputView : UIView <UITextViewDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *textViewBgImageView;

@property (retain, nonatomic) IBOutlet UITextView *inputView;

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;

@property (retain, nonatomic) IBOutlet UIButton *emoButton;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;

@property (retain, nonatomic) id <ChatInputViewDelegate> delegate;

- (IBAction)emoButtonClick:(id)sender;

- (IBAction)sendButtonClick:(id)sender;

- (void) syncEmoButtonIcon;

@end
