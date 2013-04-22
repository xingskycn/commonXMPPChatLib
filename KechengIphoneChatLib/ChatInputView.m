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

@interface ChatInputView()
{
    CGFloat _previousContentHeight;
}

- (void) setSelfHeight:(CGFloat)newHeight;

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
    self.inputView.delegate = self;
    [self syncEmoButtonIcon];
    self.bgImageView.image = [[UIImage imageNamed:@"chat.png"]
                              stretchableImageWithLeftCapWidth:18 topCapHeight:20];
    [self sendSubviewToBack:self.bgImageView];
    _previousContentHeight = self.inputView.contentSize.height;
    self.inputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
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

- (void)setSelfHeight:(CGFloat)newHeight
{
    CGFloat heightChange = newHeight - self.frame.size.height;
    [self.delegate onInputViewHeightChanged:heightChange];
    CGRect newFrame = self.frame;
    newFrame.origin.y -= heightChange;
    newFrame.size.height = newHeight;
    
    CGRect sendBtnFrame = self.sendButton.frame;
    sendBtnFrame.size.height += heightChange;
    
    CGRect emoBtnFrame = self.emoButton.frame;
    emoBtnFrame.origin.y += heightChange / 2;
    
    [UIView beginAnimations:@"bottomFrameChange" context:NULL];
    [UIView setAnimationDuration:0.1f];
    self.frame = newFrame;
    CGRect imageFrame = self.bgImageView.frame;
    imageFrame.size.height = newHeight;
    self.bgImageView.frame = imageFrame;
    self.sendButton.frame = sendBtnFrame;
    self.emoButton.frame = emoBtnFrame;
    [UIView commitAnimations];
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
    if([textView.text length] <= TEXT_MAX_LENGTH) {
        CGFloat contentHeight = textView.contentSize.height - MESSAGE_FONT_SIZE + 2.0f;
        
        if ([textView hasText]) {
            // Resize textView to contentHeight
            if (contentHeight != _previousContentHeight) {
                // limit chatInputHeight <= 4 lines
                if (contentHeight <= CONTENT_MAX_HEIGHT) {
                    CGFloat chatBarHeight = contentHeight + 18.0f + 4;
                    [self setSelfHeight:chatBarHeight];
                    
                    if (_previousContentHeight > CONTENT_MAX_HEIGHT) {
                        textView.scrollEnabled = NO;
                    }
                } else if (_previousContentHeight <= CONTENT_MAX_HEIGHT) {
                    self.inputView.scrollEnabled = YES;
                    self.inputView.clipsToBounds = YES;
                    CGRect textViewFrame = self.inputView.frame;
                    textViewFrame.size.height = contentHeight - 16;
                    self.inputView.frame = textViewFrame;
                    // shift to bottom
                    textView.contentOffset = CGPointMake(0.0f, contentHeight - 68.0f);
                    
                    if (_previousContentHeight < CONTENT_MAX_HEIGHT) {
                        [self setSelfHeight:SELF_MAX_HEIGHT];
                    }
                }
            }
        } else {
            // textView is empty
            if (_previousContentHeight > 22.0f) {
                [self setSelfHeight:SELF_MIN_HEIGHT];
                if (_previousContentHeight > CONTENT_MAX_HEIGHT) {
                    textView.scrollEnabled = NO;
                }
            }
            textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
        }
        _previousContentHeight = contentHeight;
    } else {
        textView.text = [textView.text substringToIndex:TEXT_MAX_LENGTH];
    }
}
@end
