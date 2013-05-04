//
//  ChatInputView.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatInputView.h"

static const CGFloat MESSAGE_FONT_SIZE = 17.0f;
static const CGFloat CONTENT_MAX_HEIGHT = 84.0f;
static const CGFloat SELF_MAX_HEIGHT = 104.0f;
static const CGFloat SELF_MIN_HEIGHT = 44.0f;
static const int TEXT_MAX_LENGTH = 1000;
static const int TEXT_VIEW_MIN_HEIGHT = 37;
static const int TEXT_VIEW_MAX_HEIGHT = 100;

@interface ChatInputView()
{
    CGFloat _previousContentHeight;
    CGFloat _originHeight;
    CGFloat _textViewHeightChanged;
}

@end

@implementation ChatInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)emoButtonClick:(id)sender
{
    [self.delegate onEmoButtonClick];
}

- (IBAction)sendButtonClick:(id)sender
{
    [self.delegate onInputViewSendMessage:self.inputView.text];
    self.inputView.text = @"";
    [self textViewDidChange:self.inputView];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self syncEmoButtonIcon];
    self.textViewBgImageView.image = [[UIImage imageNamed:@"chat_inputbox"] stretchableImageWithLeftCapWidth:13 topCapHeight:13];
    self.inputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.inputView.clearsContextBeforeDrawing = NO;
    self.inputView.font = [UIFont systemFontOfSize:17.0f];
    self.inputView.returnKeyType = UIReturnKeySend;
    self.inputView.clipsToBounds = YES;
    self.inputView.scrollEnabled = NO;
    self.inputView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.inputView.delegate = self;
    self.bgImageView.image = [[UIImage imageNamed:@"chat_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [self sendSubviewToBack:self.bgImageView];
    _originHeight = CGRectGetHeight(self.frame);

}

- (void)syncEmoButtonIcon
{
    if ([self.delegate chatInputMode] == CHAT_INPUT_MODE_EMO) {
        [self.emoButton setBackgroundImage:[UIImage imageNamed:@"keyboard_button"] forState:UIControlStateNormal];
        [self.emoButton setBackgroundImage:[UIImage imageNamed:@"keyboard_button_pressed"] forState:UIControlStateHighlighted];
    } else if ([self.delegate chatInputMode] == CHAT_INPUT_MODE_TEXT || [self.delegate chatInputMode] == CHAT_INPUT_MODE_NONE) {
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
    [_sendButton release];
    [super dealloc];
}

#pragma mark ChatEmoView delegate
- (void) onInputEmoji:(NSString *)emoji
{
    NSString *temp = [self.inputView.text stringByAppendingFormat:@"%@",emoji];
    [self.inputView setText:temp];
    [self textViewDidChange:self.inputView];
}

- (void) onDeleteEmoji
{
    [self.inputView deleteBackward];
    [self textViewDidChange:self.inputView];
}

#pragma mark TextView delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] <= TEXT_MAX_LENGTH) {
        CGFloat contentHeight = self.inputView.contentSize.height;
        if (contentHeight <= TEXT_VIEW_MIN_HEIGHT) {
            _textViewHeightChanged = 0;
        } else if (contentHeight > TEXT_VIEW_MIN_HEIGHT && contentHeight < TEXT_VIEW_MAX_HEIGHT) {
            _textViewHeightChanged = contentHeight - TEXT_VIEW_MIN_HEIGHT;
        } else {
            _textViewHeightChanged = TEXT_VIEW_MAX_HEIGHT - TEXT_VIEW_MIN_HEIGHT;
        }
        [self configureView];
    }
}

- (void)configureView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, SCREEN_HEIGHT - CGRectGetHeight(self.keyboardOrEmoRect) - _originHeight - _textViewHeightChanged, CGRectGetWidth(self.frame), _originHeight + _textViewHeightChanged);
        self.inputView.frame = CGRectMake(self.inputView.frame.origin.x, self.inputView.frame.origin.y, self.inputView.frame.size.width, 27 + _textViewHeightChanged);
        self.textViewBgImageView.frame = CGRectMake(self.textViewBgImageView.frame.origin.x, self.textViewBgImageView.frame.origin.y, CGRectGetWidth(self.textViewBgImageView.frame), 33 + _textViewHeightChanged);
        CGFloat contentHeight = self.inputView.contentSize.height;
        [self.inputView scrollRectToVisible:CGRectMake(0, contentHeight - CGRectGetHeight(self.inputView.frame) - 4, CGRectGetWidth(self.inputView.frame), CGRectGetHeight(self.inputView.frame)) animated:YES];
        self.emoButton.frame = CGRectMake(self.emoButton.frame.origin.x, CGRectGetHeight(self.frame) - CGRectGetHeight(self.emoButton.frame) - 6, CGRectGetWidth(self.emoButton.frame), CGRectGetHeight(self.emoButton.frame));
        self.sendButton.frame = CGRectMake(self.sendButton.frame.origin.x, CGRectGetHeight(self.frame) - CGRectGetHeight(self.sendButton.frame) - 6, CGRectGetWidth(self.sendButton.frame), CGRectGetHeight(self.sendButton.frame));
        [self.delegate onInputViewChangeFrame:self.frame];
    }];
    
}

- (void) clearTextView
{
    self.inputView.text = @"";
    [self textViewDidChange:self.inputView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendButtonClick:nil];
        return NO;
    }
    
    return YES;
}
@end
