//
//  ChatExpressionView.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatDefinitions.h"

@interface ChatEmoView : UIView <UIScrollViewDelegate>

@property(retain, nonatomic) UIScrollView *scrollView;
@property(retain, nonatomic) UIPageControl *pageControl;

@property(retain, nonatomic) id <ChatEmoViewDelegate> delegate;

@end
