//
//  ChatView.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/15/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatView.h"

@interface ChatView()
{
    NSMutableArray * _chatMessages;
    UITableView * _chatTableView;
    ChatInputView * _chatInputView;
}

@end

@implementation ChatView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _chatMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
    NSArray * xib = [[NSBundle mainBundle] loadNibNamed:@"ChatInputView" owner:self options:nil];
    _chatInputView = [xib objectAtIndex:0];
    _chatInputView.frame = CGRectMake(0, 503, 320, 45);
    [self addSubview:_chatInputView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_chatTableView release];
    [super dealloc];
}
@end
