//
//  GlobalDataCache.h
//
//
//  Created by 唐志华 on 12-9-13.
//
//  内存级别缓存
//
//  这是是 "按需缓存" , 内部使用 "数据模型缓存" 实现.
//
//

#import <Foundation/Foundation.h>

// 用于外部 KVO 的, 属性名称(字符串格式).
#define kGlobalDataCacheForMemorySingletonProperty_privateAccountLogonNetRespondBean @"privateAccountLogonNetRespondBean"
#define kGlobalDataCacheForMemorySingletonProperty_bookCategoriesNetRespondBean      @"bookCategoriesNetRespondBean"

@class LogonNetRespondBean;
@class LocalBookList;
@class BookCategoriesNetRespondBean;

@interface GlobalDataCacheForMemorySingleton : NSObject {
  
}

// 用户第一次启动App
@property (nonatomic, assign) BOOL isFirstStartApp;
// 是否需要在app启动时, 显示 "初学者指南界面"
@property (nonatomic, assign, setter=setNeedShowBeginnerGuide:) BOOL isNeedShowBeginnerGuide;
// 是否需要自动登录的标志
@property (nonatomic, assign, setter=setNeedAutologin:) BOOL isNeedAutologin;




// 私有用户登录成功后, 服务器返回的信息(判断此对象是否为空, 来确定当前是否有企业账户处于登录状态)
@property (nonatomic, strong) LogonNetRespondBean *privateAccountLogonNetRespondBean;


// 用户最后一次登录成功时的用户名/密码(企业账户/公共账户 登录成功都会保存在这里)
@property (nonatomic, copy) NSString *usernameForLastSuccessfulLogon;
@property (nonatomic, copy) NSString *passwordForLastSuccessfulLogon;

// 本地缓存的数据的大小(字节)
@property (nonatomic, readonly) NSUInteger localCacheDataSize;


// 本地书籍列表
@property (nonatomic, strong) LocalBookList *localBookList;
// 书籍分类
@property (nonatomic, strong) BookCategoriesNetRespondBean *bookCategoriesNetRespondBean;

#pragma mark -
#pragma mark 单例
+ (GlobalDataCacheForMemorySingleton *) sharedInstance;
@end
