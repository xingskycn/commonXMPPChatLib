//
//  ChatManager.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/15/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatManager.h"
#import "XMPP.h"
#import "ChatDBHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Reachability.h"

typedef enum {
    connectionStateUnkown,
    connectionStateOffline = 1,
    connectionStateConnectingServer,
    connectionStateConnecetedServer,
    connectionStateAuthenticating,
    connectionStateConfiguring,
    connectionStateLoginSuccess,
    connectionStateLoginFailure
} connectionState;

static ChatManager * chatManager = nil;

static NSString * ON_LINE = @"available";
static NSString * OFF_LINE = @"unavailable";
static int SEND_MESSAGE_TIMEOUT = 5;
static int CHECK_CONNECTION_TIMEOUT = 60;

@interface ChatManager()<XMPPStreamDelegate>
{
    XMPPStream * _xmppStream;
    connectionState _connectionState;
    dispatch_source_t _connectionCheckTimer;
    BOOL _bRunCheckTimer;
    dispatch_source_t _connectionTimer;
    BOOL _bConnecting;
}

- (BOOL) connectToServer;

- (void) checkAuthentication;

- (void) wrongState;

- (void) friendPresence:(NSString*) friendUserName presenceType:(NSString*)presenceType;

- (void) mePresence:(NSString*)presenceType;

- (NSXMLElement*) chatMessage2XmppMessage:(ChatMessage*)message;

- (ChatMessage*) xmppMessage2ChatMessage:(NSXMLElement*)xmppMessage;

- (void) createConnectionCheckTimer;

@end

@implementation ChatManager

+ (ChatManager*) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatManager = [[ChatManager alloc] init];
        if (chatManager) {
            
        }
    });
    return chatManager;
}

- (id) init
{
    if (self = [super init]) {
        _xmppStream = [[XMPPStream alloc] init];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self createConnectionCheckTimer];
    }
    return self;
}

- (void) sendMessage:(ChatMessage *)message withComplete:(void (^)(BOOL))block
{
    if ([self checkConnectionAvailable]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            XMPPElementReceipt *receipt;
            [_xmppStream sendElement:[self chatMessage2XmppMessage:message] andGetReceipt:&receipt];
            if ([receipt wait:SEND_MESSAGE_TIMEOUT]) {
                //Wait until the element has been sent
                message.isSucceed = YES;
                [[ChatDBHelper sharedInstance] insertChatMessage:message];
                NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
                [userInfo setObject:message forKey:CHAT_MESSAGE_NOTIFICATION_KEY];
                [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_SEND_MESSAGE_SUCCESS_NOTIFICATION object:self userInfo:userInfo];
                block(YES);
            } else {
                //Maybe retry
                message.isSucceed = NO;
                [[ChatDBHelper sharedInstance] insertChatMessage:message];
                [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_SEND_MESSAGE_FAILURE_NOTIFICATION object:nil];
                block(NO);
            }
        });
    }
}

- (BOOL) connectToServer
{
    [[NSNotificationCenter defaultCenter] postNotificationName: CHAT_CONNECTING_NOTIFICATION object:nil];
    [_xmppStream disconnect];
    _connectionState = connectionStateOffline;
    
    if (_connectionState == connectionStateUnkown || _connectionState == connectionStateOffline || _connectionState == connectionStateLoginFailure) {
        _connectionState = connectionStateConnectingServer;
        [_xmppStream setMyJID:[XMPPJID jidWithString:[self.me xmppUserName]]];
        [_xmppStream setHostName:self.serverHost];
        [_xmppStream setHostPort:self.serverPort];
        
        NSError * error = nil;
        if (![_xmppStream connect:&error]) {
            _connectionState = connectionStateLoginFailure;
            [[NSNotificationCenter defaultCenter] postNotificationName: CHAT_DISCONNECTED_NOTIFICATION object:nil];
            return NO;
        } else {
            return YES;
        }
    } else {
        [self wrongState];
    }

    return NO;
}

- (void) login
{
    //Establish connection to server
    [self createConnectionTimer];
}

- (void) logout
{
    //Break connection to server
    if ([self checkConnectionAvailable]) {
        XMPPPresence * presence = [XMPPPresence presenceWithType:OFF_LINE];
        [_xmppStream sendElement:presence];
    }
    [_xmppStream disconnect];
}

- (void) checkAuthentication
{
    if (_connectionState == connectionStateConnecetedServer) {
        NSError * error = nil;
        [_xmppStream authenticateWithPassword:[self.me xmppPassword] error:&error];
        _connectionState = connectionStateAuthenticating;
    } else {
        [self wrongState];
    }
}

- (void) friendPresence:(NSString *)friendUserName presenceType:(NSString *)presenceType
{
    if ([presenceType isEqualToString:ON_LINE]) {
        //Post online notification
        
    } else {
        //Post offline notification
    }
}

- (void) mePresence:(NSString *)presenceType
{
    if ([presenceType isEqualToString:ON_LINE]) {
        _connectionState = connectionStateLoginSuccess;
    } else {
        _connectionState = connectionStateLoginFailure;
        //Disconnect or something
        [self wrongState];
    }
}

- (BOOL) checkConnectionAvailable
{
    return [_xmppStream isConnected] && [_xmppStream isAuthenticated];
}

