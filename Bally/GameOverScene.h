//
//  GameOverScene.h
//  Bally
//
//  Created by Saida Memon on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <UIKit/UIKit.h>

@interface GameOverScene : CCLayer <UITextFieldDelegate, UIAlertViewDelegate>
{
	CCLabelTTF *winner1;
    CCLabelTTF *winner2;
    CCLabelTTF *winner3;
	CCLabelTTF *HS1;
    CCLabelTTF *HS2;
    CCLabelTTF *HS3;
    int newHS;
    int H1;
    int H2;
    int H3;
    NSString* W1;
    NSString* W2;
    NSString* W3;
    
    NSString *newWinner;
    
    CCLabelTTF* tapLabel;
    CCLabelTTF* newHSlabel;
    UITextField* myTextField;
    
    BOOL muted;
    UIAlertView *myAlertView;
}

+(id) scene;
- (void)saveData;
- (void)restoreData;
- (void)testScore;
- (void)printScores;
-(void)setLabels;

@end