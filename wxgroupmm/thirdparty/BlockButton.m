#import "BlockButton.h"

@interface BlockButton ()

@end


@implementation BlockButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)doAction:(UIButton *)button {

    self.block(button);
}

@end