#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void(^BtnBlock)(UIButton * button);

@interface BlockButton : UIButton

@property (nonatomic, copy) BtnBlock block;

@end
