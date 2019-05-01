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
#import <AVFoundation/AVAudioSession.h>

@interface plpSoundController : NSObject {
    SKAudioNode *platformSound;
    BOOL muteMusic;
    BOOL muteSoundFX;
}
- (BOOL)isHeadsetPluggedIn;
- (void)initSounds;
@end
