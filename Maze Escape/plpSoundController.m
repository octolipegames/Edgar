//
//  plpSoundController.m
//  Edgar_the_Explorer
//
//  Created by Paul on 17.03.19.
//  Copyright © 2019 Polip. All rights reserved.
//

#import "plpSoundController.h"

/*
 manages:
 - when sound gets muted
 - when sound should / should not get played
 
*/

@implementation plpSoundController

- (id)init
{
    NSLog(@"init sound controller");
    
    self = [super init];
    
    if(self){
        // TODO check for silent mode, headphones etc. here
        self.muteSoundFX = FALSE;
        self.muteMusic = TRUE;
        
        self->pushingCrate = FALSE;

        // @TODO: get prefs
        self->musicVolume = 1.0f;
        self->fxVolume = 1.0f;
    }
    else{
        return nil;
    }
    
    return self;
}

- (void) playSound{
    NSError *error;
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"fx_jump" withExtension:@"wav"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    [player setVolume:fxVolume];
    [player prepareToPlay];
    
    SKAction*   playAction = [SKAction runBlock:^{
        [player play];
    }];
    SKAction *waitAction = [SKAction waitForDuration:player.duration+1];
    SKAction *sequence = [SKAction sequence:@[playAction, waitAction]];
    
    [self runAction:sequence];
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

-(void)startPlaying
{
    if(self.audioPlayer)
        [self.audioPlayer play];
}

-(void)playTune:(NSString*)filename loops:(int)loops
{
    NSLog(@"playTune called");
    if( !self->muteMusic == true ){
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"mp3"];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = loops;
        if (!self.audioPlayer) {
            NSLog(@"Error creating player: %@", error);
        }
        [NSThread detachNewThreadSelector:@selector(startPlaying) toTarget:self withObject:nil];
    }
}

- (void)doVolumeFade
{
    if (self.audioPlayer.volume > 0.1) {
        self.audioPlayer.volume = self.audioPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.volume = 1.0;
    }
}

- (void)setMuteMusic: (BOOL) muted{
    self -> muteMusic = muted;
}
- (void)setMuteSoundFX: (BOOL) muted{
    self -> muteSoundFX = muted;
}
- (BOOL)getMuteMusic{
    return self -> muteMusic;
}
- (BOOL)getMuteSoundFX{
    return self -> muteSoundFX;
}

- (void)initSounds {
/*    platformSound = [[SKAudioNode alloc] initWithFileNamed:@"Sounds/fx_elevateur.wav"];
    platformSound.autoplayLooped = false;
    platformSound.position = CGPointMake(0, 0);
    platformSound.positional = true;*/
    if( self -> muteSoundFX){
        NSLog(@"Sound fx muted - we dont initialize sounds");
        return;
    }
    jumpSound = [SKAction playSoundFileNamed:@"Sounds/fx_jump.wav" waitForCompletion:NO];
    takeCellSound = [SKAction playSoundFileNamed:@"Sounds/fx_pile.aif" waitForCompletion:NO];
    liftReadySound = [SKAction playSoundFileNamed:@"Sounds/fx_bouton_porte.wav" waitForCompletion:NO];
    takeLiftSound = [SKAction playSoundFileNamed:@"Sounds/fx_arrivee_ascenseur.wav" waitForCompletion:NO];
    leftFootstepSound = [SKAction playSoundFileNamed:@"Sounds/fx_pas_gauche.aif" waitForCompletion:YES];
    rightFootstepSound = [SKAction playSoundFileNamed:@"Sounds/fx_pas_droit.aif" waitForCompletion:YES];
    crateSound = [SKAction playSoundFileNamed:@"Sounds/fx_caisse_short.wav" waitForCompletion:YES];
    trainImpactSound = [SKAction playSoundFileNamed:@"Sounds/fx_chariot_tombe.wav" waitForCompletion:NO];
    
    NSLog(@"Init sounds done");
}

- (void) playJumpSound {
    //NSLog(@"sadf");
    if ( !self -> muteSoundFX ){
        [self playSound];
        //[self runAction: jumpSound];
    }
}
- (void) playTakeCellSound {
    if ( !self -> muteSoundFX ){
        [self runAction: takeCellSound];
    }
}
- (void) playLiftReadySound {
    if ( !self -> muteSoundFX ){
        [self runAction: liftReadySound];
    }
}
- (void) playTakeLiftSound {
    if ( !self -> muteSoundFX ){
        [self runAction: takeLiftSound];
    }
}

-(void) playFootstepSound {
    if ( !self -> muteSoundFX ){
        [self runAction:[SKAction repeatActionForever:
                     [SKAction sequence: @[rightFootstepSound, leftFootstepSound]]] withKey:@"footstepSound"];
    }
}
-(void) stopFootstepSound {
    if ( !self -> muteSoundFX ){
        [self removeActionForKey:@"footstepSound"];
    }
}


- (void) playCrateSound {
    if ( !self -> muteSoundFX ){
        if(!pushingCrate){
            [self runAction: [SKAction sequence: @[crateSound, [SKAction runBlock:^{
                self->pushingCrate = false;
            }] ] ] withKey: @"pushingCrate"];
            pushingCrate = true;
        }
    }
}
- (void) stopCrateSound {
    if ( !self -> muteSoundFX ){
        NSLog(@"stopit");
        [self removeActionForKey:@"pushingCrate"];
    }
}

- (void) playTrainImpactSound {
    if ( !self -> muteSoundFX ){
        [self runAction: trainImpactSound];
    }
}


//- (void) getPlatformSound {
//    return self->platformSound;
//}

@end
