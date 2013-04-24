//
//  ChatExpressionView.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatEmoView.h"
#import "ChatEmojis.h"

@implementation ChatEmoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    ChatEmojis * emoManager = [[ChatEmojis alloc]init];
    NSArray* emojis = [[emoManager allEmojis]retain];
    [emoManager release];
    
    UIFont * emojiFont = [UIFont fontWithName:@"Apple Color Emoji" size:27];
    int buttonSize = 45;
    int pageControlHeight = 20;
    int buttonNumHor = (int)self.frame.size.width / buttonSize;
    int buttonNumVer = (int)(self.frame.size.height - pageControlHeight) / buttonSize;
    float spaceHor = (self.frame.size.width - buttonNumHor * buttonSize) / (buttonNumHor + 1);
    float spaceVer = (self.frame.size.height - pageControlHeight - buttonNumVer*buttonSize) / (buttonNumVer + 1);
    int pageSum = ceilf((float)emojis.count / (buttonNumVer * buttonNumHor));
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _scrollView.clipsToBounds = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delaysContentTouches = YES;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.delegate = self;
    [_scrollView setContentSize:CGSizeMake(self.frame.size.width * pageSum,  self.frame.size.height - pageControlHeight)];
    [self addSubview:_scrollView];
    [_scrollView release];
    
    for(int i = 0; i < pageSum; i++) {
        UIImageView * bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"emoji_bg"]];
        bg.frame = CGRectMake(i * 320, 0, 320, 216);
        [_scrollView addSubview:bg];
        [bg release];
    }
    
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - pageControlHeight, self.frame.size.width, pageControlHeight)];
    _pageControl.numberOfPages = pageSum;
    
    [self addSubview:_pageControl];
    [_pageControl release];
    
    
    int page = 0;
    int col = 0;
    int row = 0;
    for(int i = 0; i< [emojis count]; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //special case for back button
        if(row == buttonNumVer - 1 && col == buttonNumHor - 1) {
            //save space for back button
        } else {
            [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:[emojis objectAtIndex:i] forState:UIControlStateNormal];
            button.titleLabel.font = emojiFont;
            button.frame = CGRectMake(page * self.frame.size.width + col * (buttonSize + spaceHor) + spaceHor, row * (buttonSize + spaceVer) + spaceVer, buttonSize, buttonSize);
        }
        button.backgroundColor = [UIColor clearColor];
        
        [_scrollView addSubview:button];
        
        col++;
        if (col == buttonNumHor){
            row++;
            col = 0;
            if (row == buttonNumVer){
                page++;
                row = 0;
            }
        }
    }
    
    //add back buttons
    for(int i = 0; i <= page; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(backButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"emoji_delete_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"emoji_delete_button_pressed"] forState:UIControlStateSelected];
        button.frame = CGRectMake(i * 320 + 274, 142, 45, 47);
        NSLog(@"%@", NSStringFromCGRect(button.frame));
        button.backgroundColor = [UIColor clearColor];
        [_scrollView addSubview:button];
    }
    [emojis release];
}

-(void)buttonPress:(id)sender
{
    UIButton* button = sender;
    [self.delegate onInputEmoji:button.titleLabel.text];
}

-(void)backButtonPress:(id)sender
{
    [self.delegate onDeleteEmoji];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv
{
    if ([sv isKindOfClass:[UITableView class]]) {
        return;
    }
    
    int index = fabs(sv.contentOffset.x) / sv.frame.size.width;
    _pageControl.currentPage = index;
}

@end
