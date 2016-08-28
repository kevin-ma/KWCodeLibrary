//
//  KWCodeCellView.m
//  KWCodeLibrary
//
//  Created by 凯文马 on 16/8/24.
//  Copyright © 2016年 kevin-meili-inc. All rights reserved.
//

#import "KWCodeCellView.h"
#import "KWCodeLibraryTextView.h"

@interface KWCodeCellView ()

@property (nonatomic,strong) KWCodeLibraryTextView *textView;

@end

@implementation KWCodeCellView

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (!_textView) {
        _textView = [[KWCodeLibraryTextView alloc] initWithFrame:CGRectZero];
        [self addSubview:_textView];
        
        _textView.backgroundColor = [NSColor clearColor];
        _textView.textColor = [NSColor greenColor];
        
        _textView.translatesAutoresizingMaskIntoConstraints = NO;

        NSLayoutConstraint *topCos = [NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5];
        NSLayoutConstraint *leftCos = [NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5];
        NSLayoutConstraint *rightCos = [NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:5];
        NSLayoutConstraint *bottomCos = [NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5];

        [self addConstraint:topCos];
        [self addConstraint:rightCos];
        [self addConstraint:leftCos];
        [self addConstraint:bottomCos];
    }
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    [self.textView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:_text]];
}


@end
