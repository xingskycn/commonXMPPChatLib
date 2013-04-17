//
//  ChatTableViewCell.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "CopyLabel.h"

@implementation ChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:11.0];
        _timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeLabel];
        
        
        _bgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_bgView];
        
        _messageLabel = [[CopyLabel alloc] init];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0;
        [self.contentView addSubview:_messageLabel];
        
        _headBgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headBgView.userInteractionEnabled = YES;
        [self.contentView addSubview:_headBgView];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headImageView.userInteractionEnabled = YES;
        _headBgView.image = [UIImage imageNamed:@"avatar_shadow"];
        [_headBgView addSubview:_headImageView];
    }
    return self;
}

- (void)layoutCell:(BOOL)left showTime:(BOOL)showTime messageSize:(CGSize)size
{
    float headBgX;
    float messageLabelX;
    float paddingTop = 5;
    NSString* bgImageName;
    
    if (left) {
        headBgX = 10;
        bgImageName = @"bubble_2";
        messageLabelX = 70;
    } else {
        headBgX = 320 - 42 - 10;
        bgImageName = @"bubble_1";
        messageLabelX = 320 - size.width - 70;
    }
    
    if(showTime) {
        _timeLabel.frame = CGRectMake(0, 5, 320, 15);
        paddingTop += 25;
    } else {
        _timeLabel.frame = CGRectZero;
    }
    
    _headBgView.frame = CGRectMake(headBgX, paddingTop, 42, 42);
    _headImageView.frame = CGRectMake(1, 1, 40, 40);
    _bgView.image = [[UIImage imageNamed:bgImageName] stretchableImageWithLeftCapWidth:24 topCapHeight:30];
    
    _messageLabel.frame = CGRectMake(messageLabelX, paddingTop + 10, size.width, size.height);
    _bgView.frame = CGRectInset(_messageLabel.frame, -10, -5);
}

@end
