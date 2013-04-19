//
//  ChatViewController.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/18/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatInputView.h"
#import "ChatEmoView.h"

@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ChatInputViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *chatHeaderView;
@property (retain, nonatomic) IBOutlet UITableView *chatTableView;
@property (retain, nonatomic) IBOutlet ChatInputView* chatInputView;
@property (retain, nonatomic) ChatEmoView* chatEmoView;
@property (retain, nonatomic) UIImage* headImage;  //Todo:zuoyl friend's image

@end
