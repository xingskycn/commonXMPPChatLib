//
//  ChatViewController.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/18/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatMessage.h"
#import "ChatTableViewCell.h"

static const int INPUT_VIEW_INIT_HEIGHT = 45;
static const int HEADER_VIEW_HEIGHT = 45;
static const CGFloat MESSAGE_FONT_SIZE = 17.0f;
static const CGFloat PADDING = 30.f;

@interface ChatViewController ()
{
    NSMutableArray * _chatMessages;
    CHAT_INPUT_MODE _chatInputMode;
    NSString* _userAvatarUrl;
}

- (void)scrollTableViewToBottom;

- (void)relayoutForKeyboard:(NSNotification *)notification;

- (void)relayoutForEmoView;

@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"global_bg_pattern.png"]];
    
    NSArray* xib = [[NSBundle mainBundle] loadNibNamed:@"ChatInputView" owner:self options:nil];
    self.chatInputView = [xib objectAtIndex:0];
    [self.chatInputView setFrame:CGRectMake(0, 372, self.view.frame.size.height - INPUT_VIEW_INIT_HEIGHT, INPUT_VIEW_INIT_HEIGHT)];
    self.chatInputView.delegate = self;
    [self.view addSubview:self.chatInputView];
    
    self.chatEmoView = [[ChatEmoView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, 320, 216)];
    self.chatEmoView.delegate = self.chatInputView;
    [self.view addSubview:self.chatEmoView];
    
    _chatInputMode = CHAT_INPUT_MODE_NONE;
    
    self.navigationItem.title = @"Origin title";
}

- (void)registerNotification
{
    //Add keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutForKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutForKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    #ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutForKeyboard:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    #endif
    
    //Add chat Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatConnectionStateNotification:) name:CHAT_DISCONNECTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatConnectionStateNotification:) name:CHAT_CONNECTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatConnectionStateNotification:) name:CHAT_CONNECTING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatMessageNotification:) name:CHAT_RECEIVE_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatMessageNotification:) name:CHAT_SEND_MESSAGE_SUCCESS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatMessageNotification:) name:CHAT_SEND_MESSAGE_FAILURE_NOTIFICATION object:nil];
}

- (void)handleChatConnectionStateNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:CHAT_DISCONNECTED_NOTIFICATION]) {
        self.navigationItem.title = @"Disconnected";
    } else if ([notification.name isEqualToString:CHAT_CONNECTING_NOTIFICATION]) {
        self.navigationItem.title = @"Connecting";
    } else if ([notification.name isEqualToString:CHAT_CONNECTED_NOTIFICATION]) {
        self.navigationItem.title = @"Connected";
    }
}

- (void)handleChatMessageNotification:(NSNotification*)notification
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setChatHeaderView:nil];
    [self setChatTableView:nil];
    [super viewDidUnload];
}

- (void)relayoutForKeyboard:(NSNotification*) notification
{
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        _chatInputMode = CHAT_INPUT_MODE_TEXT;
    }
    if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        _chatInputMode = CHAT_INPUT_MODE_NONE;
    }
    NSDictionary* options = [notification userInfo];
    NSValue* aValue = [options objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [options objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:animationDuration];
    
    CGRect keyboardFrameEndRelative = [self.view convertRect:keyboardRect fromView:nil];
    
    //Todo:zuoyl int bottom = keyboardFrameEndRelative.origin.y>least ? least : keyboardFrameEndRelative.origin.y;
    int bottom = keyboardFrameEndRelative.origin.y;
    CGRect tableViewFrame = self.chatTableView.frame;
    tableViewFrame.size.height = bottom - self.chatInputView.frame.size.height - 6;
    self.chatInputView.frame = tableViewFrame;
    
    CGRect bottomViewFrame = self.chatInputView.frame;
    bottomViewFrame.origin.y = bottom - self.chatInputView.frame.size.height;
    self.chatInputView.frame = bottomViewFrame;
    [self scrollTableViewToBottom];
    //[UIView commitAnimations];
    [self.chatInputView syncEmoButtonIcon];
}

