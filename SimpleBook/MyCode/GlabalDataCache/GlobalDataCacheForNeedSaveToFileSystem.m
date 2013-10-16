//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "GlobalDataCacheForNeedSaveToFileSystem.h"
#import "GlobalDataCacheForMemorySingleton.h"




#import "NSObject+Serialization.h"

#import "LocalCacheDataPathConstant.h"

#import "LocalBookList.h"





static NSString *const TAG = @"<GlobalDataCacheForNeedSaveToFileSystem>";











// 自动登录的标志
static NSString *const kLocalCacheDataName_AutoLoginMark                  = @"AutoLoginMark";

// 用户最后一次成功登录时的用户名
static NSString *const kLocalCacheDataName_UsernameForLastSuccessfulLogon = @"UsernameForLastSuccessfulLogon";
// 用户最后一次成功登录时的密码
static NSString *const kLocalCacheDataName_PasswordForLastSuccessfulLogon = @"PasswordForLastSuccessfulLogon";
// 用户是否是首次启动App
static NSString *const kLocalCacheDataName_FirstStartApp                  = @"FirstStartApp";
// 是否需要显示 初学者指南
static NSString *const kLocalCacheDataName_BeginnerGuide                  = @"BeginnerGuide";

// 本地书籍列表
static NSString *const kLocalCacheDataName_LocalBookList                  = @"LocalBookList";

@implementation GlobalDataCacheForNeedSaveToFileSystem

+(void) initialize {
  
  // 内存告警
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(saveMemoryCacheToDisk:)
                                               name:UIApplicationDidReceiveMemoryWarningNotification
                                             object:nil];
  // 应用进入后台
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(saveMemoryCacheToDisk:)
                                               name:UIApplicationDidEnterBackgroundNotification
                                             object:nil];
  // 应用退出
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(saveMemoryCacheToDisk:)
                                               name:UIApplicationWillTerminateNotification
                                             object:nil];
}

+(void) dealloc {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidReceiveMemoryWarningNotification
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidEnterBackgroundNotification
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationWillTerminateNotification
                                                object:nil];
  
}

#pragma mark -
#pragma mark 将内存中缓存的数据保存到文件系统中

