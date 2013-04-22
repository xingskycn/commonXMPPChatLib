//
//  TestUser.h
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/19/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatUser.h"

@interface TestUser : NSObject <ChatUser>

@property (nonatomic, retain) NSString* userName;
@property (nonatomic, retain) NSString* password;
@property int user_id;

@end
