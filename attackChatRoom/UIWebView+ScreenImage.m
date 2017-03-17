#import "WebView+ScreenImage.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIWebView (ScreenImage)

- (UIImage *)getImage {
    CGFloat scale = [UIScreen mainScreen].scale;  
      
    CGSize boundsSize = self.bounds.size;  
    CGFloat boundsWidth = boundsSize.width;  
    CGFloat boundsHeight = boundsSize.height;  
      
    CGSize contentSize = self.scrollView.contentSize;  
    CGFloat contentHeight = contentSize.height;  
    
    CGPoint offset = self.scrollView.contentOffset;  

    
    [self.scrollView setContentOffset:CGPointMake(0, 0)];  
      
    NSMutableArray *images = [NSMutableArray array];  
    while (contentHeight > 0) {  
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, 0.0);  
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];  
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();  
        UIGraphicsEndImageContext();  
        [images addObject:image];  
          
        CGFloat offsetY = self.scrollView.contentOffset.y;  
        [self.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];  
        contentHeight -= boundsHeight;  
    }  
      
    [self.scrollView setContentOffset:offset];  
    
    // NSLog(@"MYHOOK images: %lu nSize: %f,%f Ssize: %f,%f", [images count], boundsSize.width, boundsSize.height, contentSize.width, contentSize.height);
      
    CGSize imageSize = CGSizeMake(contentSize.width * scale,  
                                  contentSize.height * scale);  
    UIGraphicsBeginImageContext(imageSize);  
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {  
        [image drawInRect:CGRectMake(0,  
                                     scale * boundsHeight * idx,  
                                     scale * boundsWidth,  
                                     scale * boundsHeight)];  
    }];  
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    return fullImage;
    // 
    // NSData *pngImg;
    // CGFloat max, scale = 1.0;
    // CGSize viewSize = [self bounds].size;
    // 
    // // 获取全屏的Size，包含可见部分和不可见部分(滚动部分)
    // CGSize size = [self sizeThatFits:CGSizeZero];
    // NSLog(@"MYHOOK webview size: %@", size);
    // max = (viewSize.width > viewSize.height) ? viewSize.width : viewSize.height;
    // if( max > 960 )
    // {
    //     scale = 960/max;
    // }
    // 
    // UIGraphicsBeginImageContextWithOptions(size,YES,scale);
    // 
    // // 设置view成全部展开效果
    // [self setFrame: CGRectMake(0, 0, size.width, self.scrollView.contentSize.height)];
    // 
    // CGContextRef context = UIGraphicsGetCurrentContext();
    // [self.layer renderInContext:context];
    // pngImg = UIImagePNGRepresentation( UIGraphicsGetImageFromCurrentImageContext() );
    // 
    // UIGraphicsEndImageContext();
    // return [UIImage imageWithData:pngImg];
}

@end