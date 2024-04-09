//
//  LLZSharePhoneHandler.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import "LLZSharePhoneHandler.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "UIViewController+Utils.h"

@interface LLZSharePhoneHandler ()<CNContactPickerDelegate>

@property (nonatomic, copy) ShareSuccessBlock successBlock;
@property (nonatomic, copy) ShareCancelBlock cancelBlock;
@property (nonatomic, copy) ShareErrorBlock errorBlock;

@end

@implementation LLZSharePhoneHandler
@synthesize shareChannelType = _shareChannelType;
@synthesize shareTitle = _shareTitle;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shareChannelType = LLZShareChannelTypePhone;
        _shareTitle = PhoneShareChannelTitle;
    }
    return self;
}

- (void)shareWithObject:(nullable LLZShareObject *)object
     withViewController:(nullable UIViewController*)viewController
       withSuccessBlock:(ShareSuccessBlock)successHandler
        withCancelBlock:(ShareCancelBlock)cancelHandler
         withErrorBlock:(ShareErrorBlock)errorHandler {
    [self shareInfoReset];
    self.successBlock = successHandler;
    self.cancelBlock = cancelHandler;
    self.errorBlock = errorHandler;
    CNContactPickerViewController *contactVC = [[CNContactPickerViewController alloc] init];
    contactVC.delegate = self;
    [[UIViewController currentViewController] presentViewController:contactVC animated:YES completion:nil];
}


#pragma mark - CNContactPickerDelegate
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    if(self.cancelBlock){
        self.cancelBlock(self.shareTitle, @"用户点击了取消");
    }
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSString *nameStr;
    NSString *curPhoneString;
    NSArray *phoneNumbers = contact.phoneNumbers;
    for (CNLabeledValue *labelValue in phoneNumbers) {
        //遍历一个人名下的多个电话号码
        CNPhoneNumber *phoneNumber = labelValue.value;
        NSString *phoneString = phoneNumber.stringValue;
        //去掉电话中的特殊字符
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@"+86" withString:@""];
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@")" withString:@""];
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
        phoneString = [phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSLog(@"姓名=%@, 电话号码是=%@", nameStr, phoneString);
        // 遍历到一个即去拨打电话
        if (phoneString.length) {
            curPhoneString = phoneString;
            break;
        }
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", curPhoneString]];
    if ([[UIApplication sharedApplication] canOpenURL:url] && curPhoneString && curPhoneString.length > 0) {
        [self makePhoneCall:url];
        if(self.successBlock){
            self.successBlock(self.shareTitle, @"电话拨打成功");
        }
    } else {
        NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"此电话无法拨打, 电话:%@", curPhoneString]}];
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
    }
}

- (void)makePhoneCall: (NSURL *)url {
    [[UIApplication sharedApplication] openURL:url
                                       options:@{}
                             completionHandler:nil];
}

- (void)shareInfoReset {
    self.successBlock = nil;
    self.errorBlock = nil;
    self.cancelBlock = nil;
}

- (SupportShareObjectOptions) supportSharingObjectOptions {
    return SupportShareObjectMessage | SupportShareObjectImage | SupportShareObjectVideo | SupportShareObjectWebpage | SupportShareObjectMiniApp;
}

@end
