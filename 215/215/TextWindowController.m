//
//  TextWindowController.m
//  215
//
//  Created by Ding Orlando on 8/2/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import "TextWindowController.h"

@interface TextWindowController ()

-(void)reload;
-(void)fetchDataFinished:(id)valueOfRange;
-(void)enumerateByWords;
-(void)enumerateByWordsSlowly;

@end

@implementation TextWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here -> Not valid here, as it's not intialized.
//         if(_textview){
//            NSLog(@"%@", _textview);
//        }
    }
    
    return self;
}


#pragma window lifecycle - just for controller loading *** NOT VALID ***
-(void)windowWillLoad
{
//    NSLog(@"%@", @"windowWillLoad");
}

#pragma window lifecycle - just for controller loading *** NOT VALID ***
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.-> windows controller initialization from NIB
}

#pragma current Nib loading logic - _textview loading content via GCD
//TODO : http://stackoverflow.com/questions/3956349/nstextview-loading-rtf-view-does-not-update-correctly-until-mouse-is-moved-ove
- (void)awakeFromNib
{
//  NSLog(@"%@", @"awakeFromNib");
    if(_textview){
        [self reload];
    }
}

//TODO : switch case for implementation of NSMatrix
-(IBAction)changeSelector:(id)sender{
    NSMatrix* _optionMatrix = (NSMatrix*)sender;
    /* selected target NSButtonCell instance
     NSButtonCell* _selectedCell = (NSButtonCell*)_optionMatrix.selectedCell;
     NSLog(@"%@", _selectedCell.title);
     */
    int _selectedIndex = (int)_optionMatrix.selectedRow;
    switch (_selectedIndex) {
        case 0:
            [self reload];
            break;
        case 1:
            [self enumerateByWords];
            break;
        case 2:
            [self enumerateByWordsSlowly];
            break;
        default:
            break;
    }
}

-(void)reload{
    //TODO : GCD loading text logic asynchronously
    dispatch_async(dispatch_get_main_queue(), ^{
        //           BOOL result = [_textview readRTFDFromFile:@"/Users/llv22/Documents/02_apple_programming/05_wwdc/devcode/readme.rtf"];
        //            NSLog(@"%d", result);
        //TODO : read abosutely path content - https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Strings/Articles/readingFiles.html
        NSBundle * myMainBundle = [NSBundle mainBundle];
        NSString * rtfFilePath = [myMainBundle pathForResource:@"readme" ofType:@"rtf"];
        assert([_textview readRTFDFromFile:rtfFilePath]);
    });
}

-(void)enumerateByWords{
    NSString* strContent = [_textview string];
    id color = [NSColor redColor];
    NSRange range = NSMakeRange(0, [strContent length]);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    double delayInSeconds = 0.2;
    dispatch_time_t _tPopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //TODO : dispatch_async
    dispatch_after(_tPopTime, dispatch_get_main_queue(), ^{
        [strContent enumerateSubstringsInRange:range
                                   options:NSStringEnumerationByWords
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                    [[_textview textStorage]addAttribute:NSForegroundColorAttributeName value:color range:substringRange];
                                }
         ];
    });
}

//TODO : http://stackoverflow.com/questions/10883738/nstextview-when-to-automatically-insert-characters-like-auto-matching-parenthe
//TODO : http://borkware.com/quickies/one?topic=NSTextView
-(void)enumerateByWordsSlowly{
    NSString* strContent = [_textview string];
    long lfullTextLength = [strContent length];
    NSRange range = NSMakeRange(0, lfullTextLength);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    __block NSRange _substringRange;
    __block NSRange _enclosingRange = NSMakeRange(0, 0);
    long _leftlen = lfullTextLength;
    
    do{
        //TODO : http://developer.apple.com/library/ios/#documentation/cocoa/reference/foundation/Classes/NSValue_Class/Reference/Reference.html#//apple_ref/occ/clm/NSValue/valueWithRange:
        [strContent enumerateSubstringsInRange:range
                                       options:NSStringEnumerationByWords
                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                        id color = [NSColor redColor];
                                        [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                                                       value:color
                                                                       range:substringRange];
                                        *stop = YES;
                                        _substringRange = substringRange;
                                        _enclosingRange = enclosingRange;
                                    }
         ];
        long _lEndWordLocation = _enclosingRange.location + _enclosingRange.length;
        _leftlen = lfullTextLength - _lEndWordLocation;
        //TODO : end of _lEndWordLocation may the next start index
        range = NSMakeRange(_lEndWordLocation, _leftlen);
    }while (_leftlen > 0);
}


-(void)fetchDataFinished:(id)valueOfRange{
    id color = [NSColor redColor];
    NSValue* _value = (NSValue*)valueOfRange;
    NSRange substringRange = [_value rangeValue];
    [[_textview textStorage]addAttribute:NSForegroundColorAttributeName value:color range:substringRange];
}

@end
