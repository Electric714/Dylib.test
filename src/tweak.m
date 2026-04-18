#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface FBButtonTarget : NSObject
- (void)handleTap;
@end

@implementation FBButtonTarget
- (void)handleTap {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive || ![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    break;
                }
            }
            if (keyWindow) {
                break;
            }
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        keyWindow = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
    }

    if (!keyWindow) {
        return;
    }

    UIViewController *rootVC = keyWindow.rootViewController;
    if (!rootVC) {
        return;
    }

    UIViewController *presenter = rootVC;
    while (presenter.presentedViewController) {
        presenter = presenter.presentedViewController;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Injected"
                                                                   message:@"You pressed the bubble"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [presenter presentViewController:alert animated:YES completion:nil];
}
@end

__attribute__((constructor))
static void floating_bubble_inject(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState != UISceneActivationStateForegroundActive || ![scene isKindOfClass:[UIWindowScene class]]) {
                    continue;
                }
                for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                if (keyWindow) {
                    break;
                }
            }
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            keyWindow = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
        }

        if (!keyWindow) {
            return;
        }

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(CGRectGetWidth(keyWindow.bounds) - 80.0, CGRectGetHeight(keyWindow.bounds) - 180.0, 60.0, 60.0);
        button.layer.cornerRadius = 30.0;
        button.backgroundColor = [UIColor systemBlueColor];
        [button setTitle:@"+" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;

        FBButtonTarget *target = [FBButtonTarget new];
        objc_setAssociatedObject(button, @selector(handleTap), target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [button addTarget:target action:@selector(handleTap) forControlEvents:UIControlEventTouchUpInside];

        [keyWindow addSubview:button];
    });
}