- (NSXMLElement*) chatMessage2XmppMessage:(ChatMessage *)message
{
    NSXMLElement * body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message.content];
    NSXMLElement * xmlMessage = [NSXMLElement elementWithName:@"message"];
    [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [xmlMessage addAttributeWithName:@"to" stringValue:[message.myFriend xmppUserName]];
    [xmlMessage addChild:body];
    return xmlMessage;
}

- (ChatMessage*) xmppMessage2ChatMessage:(DDXMLElement *)xmppMessage
{
    NSString * type = [[xmppMessage attributeForName:@"type"] stringValue];
    if ([type isEqualToString:@"error"]) {
        return nil;
    }
    NSString * from = [[xmppMessage attributeForName:@"from"] stringValue];
    if (![from isEqualToString:[self.me xmppUserName]] && [[xmppMessage elementForName:@"body"] stringValue] != nil) {
        NSDate *date = nil;
        NSXMLElement * delay = [xmppMessage elementForName:@"delay"];
        if (delay) {
            date = [self delayTimeToNSDate:[delay attributeForName:@"stamp"].stringValue];
        } else {
            date = [NSDate date];
        }
        ChatMessage* chatMessage = [[ChatMessage alloc] init];
        chatMessage.content = [[xmppMessage elementForName:@"body"] stringValue];
        chatMessage.contentType = CHAT_CONTENT_TYPE_TEXT;
        chatMessage.date = date;
        chatMessage.myFriend = [self.me buildChatUserFromXmppUserName:from];
        chatMessage.whoSend = CHAT_SENDER_TYPE_FRIEND;
        chatMessage.isNew = YES;
        chatMessage.isSucceed = YES;
        return chatMessage;
    }
    
    return nil;
}

- (void) createConnectionCheckTimer
{
    _connectionCheckTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_connectionCheckTimer, dispatch_time(DISPATCH_TIME_NOW, CHECK_CONNECTION_TIMEOUT * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(_connectionCheckTimer, ^{
        if (![self checkConnectionAvailable]) {
            //reconnect
            [self connectToServer];
        }
        if (!_bRunCheckTimer) {
            dispatch_source_cancel(_connectionCheckTimer);
        }
    });
    dispatch_resume(_connectionCheckTimer);
}

- (void) createConnectionTimer
{
    _connectionTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_connectionTimer, dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(_connectionTimer, ^{
        Reachability * reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
        reach.reachableBlock = ^(Reachability*reach) {
            if (![self checkConnectionAvailable]) {
                [self connectToServer];
            } else {
                dispatch_source_cancel(_connectionTimer);
            }
        };
        reach.unreachableBlock = ^(Reachability*reach) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NO_AVAILABLE_NETWORK object:nil];
            dispatch_source_cancel(_connectionTimer);
        };
        [reach startNotifier];
    });
    dispatch_resume(_connectionTimer);
}

- (void) wrongState
{
    [_xmppStream disconnect];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_DISCONNECTED_NOTIFICATION object:nil];
}

#pragma mark -- XMPP delegate
- (void) xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidConnect");
    if (_connectionState == connectionStateConnectingServer) {
        _connectionState = connectionStateConnecetedServer;
        [self checkAuthentication];
    } else {
        [self wrongState];
    }
}

- (void) xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidAuthenticate");
    //when authentication is successful,we should notify the server that we are online
    if (_connectionState == connectionStateAuthenticating) {
        XMPPPresence * presence = [XMPPPresence presence];
        [_xmppStream sendElement:presence];
        _connectionState = connectionStateConfiguring;
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_CONNECTED_NOTIFICATION object:nil];
    } else {
        [self wrongState];
    }
}

- (void) xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"xmppStreamDidReceivePresence");
    //when we receive a presence notification,we should do something base on presence propeties;
    NSString * presenceType = [presence type] ;
    NSString * myXmppName = [sender.myJID user];
    NSString * friendXmppName = [[presence from] user];
    if (![friendXmppName isEqualToString:myXmppName]) {
        [self friendPresence:friendXmppName presenceType:presenceType];
    } else {
        //Self online
        if (_connectionState == connectionStateConfiguring || _connectionState == connectionStateLoginSuccess) {
            [self mePresence:presenceType];
        }
    }
}

- (void) xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    ChatMessage* chatMessage = [self xmppMessage2ChatMessage:message];
    if (chatMessage != nil) {
        NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
        [userInfo setObject:chatMessage forKey:@"chatMessage"];
        [[ChatDBHelper sharedInstance] insertChatMessage:chatMessage];
        //Post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_RECEIVE_MESSAGE_NOTIFICATION object:self userInfo:userInfo];
        if([[[NSUserDefaults standardUserDefaults] objectForKey:self.CHAT_SHOULD_VIBRATE_KEY] boolValue]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

#pragma mark-- private method
-(NSDate *)delayTimeToNSDate:(NSString *)time_str{
    time_str = [time_str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    time_str = [time_str stringByReplacingOccurrencesOfString:@"Z" withString:@" "];
    NSDateFormatter * dateFormatrer = [[[NSDateFormatter alloc]init]autorelease];
    [dateFormatrer setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatrer setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate * date_0zone = [dateFormatrer dateFromString:time_str];
    NSDate * date_8zone = [NSDate dateWithTimeInterval:8*60*60 sinceDate:date_0zone];
    return date_8zone;
}

@end
