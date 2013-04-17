//
//  ChatEmojis.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatEmojis.h"

@implementation ChatEmojis

-(id)init {
    self = [super init];
    if(self) {
        _allEmojis = [[NSArray arrayWithObjects:
                       @"😄", @"😊", @"😃", @"😉", @"😍",@"😘", @"😚", @"😳", @"😌", @"😁", @"😜", @"😡", @"😏", @"😓", @"😔", @"😖", @"😥", @"😰", @"😨", @"😣", @"😢", @"😭", @"😂", @"😲", @"😱", @"😠", @"👻", @"💜", @"✌", @"👙", @"💤", @"💏", @"❤", @"💗", @"💘", @"💔", @"🎅", @"🎄", @"🎂", @"🍰", @"👽", @"💋", @"💎", @"🍀", @"🌙", @"⛄", @"📢", @"🔒", @"🔫", @"💰", @"🎶", @"🏈", @"🏀", @"⚽", @"⚾", @"🎾", @"🎱", @"🍔", @"🍟", @"🍜", @"🍎", @"✈", @"🚌", @"🚙", @"🚲", @"🌟", @"💤", @"🎵", @"🔥", @"💩", @"👍", @"👎", @"👌", @"🎎", @"🎒", @"🎓", @"🎆", @"🎃", @"🎁", @"🔔", @"📷", @"💻", @"🈶", @"🈚", @"🚾", @"㊙", nil] retain];
    }
    return self;
}

-(NSArray*) allEmojis {
    return _allEmojis;
}

-(void)dealloc {
    [_allEmojis release];
    [super dealloc];
}

@end
