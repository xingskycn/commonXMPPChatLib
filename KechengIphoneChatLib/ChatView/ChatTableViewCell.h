//
//  ChatTableViewCell.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatDefinitions.h"

@interface ChatTableViewCell : UITableViewCell

@property (nonatomic, assign) UILabel* timeLabel;
@property (nonatomic, assign) UILabel* messageLabel;
@property (nonatomic, assign) UIImageView* bgView;
@property (nonatomic, assign) UIImageView* headImageView;
@property (nonatomic, assign) UIImageView* headBgView;

-(void)layoutCell:(CHAT_SENDER_TYPE)sender messageSize:(CGSize)size;

-(void)setTime:(NSDate *)messageDate;

@end
