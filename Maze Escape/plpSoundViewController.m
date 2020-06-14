//
//  plpViewController.h
//
//  Edgar The Explorer
//
//  Copyright (c) 2014-2016 Filipe Mathez and Paul Ronga
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation; either version 2.1 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////////////////////////
#import "plpSoundViewController.h"

@implementation plpSoundViewController

/*
 
 Ici: ajuster les sons selon la denrière valeur
 
*/
- (void)viewDidLoad
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL volumeSaved = [defaults boolForKey:@"volumeSaved"];
    if(volumeSaved == YES){
        float savedMusicVolume = [defaults floatForKey:@"musicVolume"];
        
        // float savedFxVolume = [defaults floatForKey:@"fxVolume"];
        BOOL playFX = [defaults boolForKey:@"playFX"];
        // NSLog(@"Saved music volueme: %f, other thing: %d", savedMusicVolume, playFX);
        
        [self.musicVolumeSlider setValue: savedMusicVolume animated: NO];
        // [self.fxVolumeSlider setValue: savedFxVolume animated: NO];
        
        if(playFX == NO){
            [_fxSwitch setOn:NO animated:NO];
        }
    } else {
        NSLog(@"(soundView) No saved volumes found in prefs");
    }
}

- (IBAction)musicVolumeChanged:(id)sender {
    // Here we could change music volume directly
    self->valuesDidChange = TRUE;
}

/*- (IBAction)fxVolumeChanged:(id)sender {
    // Here we could play a sound
    // UISlider *slider = (UISlider *)sender;
    // NSLog(@"SliderValue ... %f",(float)[slider value]);
    self->valuesDidChange = TRUE;
}*/

- (IBAction)fxSwitchChanged:(id)sender {
    self->valuesDidChange = TRUE;
}
- (IBAction)applyChanges:(id)sender {
    NSLog(@"Save volume changes...");
    NSLog(@"SliderValue ... %f", self.musicVolumeSlider.value);
    //[(plpSoundController*)mySoundController setMusicVolume];
    if(self->valuesDidChange == TRUE){
        NSLog(@"Values did change so we update user prefs");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:self.musicVolumeSlider.value forKey:@"musicVolume"];
        // [defaults setFloat:self.fxVolumeSlider.value forKey:@"fxVolume"];
        [defaults setBool: _fxSwitch.on forKey:@"playFX"];
        [defaults setBool:YES forKey:@"volumeSaved"];
        [defaults synchronize];
    }
}

@end