+ (void)readUserLoginInfoToGlobalDataCacheForMemorySingleton {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  // 自动登录的标志
  id autoLoginMark = [userDefaults objectForKey:(NSString *)kLocalCacheDataName_AutoLoginMark];
  if (autoLoginMark == nil) {
    [userDefaults setBool:YES forKey:(NSString *)kLocalCacheDataName_AutoLoginMark];
  }
  BOOL autoLoginMarkBOOL = [userDefaults boolForKey:(NSString *)kLocalCacheDataName_AutoLoginMark];
  [[GlobalDataCacheForMemorySingleton sharedInstance] setNeedAutologin:autoLoginMarkBOOL];
  
	
	
  // 用户最后一次成功登录时的用户名
  NSString *usernameForLastSuccessfulLogon = [userDefaults stringForKey:(NSString *)kLocalCacheDataName_UsernameForLastSuccessfulLogon];
  [GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon = usernameForLastSuccessfulLogon;
  
  // 用户最后一次成功登录时的密码
  NSString *passwordForLastSuccessfulLogon = [userDefaults stringForKey:(NSString *)kLocalCacheDataName_PasswordForLastSuccessfulLogon];
  [GlobalDataCacheForMemorySingleton sharedInstance].passwordForLastSuccessfulLogon = passwordForLastSuccessfulLogon;
  
}

+ (void)readAppConfigInfoToGlobalDataCacheForMemorySingleton {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
	// 用户是否是第一次启动App
	id isFirstStartAppTest = [userDefaults objectForKey:kLocalCacheDataName_FirstStartApp];
  if (nil == isFirstStartAppTest) {
    [userDefaults setBool:YES forKey:kLocalCacheDataName_FirstStartApp];
  }
  BOOL isFirstStartApp = [userDefaults boolForKey:kLocalCacheDataName_FirstStartApp];
  [GlobalDataCacheForMemorySingleton sharedInstance].isFirstStartApp = isFirstStartApp;
	
  // 是否需要在启动后显示初学者指南界面
  id isNeedShowBeginnerGuideTest = [userDefaults objectForKey:kLocalCacheDataName_BeginnerGuide];
  if (nil == isNeedShowBeginnerGuideTest) {
    [userDefaults setBool:YES forKey:kLocalCacheDataName_BeginnerGuide];
  }
  BOOL isNeedShowBeginnerGuide = [userDefaults boolForKey:kLocalCacheDataName_BeginnerGuide];
  [GlobalDataCacheForMemorySingleton sharedInstance].isNeedShowBeginnerGuide = isNeedShowBeginnerGuide;
	
  
  
  
}

+ (void)readLocalBookListToGlobalDataCacheForMemorySingleton {
  LocalBookList *object = [LocalBookList deserializeObjectFromFileWithFileName:kLocalCacheDataName_LocalBookList directoryPath:[LocalCacheDataPathConstant importantDataCachePath]];
  if (object == nil) {
    object = [[LocalBookList alloc] init];
  }
  
  [[GlobalDataCacheForMemorySingleton sharedInstance] setLocalBookList:object];
}


#pragma mark -
#pragma mark 从文件系统中读取缓存的数据到内存中

+ (void)writeUserLoginInfoToFileSystem {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  // 自动登录的标志
  BOOL autoLoginMark = [[GlobalDataCacheForMemorySingleton sharedInstance] isNeedAutologin];
  [userDefaults setBool:autoLoginMark forKey:(NSString *)kLocalCacheDataName_AutoLoginMark];
  
  
	
  // 用户最后一次成功登录时的用户名
  NSString *usernameForLastSuccessfulLogon = [[GlobalDataCacheForMemorySingleton sharedInstance] usernameForLastSuccessfulLogon];
  if (![NSString isEmpty:usernameForLastSuccessfulLogon]) {
    [userDefaults setObject:usernameForLastSuccessfulLogon forKey:(NSString *)kLocalCacheDataName_UsernameForLastSuccessfulLogon];
  }
  
  // 用户最后一次成功登录时的密码
  NSString *passwordForLastSuccessfulLogon = [[GlobalDataCacheForMemorySingleton sharedInstance] passwordForLastSuccessfulLogon];
  if (![NSString isEmpty:passwordForLastSuccessfulLogon]) {
    [userDefaults setObject:passwordForLastSuccessfulLogon forKey:(NSString *)kLocalCacheDataName_PasswordForLastSuccessfulLogon];
  }
  
}

+ (void)writeAppConfigInfoToFileSystem {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
	// 是否需要显示用户第一次登录时的帮助界面的标志
  BOOL isFirstStartApp = [GlobalDataCacheForMemorySingleton sharedInstance].isFirstStartApp;
  [userDefaults setBool:isFirstStartApp forKey:kLocalCacheDataName_FirstStartApp];
	
  // 是否需要显示用户第一次登录时的帮助界面的标志
  BOOL isNeedShowBeginnerGuide = [GlobalDataCacheForMemorySingleton sharedInstance].isNeedShowBeginnerGuide;
  [userDefaults setBool:isNeedShowBeginnerGuide forKey:kLocalCacheDataName_BeginnerGuide];
	
  
}

+ (void)writeLocalBookListToFileSystem {
  LocalBookList *object = [[GlobalDataCacheForMemorySingleton sharedInstance] localBookList];
  [object serializeObjectToFileWithFileName:kLocalCacheDataName_LocalBookList directoryPath:[LocalCacheDataPathConstant importantDataCachePath]];
}

#pragma mark -
#pragma mark 将内存级别缓存的数据固化到硬盘中
+ (void)saveMemoryCacheToDisk:(NSNotification *)notification {
  NSLog(@"saveMemoryCacheToDisk:%@", notification);
  
  [GlobalDataCacheForNeedSaveToFileSystem writeUserLoginInfoToFileSystem];
  [GlobalDataCacheForNeedSaveToFileSystem writeAppConfigInfoToFileSystem];
  [GlobalDataCacheForNeedSaveToFileSystem writeLocalBookListToFileSystem];
}

@end
