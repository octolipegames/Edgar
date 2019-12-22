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
//        self.muteSoundFX = FALSE;
//        self.muteMusic = FALSE;
        self.muteSoundFX = TRUE;
        self.muteMusic = TRUE;
//        [self setMuteSoundFX: TRUE];
//        [self setMuteMusic: TRUE];
        self->pushingCrate = FALSE;

//        [self updateVolumes];
    }
    else{
        return nil;
    }
    
    return self;
}

- (void) getStoredVolumes{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL volumeSaved = [defaults boolForKey:@"volumeSaved"];
    
    if(volumeSaved == YES){
        float savedMusicVolume = [defaults floatForKey:@"musicVolume"];
        float savedFxVolume = [defaults floatForKey:@"fxVolume"];
        
        self->musicVolume = savedMusicVolume;
        if(savedMusicVolume == 0){
            NSLog(@"music is muted");
            [self setMuteMusic: TRUE];
        }
        self->fxVolume = savedFxVolume;
        if(savedFxVolume == 0){
            NSLog(@"fx are muted");
            [self setMuteSoundFX: TRUE];
//            self.muteSoundFX = TRUE;
        }
    } else {
        NSLog(@"(soundController) No saved volumes found in prefs");
        self->musicVolume = 1.0f;
        self->fxVolume = 1.0f;
    }
    NSLog(@"Stored volumes retrieved: %f / %f", self->musicVolume, self->fxVolume);
}

- (void) updateVolumes{
    [self getStoredVolumes];
    if(!self -> muteSoundFX){
        self.audioPlayer.volume = self->musicVolume;
        self.jumpAudioPlayer.volume = self->fxVolume;
        self.alienAudioPlayer.volume = self->fxVolume;
        self.crateAudioPlayer.volume = self->fxVolume;
        self.takeCellAudioPlayer.volume = self->musicVolume;
        self.liftReadyAudioPlayer.volume = self->musicVolume;
        self.takeLiftAudioPlayer.volume = self->musicVolume;
        self.trainImpactAudioPlayer.volume = self->musicVolume;
        self.footstepAudioPlayer.volume = self->musicVolume;
    }
}

- (float) getFxVolume{
    return self->fxVolume;
}

/*- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            NSLog(@"Headphones in");
            return YES;
    }
    return NO;
}*/

-(void)startPlaying
{
    if(self.audioPlayer){
        [self.audioPlayer play];
    }else{
        NSLog(@"WARNING: no audioPlayer yet");
    }
}

-(void)playTune:(NSString*)filename loops:(int)loops
{
    NSLog(@"playTune called");
    if( self -> muteMusic){
        NSLog(@"Music muted - we dont play");
        return;
    } else {
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"mp3"];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = loops;
        self.audioPlayer.volume = self->musicVolume;
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
        self.audioPlayer.volume = self->musicVolume;
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
    
    if( self -> muteSoundFX){
        NSLog(@"Sound fx muted - we dont initialize sounds");
        return;
    }
    
    // lagge trop avec AVAudioPlayer
    leftFootstepSound = [SKAction playSoundFileNamed:@"Sounds/fx_pas_gauche.aif" waitForCompletion:YES];
    rightFootstepSound = [SKAction playSoundFileNamed:@"Sounds/fx_pas_droit.aif" waitForCompletion:YES];

    // sons avec AVAudioPlayer
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        NSError* error = nil;
    
        /*
        NSURL *footstepSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_pas" withExtension:@"wav"];
        self.footstepAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:footstepSoundURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            self.footstepAudioPlayer.numberOfLoops = -1;
            [self.footstepAudioPlayer setVolume:self->fxVolume];
            [self.footstepAudioPlayer prepareToPlay];
        }
        */

        NSURL *jumpSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_jump" withExtension:@"wav"];
        self.jumpAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:jumpSoundURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.jumpAudioPlayer setVolume:self->fxVolume];
            [self.jumpAudioPlayer prepareToPlay];
        }
    
        NSURL *alienSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_alien" withExtension:@"wav"];
        self.alienAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: alienSoundURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.alienAudioPlayer setVolume:self->fxVolume];
            [self.alienAudioPlayer prepareToPlay];
        }
    
        NSURL *crateSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_caisse_short" withExtension:@"wav"];
        self.crateAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: crateSoundURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.crateAudioPlayer setVolume:self->fxVolume];
            [self.crateAudioPlayer prepareToPlay];
        }
    
        NSURL *takeCellURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_pile" withExtension:@"aif"];
        self.takeCellAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:takeCellURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.takeCellAudioPlayer setVolume:self->fxVolume];
            [self.takeCellAudioPlayer prepareToPlay];
        }
    
        NSURL *liftReadyURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_bouton_porte" withExtension:@"wav"];
        self.liftReadyAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:liftReadyURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.liftReadyAudioPlayer setVolume:self->fxVolume];
            [self.liftReadyAudioPlayer prepareToPlay];
        }
    
        NSURL *takeLiftURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_arrivee_ascenseur" withExtension:@"wav"];
        self.takeLiftAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:takeLiftURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.takeLiftAudioPlayer setVolume:self->fxVolume];
            [self.takeLiftAudioPlayer prepareToPlay];
        }
    
        NSURL *trainImpactURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_chariot_tombe" withExtension:@"wav"];
        self.trainImpactAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:trainImpactURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.trainImpactAudioPlayer setVolume:self->fxVolume];
            [self.trainImpactAudioPlayer prepareToPlay];
        }
    });
    NSLog(@"Init sounds done");
}

