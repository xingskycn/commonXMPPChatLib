//
//  ChatDBHelper.m
//  KechengIphoneChatLib
//
//  Created by zuoyl on 4/16/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "ChatDBHelper.h"
#import <sqlite3.h>

static ChatDBHelper * dbHelper = nil;

static int messagesPerPage = 10;

static NSString* chatTableColumn1 = @"message_id";

static NSString* chatTableColumn2 = @"friend_id";

static NSString* chatTableColumn3 = @"send_type";

static NSString* chatTableColumn4 = @"content";

static NSString* chatTableColumn5 = @"content_type";

static NSString* chatTableColumn6 = @"is_new";

static NSString* chatTableColumn7 = @"message_date";

static NSString* chatMessageTableName = @"chat_messages_table";

@interface ChatDBHelper()
{
    sqlite3* _dbh;
    NSObject* _dbLockToken;
}
@end

@implementation ChatDBHelper

+(ChatDBHelper*) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbHelper = [[ChatDBHelper alloc] init];
        if (dbHelper != nil) {
            
        }
    });
    
    return dbHelper;
}

-(BOOL)createChatMessageTable
{
    @synchronized(_dbLockToken) {
        const char * filename = [self.chatDBPath UTF8String];
        if (sqlite3_open(filename, &_dbh) != SQLITE_OK) {
            const char* error = sqlite3_errmsg(_dbh);
            NSLog(@"Database failed to Open. %s", error);
            sqlite3_close(_dbh);
        }
        
        NSString * createSTMT = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY, '%@' INTEGER, '%@' INTEGER, '%@' TEXT, '%@' INTEGER, '%@' INTEGER, '%@' DOUBLE)", chatMessageTableName, chatTableColumn1, chatTableColumn2, chatTableColumn3, chatTableColumn4, chatTableColumn5, chatTableColumn6, chatTableColumn7];
        char * errorMesage;
        sqlite3_exec(_dbh, [createSTMT UTF8String], nil, nil, &errorMesage);
        sqlite3_close(_dbh);
        
        if (errorMesage != nil) {
            NSLog(@"errorMessage:%s", errorMesage);
            return NO;
        } else {
            return YES;
        }
    }
}

-(BOOL)insertChatMessage:(ChatMessage *)message
{
    @synchronized(_dbLockToken) {
        const char * content = [message.content UTF8String];
        const char * filename = [self.chatDBPath UTF8String];
        double messageDate = [message.date timeIntervalSince1970];
        sqlite3_stmt * stetment;
        sqlite3_open(filename, &_dbh);
        NSString * insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (%@ ,%@, %@, %@, %@, %@) VALUES(:friend_id, :who_send, :content, :content_type, :is_new, :message_date)", chatMessageTableName, chatTableColumn2, chatTableColumn3, chatTableColumn4, chatTableColumn5, chatTableColumn6, chatTableColumn7];
        const char * sql = [insertSql UTF8String];
        sqlite3_prepare(_dbh, sql, strlen(sql), &stetment, NULL);
        sqlite3_bind_int(stetment, sqlite3_bind_parameter_index(stetment, ":friend_id"), [message.myFriend chatUserId]);
        sqlite3_bind_int(stetment, sqlite3_bind_parameter_index(stetment, ":who_send"), message.whoSend);
        sqlite3_bind_text(stetment, sqlite3_bind_parameter_index(stetment, ":content"), content, strlen(content), NULL);
        sqlite3_bind_int(stetment,  sqlite3_bind_parameter_index(stetment, ":content_type"), message.contentType);
        sqlite3_bind_double(stetment, sqlite3_bind_parameter_index(stetment, ":message_date"), messageDate);
        sqlite3_bind_int(stetment, sqlite3_bind_parameter_index(stetment, ":is_new"), message.isNew);
        int r = sqlite3_step(stetment);
        sqlite3_finalize(stetment);
        sqlite3_close(_dbh);
        if (r == SQLITE_DONE) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (NSMutableArray *)MessagesAboutMyFriend:(id<ChatUser>)chatFriend page:(int)page
{
    @synchronized(_dbLockToken) {
        NSMutableArray* chatMessages = [[[NSMutableArray alloc] init] autorelease];
        const char * filename = [self.chatDBPath UTF8String];
        
        sqlite3_stmt * stetment;
        sqlite3_open(filename, &_dbh);
        NSString * selectSql = [NSString stringWithFormat:@"SELECT  * FROM %@ WHERE %@ = :friend_id ORDER BY %@ DESC limit %d, %d", chatMessageTableName, chatTableColumn2, chatTableColumn7, (page - 1) * messagesPerPage, page * messagesPerPage];
        const char * sql = [selectSql UTF8String];
        sqlite3_prepare(_dbh, sql, strlen(sql), &stetment, NULL);
        sqlite3_bind_int(stetment, sqlite3_bind_parameter_index(stetment, ":friend_id"), [chatFriend chatUserId]);
        int r = sqlite3_step(stetment);
        while (r == SQLITE_ROW) {
            ChatMessage * chatMessage = [[ChatMessage alloc] init];
            chatMessage.whoSend = sqlite3_column_int(stetment, 2);
            chatMessage.myFriend = chatFriend;
            chatMessage.content = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stetment, 3)];
            chatMessage.contentType = sqlite3_column_int(stetment, 4);
            chatMessage.isNew = sqlite3_column_int(stetment, 5);
            chatMessage.date = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stetment, 6)];
            [chatMessages addObject:chatMessage];
            [chatMessage release];
            chatMessage = nil;
            r = sqlite3_step(stetment);
        }
        sqlite3_finalize(stetment);
        sqlite3_close(_dbh);
        
        return chatMessages;
    }
}

