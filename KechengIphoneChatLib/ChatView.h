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
#import "ChatUser.h"

@interface ChatView : UIView <UITableViewDataSource, UITableViewDelegate>

//@property (retain, nonatomic) IBOutlet UITableView *chatTableView;

//@property (retain, nonatomic) IBOutlet ChatHeaderView *chatHeaderView;

//@property (retain, nonatomic) IBOutlet ChatInputView *chatInputView;

@property (retain, nonatomic) id <ChatUser> me;

@property (retain, nonatomic) id <ChatUser> myFriend;

@end
