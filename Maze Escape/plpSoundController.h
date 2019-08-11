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
    BOOL muteMusic;
    BOOL muteSoundFX;
    BOOL pushingCrate;
    float musicVolume;
    float fxVolume;
    
    SKAction *jumpSound;
    SKAction *takeCellSound;
    SKAction *activateLiftSound;
    SKAction *takeLiftSound;
    SKAction *liftReadySound;
    SKAction *leftFootstepSound;
    SKAction *rightFootstepSound;
    SKAction *crateSound;
    SKAction *trainImpactSound;
    
    SKAudioNode *platformSound;
}

-(id)init;
- (BOOL)isHeadsetPluggedIn;

// Music
- (void)playTune:(NSString*)filename loops:(int)loops;
- (void)doVolumeFade;

// Sounds
- (void) playSound;
- (void) initSounds;
- (void) playJumpSound;
- (void) playTakeCellSound;
- (void) playLiftReadySound;
- (void) playTakeLiftSound;
- (void) playFootstepSound;
- (void) stopFootstepSound;
/*- (void) playLeftFootstepSound;
- (void) playRightFootstepSound;*/
- (void) playCrateSound;
- (void) stopCrateSound;
- (void) playTrainImpactSound;
- (void) playAlienSound;
- (void) stopAlienSound;
//- (id)getPlatformSound;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioPlayer *jumpAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *alienAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *crateAudioPlayer;

@property(nonatomic, weak) SKNode *listener;

@end
