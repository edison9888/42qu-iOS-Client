//
//  CustomSegmentedControl.m
//  42qu
//
//  Created by Alex Rezit on 12-6-16.
//  Copyright (c) 2012年 Seymour Dev. All rights reserved.
//

#import "CustomSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomSegmentedControl

@synthesize delegate = _delegate;

@synthesize buttons = _buttons;

@synthesize titles = _titles;
@synthesize highlightedTitles = _highlightedTitles;
@synthesize selectedTitles = _selectedTitles;
@synthesize dividerImage = _dividerImage;
@synthesize highlightedBackgroundImage = _highlightedBackgroundImage;
@synthesize selectedBackgroundImage = _selectedBackgroundImage;
@synthesize highlightedBackgroundImageView = _highlightedBackgroundImageView;
@synthesize selectedBackgroundImageView = _selectedBackgroundImageView;

- (void)highlightButton:(UIButton *)button
{
    for (UIButton *oneButton in _buttons) {
        if (button == oneButton) {
            _highlightedBackgroundImageView.frame = oneButton.frame;
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.duration = 0.15f;
            [self.layer addAnimation:transition forKey:nil];
            [UIView animateWithDuration:0.15f animations:^{
                _highlightedBackgroundImageView.hidden = NO;
            }];
        }
    }
}

- (void)highlightButtonCancel:(UIButton *)button
{
    for (UIButton *oneButton in _buttons) {
        if (button == oneButton) {
            _highlightedBackgroundImageView.frame = oneButton.frame;
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.duration = 0.15f;
            [self.layer addAnimation:transition forKey:nil];
            [UIView animateWithDuration:0.15f animations:^{
                _highlightedBackgroundImageView.hidden = YES;
            }];
        }
    }
}

- (void)selectButton:(UIButton *)button
{
    for (UIButton *oneButton in _buttons) {
        if (button == oneButton) {
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.duration = 0.2f;
            [self.layer addAnimation:transition forKey:nil];
            _selectedBackgroundImageView.hidden = YES;
            _selectedBackgroundImageView.frame = oneButton.frame;
            [UIView animateWithDuration:0.2f animations:^{
                _selectedBackgroundImageView.hidden = NO;
                _highlightedBackgroundImageView.hidden = YES;
            }];
        }
    }
}

- (void)buttonTouchUpInside:(UIButton *)button
{
    [self selectButton:button];
    [self.delegate customSegmentedControl:self didSelectItemAtIndex:[_buttons indexOfObject:button]];
}

- (void)buttonTouchedDown:(UIButton *)button
{
    [self highlightButton:button];
}

- (void)buttonTouchedOther:(UIButton *)button
{
    [self highlightButtonCancel:button];
}

#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame Titles:(NSArray *)titles andHighlightedTitles:(NSArray *)highlightedTitles andSelectedTitles:(NSArray *)selectedTitles andBackgroundImage:(UIImage *)backgroundImage andDividerImage:(UIImage *)dividerImage andHighlightedBackgroundImage:(UIImage *)highlightedBackgroundImage andSelectedBackgroundImage:(UIImage *)selectedBackgroundImage
{
    self = [super initWithFrame:frame];
    if (self) {
        if (titles.count > 0) { // When the number of buttons > 0, generate the segmented control
            if ((highlightedTitles.count && titles.count != highlightedTitles.count) || (selectedTitles.count && titles.count != selectedTitles.count)) { // When titles and highlighted/selected titles not match, return an empty view
                NSLog(@"Custom Segmented Control: Titles and highlighted titles not match");
                return self;
            }
            // Set the attributes
            self.titles = titles;
            self.highlightedTitles = highlightedTitles;
            self.selectedTitles = selectedTitles;
            self.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
            self.dividerImage = dividerImage;
            self.highlightedBackgroundImage = highlightedBackgroundImage;
            self.selectedBackgroundImage = selectedBackgroundImage;
            
            // Calculate the size
            CGFloat dividerWidth = dividerImage?dividerImage.size.width:0;
            CGFloat height = frame.size.height;
            CGFloat buttonWidth = (frame.size.width - dividerWidth * (titles.count - 1)) / titles.count;
            
            // Initialize horizontal offset
            CGFloat horizontalOffset = 0;
            
            // Create and add buttons
            NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:titles.count];
            for (NSUInteger i = 0; i < titles.count; i++) {
                // Button
                UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(horizontalOffset, 0, buttonWidth, height)] autorelease];
                [button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
                if (highlightedTitles.count) {
                    [button setTitle:[highlightedTitles objectAtIndex:i] forState:UIControlStateHighlighted];
                }
                if (selectedTitles.count) {
                    [button setTitle:[selectedTitles objectAtIndex:i] forState:UIControlStateSelected];
                }
                [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [button addTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
                [button addTarget:self action:@selector(buttonTouchedOther:) forControlEvents:UIControlEventTouchUpOutside];
                [button addTarget:self action:@selector(buttonTouchedOther:) forControlEvents:UIControlEventTouchDragInside];
                [button addTarget:self action:@selector(buttonTouchedOther:) forControlEvents:UIControlEventTouchDragOutside];
                [buttons addObject:button];
                [self addSubview:button];
                horizontalOffset += buttonWidth;
                
                // Divider
                if (dividerImage && i != titles.count - 1) {
                    UIImageView *dividerImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(horizontalOffset, 0, dividerWidth, height)] autorelease];
                    dividerImageView.image = dividerImage;
                    [self addSubview:dividerImageView];
                    horizontalOffset += dividerWidth;
                }
            }
            self.buttons = buttons;
            [buttons release];
            
            // Initialize background views
            self.highlightedBackgroundImageView = [[UIImageView alloc] initWithFrame:[(UIButton *)[_buttons objectAtIndex:0] frame]];
            _highlightedBackgroundImageView.image = _highlightedBackgroundImage;
            _highlightedBackgroundImageView.hidden = YES;
            [self addSubview:_highlightedBackgroundImageView];
            
            self.selectedBackgroundImageView = [[UIImageView alloc] initWithFrame:[(UIButton *)[_buttons objectAtIndex:0] frame]];
            _selectedBackgroundImageView.image = _selectedBackgroundImage;
            [self addSubview:_selectedBackgroundImageView];
            [self sendSubviewToBack:_highlightedBackgroundImageView];
            [self sendSubviewToBack:_selectedBackgroundImageView];
            
            // Select the first button
            [self selectButton:[_buttons objectAtIndex:0]];
            
        } else { // When the titles is empty, return an empty view
            NSLog(@"Custom Segmented Control: Titles empty. ");
            return self;
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
    [_buttons release];
    [_titles release];
    [_highlightedTitles release];
    [_selectedTitles release];
    [_dividerImage release];
    [_highlightedBackgroundImage release];
    [_selectedBackgroundImage release];
    [_highlightedBackgroundImageView release];
    [_selectedBackgroundImageView release];
}

@end