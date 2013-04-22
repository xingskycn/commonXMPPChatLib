//
//  TestUser.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/19/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

@synthesize userName;
@synthesize password;

- (NSString*)xmppUserName
{
    return [NSString stringWithFormat:@"%@@%@", self.userName, @"localhost"];
}

- (NSString*)xmppPassword
{
    return self.userName;
}

- (id<ChatUser>)buildChatUserFromXmppUserName:(NSString *)xmppUserName
{
    NSArray* nameComponents = [xmppUserName componentsSeparatedByString:@"@"];
    NSString* newUserName = [nameComponents objectAtIndex:0];
    TestUser* newUser = [[[TestUser alloc] init] autorelease];
    newUser.userName = newUserName;
    newUser.password = newUserName;
    newUser.user_id = 2;
    return newUser;
}

- (int) chatUserId
{
    return self.user_id;
}

@end