- (void)relayoutForEmoView
{
    
    CGFloat screenHeight = SCREEN_HEIGHT;
    CGRect bottomViewFrame = self.chatInputView.frame;
    CGRect msgTableViewFrame = self.chatTableView.frame;
    if (_chatInputMode == CHAT_INPUT_MODE_EMO) {
        bottomViewFrame.origin.y = self.view.frame.size.height - self.chatEmoView.frame.size.height - self.chatInputView.frame.size.height;
        msgTableViewFrame.size.height = self.view.frame.size.height - self.chatEmoView.frame.size.height - self.chatInputView.frame.size.height - 6;
        self.chatEmoView.frame = CGRectMake(0, screenHeight - 216, 320, 216);
    } else if (_chatInputMode == CHAT_INPUT_MODE_NONE) {
        bottomViewFrame.origin.y = self.view.frame.size.height - self.chatInputView.frame.size.height;
        msgTableViewFrame.size.height = self.view.frame.size.height - self.chatInputView.frame.size.height - 6;
        self.chatEmoView.frame = CGRectMake(0, screenHeight, 320, 216);
    }
    self.chatInputView.frame = bottomViewFrame;
    [UIView beginAnimations:@"chatEmoView" context:NULL];
    [UIView setAnimationDuration:0.25f];
    
    self.chatTableView.frame = msgTableViewFrame;
    [self scrollTableViewToBottom];
    [UIView commitAnimations];
}

- (void)scrollTableViewToBottom
{
    if ([_chatMessages count] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_chatMessages count]-1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark Tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //close keyboard
    _chatInputMode = CHAT_INPUT_MODE_NONE;
    [self.view endEditing:YES];
    [self relayoutForEmoView];
    //Todo:close emo board
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentitier = @"ChatCell";
    
    ChatMessage* chatMessage = [_chatMessages objectAtIndex:indexPath.row];
    ChatTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentitier];
    if (cell == nil) {
        cell = [[[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentitier] autorelease];
    }
    
    CGSize size = [self sizeForMessage:chatMessage.content];
    size.width += PADDING / 2;
    
    cell.messageLabel.text = chatMessage.content;
    if (chatMessage.whoSend == CHAT_SENDER_TYPE_FRIEND) {
        //他人的消息
        cell.headImageView.image = self.headImage;
        //Todo:zuoyl cell image and navigation.
        //UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfile:)];
        //[cell.headImageView addGestureRecognizer:singleFingerTap];
        //[singleFingerTap release];
    } else {
        //自己的消息
        //[cell.headImageView setImageWithURL:[NSURL URLWithString:_userAvatarUrl] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
        cell.headImageView.image = [UIImage imageNamed:@"default_avatar"];
    }
    cell.headImageView.tag = chatMessage.whoSend;
    
    if (indexPath.row == 0) {
        [cell setTime:chatMessage.date];
    } else {
        //Todo:zuoyl  set time
    }
    
    [cell layoutCell:chatMessage.whoSend showTime:NO messageSize:size];
    
    return cell;
}

-(CGSize) sizeForMessage:(NSString*)msg {
    CGSize textSize = {200, 10000.0};
    return [msg sizeWithFont:[UIFont  systemFontOfSize:MESSAGE_FONT_SIZE] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
}

#pragma mark ChatInputView delegate
- (void)onInputViewHeightChanged:(CGFloat)changedHeight
{
    CGRect newFrame = self.chatTableView.frame;
    newFrame.size.height -= changedHeight;
    
    [UIView beginAnimations:@"ChangeTableViewHeight" context:NULL];
    [UIView setAnimationDuration:0.1f];
    self.chatTableView.frame = newFrame;
    [UIView commitAnimations];
    [self scrollTableViewToBottom];
}

- (void)inputViewSendMessage:(NSString *)message
{
    //Todo:zuoyl send message somting
}

- (void)onEmoButtonClick
{
    switch (_chatInputMode) {
        case CHAT_INPUT_MODE_TEXT: {
            [self.view endEditing:YES];
            _chatInputMode = CHAT_INPUT_MODE_EMO;
            break;
        }
        case CHAT_INPUT_MODE_EMO: {
            _chatInputMode = CHAT_INPUT_MODE_TEXT;
            [self.chatInputView.inputView becomeFirstResponder];
            break;
        }
        case CHAT_INPUT_MODE_NONE: {
            _chatInputMode = CHAT_INPUT_MODE_EMO;
            break;
        }
        default:
            break;
    }
    
    [self relayoutForEmoView];
    [self.chatInputView syncEmoButtonIcon];
}

- (CHAT_INPUT_MODE)chatInputMode
{
    return _chatInputMode;
}

@end
