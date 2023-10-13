//
//  ZRViewController.m
//  ZombieRun
//
//  Created by local on 8/7/12.
//  Copyright (c) 2012 Timberwoof. All rights reserved.
//

#import "ZRViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ZRViewController ()

// action buttons
- (IBAction)grabDice:(id)sender;
- (IBAction)rollDice:(id)sender;
- (IBAction)countDice:(id)sender;
- (IBAction)ednTurn:(id)sender;

// dicePictureCells: Dice In Hand
@property (weak, nonatomic) IBOutlet UIImageView *myDie1;
@property (weak, nonatomic) IBOutlet UIImageView *myDie2;
@property (weak, nonatomic) IBOutlet UIImageView *myDie3;

// brainPictureCells: Brain Pile
@property (weak, nonatomic) IBOutlet UIImageView *myBrain1;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain2;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain3;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain4;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain5;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain6;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain7;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain8;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain9;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain10;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain11;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain12;
@property (weak, nonatomic) IBOutlet UIImageView *myBrain13;

// shotPictureCells: Shots
@property (weak, nonatomic) IBOutlet UIImageView *shot1;
@property (weak, nonatomic) IBOutlet UIImageView *shot2;
@property (weak, nonatomic) IBOutlet UIImageView *shot3;

@end

static int const red = 0;
static int const yellow = 1;
static int const green = 2;

static int const none = -1;
static int const shotgun = 0;
static int const runner = 1;
static int const brain = 2;

static int grabOrPass = 1;
static int roll = 2;
static int count = 3;
int buttonstate = 0;

AVAudioPlayer *yaySound;
AVAudioPlayer *awwwSound;
AVAudioPlayer *brainSound;
AVAudioPlayer *runnerSound;
AVAudioPlayer *shotgunSound;

@implementation ZRViewController
@synthesize shot1;
@synthesize shot2;
@synthesize shot3;
@synthesize myBrain1;
@synthesize myBrain2;
@synthesize myBrain3;
@synthesize myBrain4;
@synthesize myBrain5;
@synthesize myBrain6;
@synthesize myBrain7;
@synthesize myBrain8;
@synthesize myBrain9;
@synthesize myBrain10;
@synthesize myBrain11;
@synthesize myBrain12;
@synthesize myBrain13;
@synthesize myDie1;
@synthesize myDie2;
@synthesize myDie3;

NSNumber *noDie;
NSArray *redDie;
NSArray *yellowDie;
NSArray *greenDie;
NSArray *freshBagOfDice;
NSArray *dicePictureFiles;
NSArray *dicePictureCells;
NSArray *brainPictureCells;
NSArray *shotPictureCells;
NSArray *diceFaceSounds;

