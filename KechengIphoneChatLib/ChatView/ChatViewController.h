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
#import "ChatUser.h"

@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ChatInputViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *chatHeaderView;
@property (retain, nonatomic) IBOutlet UITableView *chatTableView;
@property (retain, nonatomic) IBOutlet ChatInputView* chatInputView;
@property (retain, nonatomic) ChatEmoView* chatEmoView;
@property (retain, nonatomic) UIImage* friendHeadImage;
@property (retain, nonatomic) UIImage* myHeadImage;
@property (retain, nonatomic) id<ChatUser> me;
@property (retain, nonatomic) id<ChatUser> myFriend;

@end
