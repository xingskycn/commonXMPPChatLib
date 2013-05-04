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
#import "ChatManager.h"
#import "UIImageView+AFNetworking.h"
#import "Toast+UIView.h"

static const int INPUT_VIEW_INIT_HEIGHT = 44;
static const CGFloat MESSAGE_FONT_SIZE = 16.0f;
static const CGFloat PADDING = 30.f;

static const int EMO_VIEW_WIDTH = 320;
static const int EMO_VIEW_HEIGHT = 216;

@interface ChatViewController ()
{
    NSMutableArray * _chatMessages;
    NSMutableArray * _chatTimeArray;
    CHAT_INPUT_MODE _chatInputMode;
    NSDate * _lastChatTime;
    BOOL _bExecuteKeyboardNotification;
    CGRect _keyboardRect;
    NSTimeInterval _keyboardAnimationDuration;
    UIView * _recognizerView;
    int _keyboardAnimationOption;
}

- (void)scrollTableViewToBottom;

- (void)relayoutForKeyboard:(NSNotification *)notification;

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
    [self.chatInputView setFrame:CGRectMake(0, SCREEN_HEIGHT - INPUT_VIEW_INIT_HEIGHT, 320, INPUT_VIEW_INIT_HEIGHT)];
    self.chatInputView.delegate = self;
    [self.view addSubview:self.chatInputView];
    
    self.chatEmoView = [[ChatEmoView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, 320, 216)];
    self.chatEmoView.delegate = self.chatInputView;
    [self.view addSubview:self.chatEmoView];
    _chatInputMode = CHAT_INPUT_MODE_NONE;
    _bExecuteKeyboardNotification = YES;
    _keyboardAnimationDuration = 0;
    
    [self registerNotification];
}

- (void) handleReconnect:(UITapGestureRecognizer *)recognizer
{
    if (![[ChatManager sharedInstance] checkConnectionAvailable]) {
        [[ChatManager sharedInstance] login];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    _recognizerView = [[[UIView alloc] initWithFrame:CGRectMake(80, 2, 230, 40)] autorelease];
    _recognizerView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:_recognizerView];
    UITapGestureRecognizer * tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleReconnect:)] autorelease];
    [_recognizerView addGestureRecognizer:tapGestureRecognizer];
    [self initTitle];
    [[ChatDBHelper sharedInstance] unreadMessage2ReadMessage:self.myFriend];
    [self initChatMessages];
}

- (void) initTitle
{
    if ([[ChatManager sharedInstance] checkConnectionAvailable]) {
        self.navigationItem.title = [self.myFriend chatUserName];
    } else {
        self.navigationItem.title = @"连接失败.";
    }
}

- (void) makeDisconnectedToast
{
    [self.view makeToast:@"当前无网络连接，请稍后重试。" duration:1.5 position:@"topcenter"];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [_recognizerView removeFromSuperview];
    _chatInputMode = CHAT_INPUT_MODE_NONE;
    [self.chatInputView syncEmoButtonIcon];
    [self.chatInputView clearTextView];
    [self.view endEditing:YES];
    [self configureView];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeDisconnectedToast) name:NO_AVAILABLE_NETWORK object:nil];
}

- (void)handleChatConnectionStateNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:CHAT_DISCONNECTED_NOTIFICATION]) {
        self.navigationItem.title = @"连接失败.";
        //[self makeDisconnectedToast];
    } else if ([notification.name isEqualToString:CHAT_CONNECTING_NOTIFICATION]) {
        self.navigationItem.title = @"正在连接中...";
    } else if ([notification.name isEqualToString:CHAT_CONNECTED_NOTIFICATION]) {
        self.navigationItem.title = [self.myFriend chatUserName];
    }
}

//Main function for add message when receiving and sending
- (void)addAMessage:(ChatMessage*) message
{
    if (message != nil) {
        [self buildTimeArrayWithMessage:message];
        [_chatMessages insertObject:message atIndex:0];
    }
}
//Main function for loading messages
- (void)addMessages:(NSMutableArray*) messages
{
    if ([messages count] > 0) {
        [self buildTimeArrayWithMessages:messages];
        [_chatMessages addObjectsFromArray:messages];
    }
}

