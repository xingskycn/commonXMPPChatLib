//
//  ChatView.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/15/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatTableView.h"
#import "ChatHeaderView.h"
#import "ChatInputView.h"

@interface ChatView : UIView

@property (retain, nonatomic) IBOutlet ChatTableView *chatTableView;
@property (retain, nonatomic) IBOutlet ChatHeaderView *chatHeaderView;
@property (retain, nonatomic) IBOutlet ChatInputView *chatInputView;

@end