NSMutableArray *diceInBag;
NSMutableArray *diceInHand;
NSMutableArray *dieRolls;
int accumulatedBrains;
int accumulatedShotguns;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewDidLoad");
    
    noDie = [NSNumber numberWithInt:0];
    
    redDie = [NSArray arrayWithObjects:
              [NSNumber numberWithInt:brain],
              [NSNumber numberWithInt:shotgun],
              [NSNumber numberWithInt:runner],
              [NSNumber numberWithInt:shotgun],
              [NSNumber numberWithInt:runner],
              [NSNumber numberWithInt:shotgun],
              nil ] ;
    
    yellowDie = [NSArray arrayWithObjects:
                 [NSNumber numberWithInt:brain],
                 [NSNumber numberWithInt:runner],
                 [NSNumber numberWithInt:shotgun],
                 [NSNumber numberWithInt:brain],
                 [NSNumber numberWithInt:runner],
                 [NSNumber numberWithInt:shotgun],
                 nil ] ;
    
    greenDie = [NSArray arrayWithObjects:
                [NSNumber numberWithInt:brain],
                [NSNumber numberWithInt:runner],
                [NSNumber numberWithInt:brain],
                [NSNumber numberWithInt:shotgun],
                [NSNumber numberWithInt:brain],
                [NSNumber numberWithInt:runner],
                nil ] ;
    
    dicePictureFiles = [NSArray arrayWithObjects:@"/Boom.png",@"/Runner.png",@"/brains.png", nil];
    dicePictureCells = [NSArray arrayWithObjects:myDie1, myDie2, myDie3, nil];
    brainPictureCells = [NSArray arrayWithObjects:myBrain1, myBrain2, myBrain3, myBrain4,
                         myBrain5, myBrain6, myBrain7, myBrain8, myBrain9,
                         myBrain10, myBrain11, myBrain12, myBrain13, nil];
    shotPictureCells = [NSArray arrayWithObjects:shot1, shot2, shot3, nil];
    
    diceFaceSounds = [NSArray arrayWithObjects:@"Shotgun.caf",@"runner.caf",@"NomNomNom.caf",nil];
    
    freshBagOfDice=[NSArray arrayWithObjects:
                    greenDie, yellowDie, redDie, greenDie,
                    yellowDie, greenDie, redDie, greenDie,
                    yellowDie, greenDie, redDie, yellowDie, greenDie, nil];
    diceInBag = [[NSMutableArray alloc] init];
    diceInHand = [[NSMutableArray alloc] init];
    dieRolls = [[NSMutableArray alloc] init];
    
    accumulatedBrains = 0;
    accumulatedShotguns = 0;
    
    // generate a my bag of dice from the fresh bag
    NSUInteger countDice = [freshBagOfDice count];
    int i;
    for (i = 0; i < countDice; i++) {
        NSObject *theDie = [freshBagOfDice objectAtIndex: i];
        [diceInBag addObject: theDie];
    }
    NSLog(@"%li dice in bag",[diceInBag count]);
    
    // generate empty array of dice in hand
    for (i = 0; i < 3; i++) {
        [diceInHand addObject:noDie];
    }
    
    // set up sounds
    NSURL *yaySoundURL   = [[NSBundle mainBundle] URLForResource: @"yay" withExtension: @"caf"];
    yaySound = [[AVAudioPlayer alloc] initWithContentsOfURL:yaySoundURL error:nil];
    
    NSURL *awwwSoundURL   = [[NSBundle mainBundle] URLForResource: @"awww" withExtension: @"caf"];
    awwwSound = [[AVAudioPlayer alloc] initWithContentsOfURL:awwwSoundURL error:nil];
    
    NSURL *brainSoundURL   = [[NSBundle mainBundle] URLForResource: @"NomNomNom" withExtension: @"caf"];
    brainSound = [[AVAudioPlayer alloc] initWithContentsOfURL:brainSoundURL error:nil];
    
    NSURL *runnerSoundURL   = [[NSBundle mainBundle] URLForResource: @"runner" withExtension: @"caf"];
    runnerSound = [[AVAudioPlayer alloc] initWithContentsOfURL:runnerSoundURL error:nil];
    
    NSURL *shotgunSoundURL   = [[NSBundle mainBundle] URLForResource: @"Shotgun" withExtension: @"caf"];
    shotgunSound = [[AVAudioPlayer alloc] initWithContentsOfURL:shotgunSoundURL error:nil];
    
    buttonstate = grabOrPass;
    
    NSLog(@"viewDidLoad end");
}



- (IBAction)grabDice:(UIButton *)sender {
    NSLog(@"grabDice");
    if (buttonstate == grabOrPass)
    {
        // cannot take more dice than there are
        NSUInteger numberOfDiceToGrab = 3;
        NSUInteger numberOfDiceInBag = [diceInBag count];
        if (numberOfDiceInBag < 3) {
            numberOfDiceToGrab = numberOfDiceInBag;
        }
        
        int i;
        int grabbed = 0;
        for (i = 0; i < numberOfDiceToGrab; i++) {
            // IF a specific die is none
            if ([diceInHand objectAtIndex: i] == noDie) {
                // pick a die out of the local bag and put it my hand
                NSUInteger which = arc4random_uniform(numberOfDiceToGrab);
                [diceInHand replaceObjectAtIndex:i withObject: [diceInBag objectAtIndex: which]];
                [diceInBag removeObjectAtIndex:which];
                
                NSString *myImagePath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingString:@"/ZombieDice.png"];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile: myImagePath]; // set the image
                [[dicePictureCells objectAtIndex:i] setImage: image];
                grabbed ++;
            } // end if no die
            // the canonical rule is: If you don’t have three dice left in the cup,
            // make a note of how many Brains you have and put them all in the cup
            // (keep the Shotguns in front of you). Then continue.
            
        } // end for dice in hand to replenish
        NSLog(@"grabbed %i more dice",grabbed);
        
        // report the dice I grabbed
        unsigned long j;
        unsigned long jlimit = [diceInHand count];
        NSLog(@"%li dice in hand:",jlimit);
        for (j = 0; j < jlimit; j++) {
            NSLog(@"%li: %li ",j,(unsigned long)[diceInHand objectAtIndex: j]);
        }
        
        NSLog(@"%li dice in bag",[diceInBag count]);
        buttonstate = roll;
    }
    NSLog(@"grabDice done");
}