- (NSMutableArray *) unreadMessagesAboutMyFriend:(id<ChatUser>)chatFriend
{
    @synchronized(_dbLockToken) {
        NSMutableArray* chatMessages = [[[NSMutableArray alloc] init] autorelease];
        const char * filename = [self.chatDBPath UTF8String];
        
        sqlite3_stmt * stetment;
        sqlite3_open(filename, &_dbh);
        NSString * selectSql = [NSString stringWithFormat:@"SELECT  * FROM %@ WHERE %@ = :friend_id AND %@ = :is_new ORDER BY %@", chatMessageTableName, chatTableColumn2, chatTableColumn6, chatTableColumn7];
        const char * sql = [selectSql UTF8String];
        sqlite3_prepare(_dbh, sql, strlen(sql), &stetment, NULL);
        sqlite3_bind_int(stetment, sqlite3_bind_parameter_index(stetment, ":friend_id"), [chatFriend chatUserId]);
        sqlite3_bind_int(stetment, sqlite3_bind_parameter_index(stetment, ":is_new"), 0);
        int r = sqlite3_step(stetment);
        while (r == SQLITE_ROW) {
            ChatMessage * chatMessage = [[ChatMessage alloc] init];
            chatMessage.whoSend = sqlite3_column_int(stetment,3);
            chatMessage.myFriend = chatFriend;
            chatMessage.content = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stetment, 4)];
            chatMessage.contentType = sqlite3_column_int(stetment, 5);
            chatMessage.isNew = sqlite3_column_int(stetment, 6);
            chatMessage.date = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stetment, 7)];
            [chatMessages addObject:chatMessage];
            [chatMessage release];
            chatMessage = nil;
            r = sqlite3_step(stetment);
        }
        sqlite3_finalize(stetment);
        sqlite3_close(_dbh);
        
        return chatMessages;
    }
}

- (BOOL) unreadMessage2ReadMessage:(id<ChatUser>)chatFriend
{
    @synchronized(_dbLockToken) {
        const char * filename = [self.chatDBPath UTF8String];
        sqlite3_stmt * stetment;
        sqlite3_open(filename, &_dbh);
        NSString * updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET %@ = 1 WHERE %@ = :friend_id AND %@ = 0", chatMessageTableName, chatTableColumn6, chatTableColumn2, chatTableColumn6];
        const char * sql = [updateSql UTF8String];
        sqlite3_prepare(_dbh, sql, strlen(sql), &stetment, NULL);
        sqlite3_bind_int(stetment, sqlite3_bind_parameter_index(stetment, ":friend_id"), [chatFriend chatUserId]);
        int r = sqlite3_step(stetment);
        sqlite3_finalize(stetment);
        sqlite3_close(_dbh);
        if (r == SQLITE_DONE || r == SQLITE_OK) {
            return YES;
        } else {
            return NO;
        }
    }
}

@end
