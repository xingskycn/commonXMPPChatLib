//
//  ChatInputView.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatInputView.h"

@implementation ChatInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)emoButtonClick:(id)sender {
}

- (IBAction)sendButtonClick:(id)sender {
}

- (void)syncEmoButtonIcon
{
    if (self.inputMode == CHAT_INPUT_MODE_TEXT) {
        [self.emoButton setBackgroundImage:[UIImage imageNamed:@"keyboard_button"] forState:UIControlStateNormal];
        [self.emoButton setBackgroundImage:[UIImage imageNamed:@"keyboard_button_pressed"] forState:UIControlStateNormal];
    } else if (self.inputMode == CHAT_INPUT_MODE_EMO) {
        [self.emoButton setBackgroundImage:[UIImage imageNamed:@"emoji_button"] forState:UIControlStateNormal];
        [self.emoButton setBackgroundImage:[UIImage imageNamed:@"emoji_button_pressed"] forState:UIControlStateHighlighted];
    }
}

- (void)dealloc
{
    [_bgImageView release];
    [_inputView release];
    [_textViewBgImageView release];
    [_delegate release];
    [super dealloc];
}
@end
