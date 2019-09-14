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
#import "plpPrefsViewController.h"

@implementation plpPrefsViewController

/*
 
 Ici: ajuster les sons selon la denrière valeur
 
*/
- (void)viewDidLoad
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL useSwipeGestures = [defaults boolForKey:@"useSwipeGestures"];
    BOOL enableDebug = [defaults boolForKey:@"enableDebug"];
    
    if(useSwipeGestures == YES){
        NSLog(@"View loaded - using swipe gestures");
        [_swipeSwitch setOn:YES animated:NO];
    } else {
        NSLog(@"View loaded - not using swipe gestures");
    }
    if(enableDebug == YES){
        NSLog(@"View loaded - using swipe gestures");
        [_debugSwitch setOn:YES animated:NO];
    }
}


- (IBAction)applyChanges:(id)sender {
    NSLog(@"prefs: save");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: _swipeSwitch.on forKey:@"useSwipeGestures"];
    [defaults setBool: _debugSwitch.on forKey:@"enableDebug"];
    [defaults synchronize];
}


@end
