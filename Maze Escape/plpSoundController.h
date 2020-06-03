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
    
    SKAction *leftFootstepSound;
    SKAction *rightFootstepSound;
    
    SKAudioNode *platformSound;
}

-(id)init;
- (BOOL)isHeadsetPluggedIn;

- (void) getStoredVolumes;
- (void) updateVolumes;
- (float) getFxVolume;

// Music
- (void)playTune:(NSString*)filename loops:(int)loops;
- (void)doVolumeFade;

// Sounds
- (void) initProjectorSound;
- (void) initSounds;
- (void) playJumpSound;
- (void) playTakeCellSound;
- (void) playLiftReadySound;
- (void) playTakeLiftSound;
- (void) playFootstepSound;
- (void) stopFootstepSound;
- (void) playCrateSound;
- (void) stopCrateSound;
- (void) playTrainImpactSound;
- (void) playAlienSound;
- (void) stopAlienSound;
- (void) playDeathSound;
- (void) playProjectorSound;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioPlayer *jumpAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *alienAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *crateAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *deathAudioPlayer;

@property (strong, nonatomic) AVAudioPlayer *takeCellAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *liftReadyAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *takeLiftAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *trainImpactAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *projectorAudioPlayer;

@property(nonatomic, weak) SKNode *listener;

@end