- (void) playJumpSound {
    if ( !self -> muteSoundFX ){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self.jumpAudioPlayer play];
            [self.jumpAudioPlayer prepareToPlay];
        });
        
    }
}

- (void) playTakeCellSound {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        if( !self->muteSoundFX){
            [self.takeCellAudioPlayer play];
        }
    });
}

- (void) playLiftReadySound {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        if ( !self -> muteSoundFX ){
            [self.liftReadyAudioPlayer play];
        }
    });
}
- (void) playTakeLiftSound {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        if ( !self -> muteSoundFX ){
            [self.takeLiftAudioPlayer play];
        }
    });
}

- (void) playTrainImpactSound {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        if ( !self -> muteSoundFX ){
            [self.trainImpactAudioPlayer play];
        }
    });
}

- (void) playFootstepSound {
    if ( ! self -> muteSoundFX ){
        [self runAction:[SKAction repeatActionForever:
                         [SKAction sequence: @[rightFootstepSound, leftFootstepSound]]] withKey:@"footstepSound"];

        // [self.footstepAudioPlayer play];
    }
}
-(void) stopFootstepSound {
    if ( !self -> muteSoundFX ){
        [self removeActionForKey:@"footstepSound"];

        // [self.footstepAudioPlayer pause];
        // self.footstepAudioPlayer.currentTime = 0;
    }
}


- (void) playCrateSound {
    if ( !self -> muteSoundFX ){
        if(!pushingCrate){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                self.crateAudioPlayer.volume = self->fxVolume;
                [self.crateAudioPlayer play];
                self->pushingCrate = true;
            });
        }
    }
}
- (void) fadeOutCrateSound {
    if (!pushingCrate){
        if (self.crateAudioPlayer.volume > 0.15) {
            self.crateAudioPlayer.volume -= 0.15;
            [self performSelector:@selector(fadeOutCrateSound) withObject:nil afterDelay:0.1];
        }else{
            [self.crateAudioPlayer stop];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                [self.crateAudioPlayer prepareToPlay];
            });
        }
    }
}
- (void) stopCrateSound {
    if ( !self -> muteSoundFX ){
        // NSLog(@"stopit");
        [self performSelector:@selector(fadeOutCrateSound) withObject:nil afterDelay:0.5];
        pushingCrate = false;
        
    }
}

- (void) playAlienSound {
    if ( !self -> muteSoundFX ){
        [self.alienAudioPlayer play];
    }
}
- (void) stopAlienSound {
    if ( !self -> muteSoundFX ){
        [self.alienAudioPlayer stop];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self.alienAudioPlayer prepareToPlay];
        });
    }
}


@end
