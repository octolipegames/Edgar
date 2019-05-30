//
//  plpSoundController.m
//  Edgar_the_Explorer
//
//  Created by Paul on 17.03.19.
//  Copyright © 2019 Polip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
//#import <AVFoundation/AVAudioSession.h>

@interface plpSoundController : SKSpriteNode {
    SKAction *jumpSound;
    BOOL muteMusic;
    BOOL muteSoundFX;
}

- (BOOL)isHeadsetPluggedIn;

// Music
- (void)playTune:(NSString*)filename loops:(int)loops;
- (void)doVolumeFade;

// Sounds
- (void)initSounds;
- (void)playJumpSound;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property(nonatomic, weak) SKNode *listener;

@end
