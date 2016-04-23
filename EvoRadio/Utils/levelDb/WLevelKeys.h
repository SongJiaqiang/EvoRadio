//
//  WLevelKeys.h
//  Whisper
//
//  Created by lixin on 3/14/15.
//  Copyright (c) 2015 Whisper. All rights reserved.
//

#ifndef Whisper_WLevelKeys_h
#define Whisper_WLevelKeys_h

#import "WLevelDb.h"
#import "WLevelSnapshot.h"
#import "WLevelWriteBatch.h"

#define LK_Splash(sid) ([NSString stringWithFormat:@"splash:%@", sid])

// master_type_wid -> {date}
#define LK_NotificationReaded(type,master_wid,wid) ([NSString stringWithFormat:@"Notifcation_readed:%@_%@_%@", type, master_wid, wid])

// feedId -> [wid, wid, ....]
#define LK_FeedWhispers(feedId) ([NSString stringWithFormat:@"Feed_Whispers:%@", feedId])

// wid -> {whisper object}
#define LK_Whisper(wid) ([NSString stringWithFormat:@"Whisper:%@", wid])

// wid -> whisper meta
#define LK_WhisperMeta(wid, feedId) ([NSString stringWithFormat:@"WhisperMetaFeed:%@%@", feedId, wid])

// -> wfeed object
#define LK_UserSubSchoolFeed (@"LK_UserSubSchoolFeed")

// puid -> NSDate
#define LK_HidePuid(puid) ([NSString stringWithFormat:@"HidePuid:%@", puid])

// wid -> NSDate
#define LK_FlaggedWid(wid) ([NSString stringWithFormat:@"FlaggedWid:%@", wid])

// wid -> [{reply object}, {reply object}, ...]
#define LK_ReplyFeed(wid) ([NSString stringWithFormat:@"Replies:%@", wid])

//Feed_Mine:{string ordered timestamp} -> {wid, ts}
#define LK_MineFeedPrefix() (@"Feed_Mine:")
#define LK_MineFeedItemKey(d) ([NSString stringWithFormat:@"Feed_Mine:%.8x", (uint32_t)[d timeIntervalSince1970]])

//Feed_Hearted:{string ordered timestamp} -> {wid, ts}
#define LK_HeartedFeedPrefix() (@"Feed_Hearted:")
#define LK_HeartedFeedItemKey(d) ([NSString stringWithFormat:@"Feed_Hearted:%.8x", (uint32_t)[d timeIntervalSince1970]])

//wid -> NSDate
#define LK_MineCreatedWid(wid) ([NSString stringWithFormat:@"Mine_Created:%@",wid])

//wid -> NSDate
#define LK_HeartedWid(wid) ([NSString stringWithFormat:@"Hearted:%@", wid])

//wid -> NSDate
#define LK_HeartedReplyWid(wid) ([NSString stringWithFormat:@"HeartedReplyWid:%@", wid])

//wid -> NSDate
#define LK_WhisperVote(wid) ([NSString stringWithFormat:@"WhisperVote:%@", wid])
#define LK_WhisperHaveVoted(wid) ([NSString stringWithFormat:@"WhisperHaveVoted:%@", wid])


#define LK_ReadNotificationTime() (@"LK_ReadNotificationTime")

#define LK_ConversationGroupToken(groupToken) ([NSString stringWithFormat:@"GroupToken:%@", groupToken])

#define LK_Flash_ConversationAlertText(groupToken) ([NSString stringWithFormat:@"FlashConAlertGroupToken:%@", groupToken])

#define LK_OnlineCfg (@"LK_OnlineCfg")
#define LK_UserCfg (@"LK_UserCfg")

#endif
