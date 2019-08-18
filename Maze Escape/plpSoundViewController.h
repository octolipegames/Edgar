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

#import <UIKit/UIKit.h>
#import "plpSoundController.h"

@interface plpSoundViewController : UIViewController
{
    BOOL valuesDidChange;
    SKSpriteNode *mySoundController;
}
@property (weak, nonatomic) IBOutlet UISlider *musicVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *fxVolumeSlider;

- (IBAction)musicVolumeChanged:(id)sender;
- (IBAction)fxVolumeChanged:(id)sender;
- (IBAction)applyChanges:(id)sender;

@end