- (void)handleChatMessageNotification:(NSNotification*)notification
{
    ChatMessage* newMessage = [notification.userInfo objectForKey:@"chatMessage"];
    if ([newMessage.myFriend chatUserId] == [self.myFriend chatUserId]) {
        [self addAMessage:newMessage];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (self.view.window) {
                [[ChatDBHelper sharedInstance] unreadMessage2ReadMessage:newMessage.myFriend];
            }
        });
        [self.chatTableView reloadData];
        [self scrollTableViewToBottom];
    }
}

- (void)initChatMessages
{
    if (_chatMessages == nil) {
        _chatMessages = [[NSMutableArray alloc] init];
    } else {
        [_chatMessages removeAllObjects];
    }
    
    if (_chatTimeArray == nil) {
        _chatTimeArray = [[NSMutableArray alloc] init];
    } else {
        [_chatTimeArray removeAllObjects];
    }
    NSMutableArray* messages = [[ChatDBHelper sharedInstance] MessagesAboutMyFriend:self.myFriend startIndex:0];
    [self addMessages:messages];
    [self.chatTableView reloadData];
    [self scrollTableViewToBottom];
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
    NSDictionary* options = [notification userInfo];
    NSValue* aValue = [options objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    _keyboardAnimationDuration = [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    _keyboardAnimationOption = [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    if (!_bExecuteKeyboardNotification) {
        return;
    }
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        _chatInputMode = CHAT_INPUT_MODE_TEXT;
        [self configureView];
    }
    if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        _chatInputMode = CHAT_INPUT_MODE_NONE;
        [self configureView];
    }
    [self.chatInputView syncEmoButtonIcon];
}

- (void)scrollTableViewToBottom
{
    if ([_chatMessages count] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_chatMessages count]-1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

//Used for loading messages
- (void)buildTimeArrayWithMessages:(NSMutableArray*)chatMessages
{
    //chat messages的时间顺序是从新到旧
    for (int i = 0; i < [chatMessages count] - 1; i++) {
        ChatMessage* messageA = [chatMessages objectAtIndex:i];
        ChatMessage* messageB = [chatMessages objectAtIndex:i + 1];
        [self addTimeForLaterMessage:messageA withEarlierMessage:messageB add2Last:YES];
    }
    //Add last time
    [_chatTimeArray addObject:[[chatMessages lastObject] date]];
}

//Used for sending and receiveing message
- (void)buildTimeArrayWithMessage:(ChatMessage*)chatMessage
{
    if ([_chatMessages count] > 0) {
        ChatMessage * lastMessage = [_chatMessages objectAtIndex:0];
        [self addTimeForLaterMessage:chatMessage withEarlierMessage:lastMessage add2Last:NO];
    } else {
        [_chatTimeArray addObject:chatMessage.date];
    }
}

- (void)addTimeForLaterMessage:(ChatMessage*)laterMessage withEarlierMessage:(ChatMessage*)earlierMessage add2Last:(BOOL)bAdd2Last
{
    NSTimeInterval theInterval = [laterMessage.date timeIntervalSinceDate:earlierMessage.date];
    if (fabs(theInterval > 5 * 60 * 60)) {
        if (bAdd2Last) {
            [_chatTimeArray addObject:laterMessage.date];
        } else {
            [_chatTimeArray insertObject:laterMessage.date atIndex:0];
        }
    } else {
        if (bAdd2Last) {
            [_chatTimeArray addObject:@"null"];
        } else {
            [_chatTimeArray insertObject:@"null" atIndex:0];
        }
    };
}

#pragma mark Tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_chatMessages count];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //close keyboard
    if (_chatInputMode != CHAT_INPUT_MODE_NONE) {
        _chatInputMode = CHAT_INPUT_MODE_NONE;
        [self.view endEditing:YES];
        //[self relayoutForEmoView];
        [self configureView];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == 0) {
        int startIndex = [_chatMessages count] - 1 > 0 ? [_chatMessages count] : 0;
        NSMutableArray* earlierMessages = [[ChatDBHelper sharedInstance] MessagesAboutMyFriend:self.myFriend startIndex:startIndex];
        if ([earlierMessages count] != 0) {
            [self addMessages:earlierMessages];
            int oldHeight = self.chatTableView.contentSize.height;
            [self.chatTableView reloadData];
            [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height - oldHeight - 20)];
        }
    }
} 

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentitier = @"ChatCell";
    
    int row = [self convertIndexPathRow:indexPath.row];
    ChatMessage* chatMessage = [_chatMessages objectAtIndex:row]; //倒序读取
    ChatTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentitier];
    cell.timeLabel.text = @"";
    
    if (cell == nil) {
        cell = [[[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentitier] autorelease];
    }
    
    CGSize size = [self sizeForMessage:chatMessage.content];
    size.width += PADDING / 2;
    
    cell.messageLabel.text = chatMessage.content;
    if (chatMessage.whoSend == CHAT_SENDER_TYPE_FRIEND) {
        //他人的消息
        [cell.headImageView setImageWithURL:[NSURL URLWithString:[self.myFriend tinyAvatarUrl]] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    } else {
        //自己的消息
        [cell.headImageView setImageWithURL:[NSURL URLWithString:[self.me tinyAvatarUrl]] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    }
    cell.headImageView.tag = chatMessage.whoSend;
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfile:)];
    [cell.headImageView addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    BOOL hasDate = [[_chatTimeArray objectAtIndex:row] isKindOfClass:[NSDate class]];
    if (hasDate) {
        [cell setTime:chatMessage.date];
    }
    
    [cell layoutCell:chatMessage.whoSend messageSize:size];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Calculate Date
    int row = [self convertIndexPathRow:indexPath.row];
    ChatMessage* message = [_chatMessages objectAtIndex:row]; //倒序读取
    BOOL hasDate = [[_chatTimeArray objectAtIndex:row] isKindOfClass:[NSDate class]];
    CGSize size = [self sizeForMessage:message.content];
    size.height += hasDate ? 60 : 30;
    return MAX(50, size.height);
}

-(int)convertIndexPathRow:(int)tableViewIndexRow
{
    //因为消息数组中存储的是时间从新到旧的顺序，显示消息时的顺序是从旧到新
    //_chatTimeArray与_chatMessages是对等的
    return [_chatMessages count] - 1 - tableViewIndexRow;
}

-(CGSize) sizeForMessage:(NSString*)msg
{
    CGSize textSize = {200.0, 10000.0};
    return [msg sizeWithFont:[UIFont  systemFontOfSize:MESSAGE_FONT_SIZE] constrainedToSize:textSize lineBreakMode:NSLineBreakByCharWrapping];
}

#pragma mark ChatInputView delegate
- (void) onInputViewChangeFrame:(CGRect)inputViewFrame
{
    int keyboardOrEmoHeight = 0;
    if (_chatInputMode == CHAT_INPUT_MODE_TEXT) {
        keyboardOrEmoHeight = CGRectGetHeight(_keyboardRect);
    } else if (_chatInputMode == CHAT_INPUT_MODE_EMO) {
        keyboardOrEmoHeight = EMO_VIEW_HEIGHT;
    }
    self.chatTableView.frame = CGRectMake(self.chatTableView.frame.origin.x, self.chatTableView.frame.origin.y, CGRectGetWidth(self.chatTableView.frame), SCREEN_HEIGHT - keyboardOrEmoHeight - CGRectGetHeight(inputViewFrame));
    [self scrollTableViewToBottom];
}

- (void)onInputViewSendMessage:(NSString *)message
{
    NSString* cleanString = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([cleanString length] == 0) {
        return;
    }
    ChatMessage* chatMessage = [[[ChatMessage alloc] init] autorelease];
    chatMessage.myFriend = self.myFriend;
    chatMessage.content = cleanString;
    chatMessage.whoSend = CHAT_SENDER_TYPE_ME;
    chatMessage.contentType = CHAT_CONTENT_TYPE_TEXT;
    chatMessage.isNew = NO;
    chatMessage.date = [NSDate date];
    [self addAMessage:chatMessage];
    [self.chatTableView reloadData];
    [self scrollTableViewToBottom];
    [[ChatManager sharedInstance] sendMessage:chatMessage withComplete:^(BOOL bSuccess) {
        if (bSuccess) {
        } else {
            //Todo:show send failed
            NSLog(@"send failed");
        }
    }];
}

- (void)onEmoButtonClick
{
    switch (_chatInputMode) {
        case CHAT_INPUT_MODE_TEXT: {
            _bExecuteKeyboardNotification = NO;
            [self.view endEditing:YES];
            _chatInputMode = CHAT_INPUT_MODE_EMO;
            break;
        }
        case CHAT_INPUT_MODE_EMO: {
            _bExecuteKeyboardNotification = NO;
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
    _bExecuteKeyboardNotification = YES;
    [self configureView];
    [self.chatInputView syncEmoButtonIcon];
}

- (void)configureView
{
    CGRect changRect;
    switch (_chatInputMode) {
        case CHAT_INPUT_MODE_TEXT:
            changRect = _keyboardRect;
            break;
        case CHAT_INPUT_MODE_EMO:
            changRect = CGRectMake(0, SCREEN_HEIGHT - EMO_VIEW_HEIGHT, EMO_VIEW_WIDTH, EMO_VIEW_HEIGHT);
            break;
        case CHAT_INPUT_MODE_NONE:
            changRect = CGRectZero;
            break;
        default:
            break;
    }
    self.chatInputView.keyboardOrEmoRect = changRect;
    if (_chatInputMode == CHAT_INPUT_MODE_EMO) {
        _keyboardAnimationDuration = 0.25;
    }
    [UIView animateWithDuration:_keyboardAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone animations:^{
        CGRect inputViewRect = self.chatInputView.frame;
        self.chatInputView.frame = CGRectMake(inputViewRect.origin.x, SCREEN_HEIGHT - changRect.size.height - inputViewRect.size.height, inputViewRect.size.width, inputViewRect.size.height);
        if (_chatInputMode == CHAT_INPUT_MODE_EMO) {
            self.chatEmoView.frame = changRect;
        } else {
            self.chatEmoView.frame = CGRectMake(0, SCREEN_HEIGHT, CGRectGetWidth(self.chatEmoView.frame), CGRectGetHeight(self.chatEmoView.frame));
        }
        CGRect tableViewRect = self.chatTableView.frame;
        self.chatTableView.frame = CGRectMake(tableViewRect.origin.x, 0, tableViewRect.size.width, SCREEN_HEIGHT - CGRectGetHeight(changRect) - CGRectGetHeight(self.chatInputView.frame));
        CGFloat contentHeight = self.chatTableView.contentSize.height;
        if (CGRectGetHeight(self.chatTableView.frame) < contentHeight) {
        self.chatTableView.contentOffset = CGPointMake(0, contentHeight - CGRectGetHeight(self.chatTableView.frame));
        }
    } completion:nil];
}

- (void) showUserProfile:(id)sender
{
    //On avatar clicked
//    if (!_personDetailController) {
//        _personDetailController = [[PersonDetailController alloc]initWithNibName:@"PersonDetailController" bundle:nil];
//    }
//    int tag = ((UITapGestureRecognizer*)sender).view.tag;
//    if(tag == CHAT_SENDER_TYPE_FRIEND) {
//        _personDetailController.user = (User*)self.myFriend;
//    } else {
//        _personDetailController.user = (User*)self.me;
//    }
//    [self.navigationController pushViewController:_personDetailController animated:YES];
}

- (CHAT_INPUT_MODE)chatInputMode
{
    return _chatInputMode;
}

@end
