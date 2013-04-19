//
//  ChatManager.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/15/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatManager.h"
#import "XMPP.h"

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
}

- (BOOL) connectToServer;

- (void) checkAuthentication;

- (void) wrongState;

- (void) friendPresence:(NSString*) friendUserName presenceType:(NSString*)presenceType;

- (void) mePresence:(NSString*)presenceType;

- (BOOL) checkConnectionAvailable;

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
                block(YES);
            } else {
                //Maybe retry
                block(NO);
            }
        });
    }
}

- (BOOL) connectToServer
{
    [[NSNotificationCenter defaultCenter] postNotificationName: CHAT_CONNECTING_NOTIFICATION object:nil];
    if ([self checkConnectionAvailable]) {
        [_xmppStream disconnect];
        _connectionState = connectionStateOffline;
    }
    
    if (_connectionState == connectionStateUnkown || _connectionState == connectionStateOffline || _connectionState == connectionStateLoginFailure) {
        _connectionState = connectionStateConnectingServer;
        [_xmppStream setMyJID:[XMPPJID jidWithString:[self.me xmppUserName]]];
        [_xmppStream setHostName:self.serverHost];
        [_xmppStream setHostPort:self.serverPort];
        
        NSError * error = nil;
        if (![_xmppStream connect:&error]) {
            _connectionState = connectionStateLoginFailure;
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
    [self connectToServer];
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
    //May be not right
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
    [_xmppStream sendElement:xmlMessage];
    return xmlMessage;
}

- (ChatMessage*) xmppMessage2ChatMessage:(DDXMLElement *)xmppMessage
{
    NSString * from = [[xmppMessage attributeForName:@"from"] stringValue];
    if (![from isEqualToString:[self.me xmppUserName]]) {
        ChatMessage* chatMessage = [[ChatMessage alloc] init];
        chatMessage.content = [[xmppMessage elementForName:@"body"] stringValue];
        chatMessage.contentType = CHAT_CONTENT_TYPE_TEXT;
        chatMessage.date = [NSDate date];
        chatMessage.myFriend = [self.me buildChatUserFromXmppUserName:from];
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
}

- (void) wrongState
{
    [_xmppStream disconnect];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_DISCONNECTED_NOTIFICATION object:nil];
}

#pragma mark -- XMPP delegate
- (void) xmppStreamDidConnect:(XMPPStream *)sender
{
    if (_connectionState == connectionStateConnecetedServer) {
        _connectionState = connectionStateConnecetedServer;
        [self checkAuthentication];
    } else {
        [self wrongState];
    }
}

- (void) xmppStreamDidAuthenticate:(XMPPStream *)sender
{
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
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_RECEIVE_MESSAGE_NOTIFICATION object:chatMessage];
}

@end