- (IBAction)rollDice:(id)sender {
    // roll dice and display the results
    NSLog(@"rollDice");
    if (buttonstate == roll)
    {
        
        int i;
        for (i = 0; i<3; i++) {
            // if there is a dice in hand
            if ([diceInHand objectAtIndex: i] != noDie) {
                NSArray *theDie = [diceInHand objectAtIndex: i]; // returns a dice, an array of ints
                unsigned long whichFace = arc4random_uniform(6);
                int theRoll = [[theDie objectAtIndex: whichFace] intValue]; // returns an integer, a face number
                NSLog(@"rollDice face %li, roll %i",whichFace,theRoll);
                [dieRolls insertObject:[NSNumber numberWithInt:theRoll] atIndex:i]; // remember the rolls
                NSString *diceFileName = [dicePictureFiles objectAtIndex:theRoll]; // get the filename
                NSString *myImagePath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingString:diceFileName];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile: myImagePath]; // set the image
                [[dicePictureCells objectAtIndex:i] setImage: image];
            }
        }
        buttonstate = count;
    }
    NSLog(@"rollDice done");
}

- (IBAction)countDice:(id)sender {
    // examine the rolled dice and do the right thing
    NSLog(@"countDice");
    
    if (buttonstate == count)
    {
        int i;
        for (i = 0; i<3; i++) {
            long int theRoll = [[dieRolls objectAtIndex: i] intValue]; // returns an integer, a face number
            
            // play cute sound for runners
            if (theRoll == runner) {
                [runnerSound play];
                while ([runnerSound isPlaying]) {
                    NSDate  *limit = [NSDate dateWithTimeIntervalSinceNow: 0.2];
                    [[NSRunLoop currentRunLoop] runUntilDate: limit];
                }
            } // end runners
            
            // accumulate brains
            if (theRoll == brain) {
                NSString *diceFileName = [dicePictureFiles objectAtIndex:brain]; // get the filename
                NSString *myImagePath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingString:diceFileName];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile: myImagePath]; // set the image
                [[brainPictureCells objectAtIndex:accumulatedBrains] setImage: image];
                accumulatedBrains ++;
                
                // remove from dice in hand
                [[dicePictureCells objectAtIndex:i] setImage: nil];
                [diceInHand replaceObjectAtIndex:i withObject: noDie];
                
                // play cute sound for brains
                [brainSound play];
                while ([brainSound isPlaying]) {
                    NSDate  *limit = [NSDate dateWithTimeIntervalSinceNow: 0.2];
                    [[NSRunLoop currentRunLoop] runUntilDate: limit];
                }
            } // end accumulate brains
            
            // accumulate up to three shotguns
            if ((theRoll == shotgun) && (accumulatedShotguns < 3)) {
                NSString *diceFileName = [dicePictureFiles objectAtIndex:shotgun]; // get the filename
                NSString *myImagePath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingString:diceFileName];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile: myImagePath]; // set the image
                [[shotPictureCells objectAtIndex:accumulatedShotguns] setImage: image];
                accumulatedShotguns ++;
                
                // remove from dice in hand
                [[dicePictureCells objectAtIndex:i] setImage: nil];
                [diceInHand replaceObjectAtIndex:i withObject: noDie];
                
                // play cute sound for shotgun
                [shotgunSound play];
                while ([shotgunSound isPlaying]) {
                    NSDate  *limit = [NSDate dateWithTimeIntervalSinceNow: 0.2];
                    [[NSRunLoop currentRunLoop] runUntilDate: limit];
                }
            } // end accumulate shotguns
            
            if (accumulatedShotguns >= 3) {
                accumulatedBrains = 0;
                [awwwSound play];
                while ([awwwSound isPlaying]) {
                    NSDate  *limit = [NSDate dateWithTimeIntervalSinceNow: 0.2];
                    [[NSRunLoop currentRunLoop] runUntilDate: limit];
                }
                break;
            } // end check for three shotguns
            
        } // end look at rolled dice
        buttonstate = grabOrPass;
    }
    NSLog(@"countDice done");
}

- (IBAction)ednTurn:(id)sender {
    NSLog(@"endTurn");
    if (buttonstate == grabOrPass)
    {
        [yaySound play];
    }
    NSLog(@"endTurn done");
}
@end
