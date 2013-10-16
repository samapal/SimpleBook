//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "ToolsFunctionForThisProgect.h"

#import "NSDictionary+SafeValue.h"






#import "MacroConstantForThisProject.h"


#import "SimpleCookieSingleton.h"

#import "VersionNetRespondBean.h"

#import "LogonNetRespondBean.h"



@implementation ToolsFunctionForThisProgect

#pragma mark
#pragma mark 不能使用默认的init方法初始化对象, 而必须使用当前类特定的 "初始化方法" 初始化所有参数
- (id) init {
  RNAssert(NO, @"Can not use the default init method!");
  
  return nil;
}

/**
 * 记录用户登录成功后的重要信息
 *
 * @param logonNetRespondBean
 * @param usernameForLastSuccessfulLogon
 * @param passwordForLastSuccessfulLogon
 */
+(void)noteLogonSuccessfulInfoWithLogonNetRespondBean:(LogonNetRespondBean *)logonNetRespondBean
									usernameForLastSuccessfulLogon:(NSString *)usernameForLastSuccessfulLogon
									passwordForLastSuccessfulLogon:(NSString *)passwordForLastSuccessfulLogon {
  
  if (logonNetRespondBean == nil) {
    RNAssert(NO, @"LogonNetRespondBean is null !");
    return;
  }
  
  if ([NSString isEmpty:usernameForLastSuccessfulLogon] || [NSString isEmpty:passwordForLastSuccessfulLogon]) {
    RNAssert(NO, @"username or password is empty ! ");
    return;
  }
  
  NSLog(@"%@ LogonNetRespondBean --->", logonNetRespondBean);
  NSLog(@"%@ username --->", usernameForLastSuccessfulLogon);
  NSLog(@"%@ password --->", passwordForLastSuccessfulLogon);
  
  // 设置Cookie
  //[[SimpleCookieSingleton sharedInstance] setObject:logonNetRespondBean.sessionid forKey:@"sessionid"];
  
  // 保用用户登录成功的信息
  [GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean = logonNetRespondBean;
  
  
	
  // 保留用户最后一次登录成功时的 用户名
  [GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon = usernameForLastSuccessfulLogon;
  
  // 保留用户最后一次登录成功时的 密码
  [GlobalDataCacheForMemorySingleton sharedInstance].passwordForLastSuccessfulLogon = passwordForLastSuccessfulLogon;
}

/**
 * 清空登录相关信息
 */
+(void)clearLogonInfo {
  [[SimpleCookieSingleton sharedInstance] removeObjectForKey:@"sessionid"];
  
  [GlobalDataCacheForMemorySingleton sharedInstance].LogonNetRespondBean = nil;
}



// 同步网络请求App最新版本信息(一定要在子线程中调用此方法, 因为使用sendSynchronousRequest发起的网络请求), 并且返回 VersionNetRespondBean
// 今日书院(我们的app id) : 722737021
// 蚂蚁短租(用于测试) : 494520120
#define APP_URL @"http://itunes.apple.com/lookup?id=722737021"
+(VersionNetRespondBean *)synchronousRequestAppNewVersionAndReturnVersionBean {
  VersionNetRespondBean *versionBean = nil;
  
  do {
    
    NSString *URL = APP_URL;
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:URL]];
    [urlRequest setHTTPMethod:@"POST"];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    // 同步请求网络数据
    NSData *recervedData
    = [NSURLConnection sendSynchronousRequest:urlRequest
                            returningResponse:&urlResponse
                                        error:&error];
    if (![recervedData isKindOfClass:[NSData class]]) {
      break;
    }
    if (recervedData.length <= 0) {
      break;
    }
    urlRequest = nil;
    
    NSDictionary *jsonRootNSDictionary = [NSJSONSerialization JSONObjectWithData:recervedData options:0 error:&error];
    
    if (![jsonRootNSDictionary isKindOfClass:[NSDictionary class]]) {
      break;
    }
    //NSString *jsonString = [[NSString alloc] initWithData:recervedData encoding:NSUTF8StringEncoding];
    
    NSArray *infoArray = [jsonRootNSDictionary objectForKey:@"results"];
    if ([infoArray count] > 0) {
      NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
      NSString *lastVersion = [releaseInfo objectForKey:@"version"];
      NSString *trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
      NSString *fileSizeBytes = [releaseInfo objectForKey:@"fileSizeBytes"];
      NSString *releaseNotes = [releaseInfo objectForKey:@"releaseNotes"];
      versionBean = [VersionNetRespondBean versionNetRespondBeanWithNewVersion:lastVersion
                                                                   andFileSize:fileSizeBytes
                                                              andUpdateContent:releaseNotes
                                                            andDownloadAddress:trackViewUrl];
    }
  } while (NO);
  
  return versionBean;
}

/*
 Xcode4有两个版本号，一个是Version,另一个是Build,对应于Info.plist的字段名分别为CFBundleShortVersionString,CFBundleVersion。
 友盟SDK为了兼容Xcode3的工程，默认取的是Build号，如果需要取Xcode4的Version，可以使用下面的方法。
 
 NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
 */
// 使用 Info.plist 中的 "Bundle version" 来保存本地App Version
+(NSString *)localAppVersion {
  NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
  NSString *appVersion = [infoDic objectForKey:@"CFBundleVersion"];
  return appVersion;
}

// 加载内部错误时的UI(Activity之间传递的必须参数无效), 并且隐藏 bodyLayout
+(void)loadIncomingIntentValidUIWithSuperView:(UIView *)superView andHideBodyLayout:(UIView *)bodyLayout {
  if (![superView isKindOfClass:[UIView class]]) {
    // 入参错误
    return;
  }
  
	/*
	 PreloadingUIToolBar *preloadingUIToolBar = [PreloadingUIToolBar preloadingUIToolBar];
	 [preloadingUIToolBar setHintInfo:kIncomingIntentValid];
	 [preloadingUIToolBar showInView:superView];
	 
	 // 外部传入的数据非法, 就隐藏掉 bodyLayout
	 if ([bodyLayout isKindOfClass:[UIView class]]) {
	 bodyLayout.hidden = YES;
	 }
	 */
}


// 将 "秒" 格式化成 "天小时分钟秒", 例如 : 入参是 118269(秒), 返回 "1天8时51分9秒"
+(NSString *)formatSecondToDayHourMinuteSecond:(NSNumber *)secondSource {
	if (![secondSource isKindOfClass:[NSNumber class]] || [secondSource doubleValue] <= 0.0f) {
    return @"0秒";
  }
  
	double timeOfSecond = [secondSource doubleValue];
	NSInteger day = timeOfSecond / 86400;
	timeOfSecond -= 86400*day;
	NSInteger hour = timeOfSecond / 3600;
	timeOfSecond -= 3600*hour;
	NSInteger minute = timeOfSecond / 60;
	timeOfSecond -= 60*minute;
	NSInteger second = timeOfSecond;
	
  
	NSMutableString *dateString = [NSMutableString string];
	if (day > 0) {
		[dateString appendFormat:@"%d天", day];
	}
	if (hour > 0) {
		[dateString appendFormat:@"%d时", hour];
	}
	if (minute > 0) {
		[dateString appendFormat:@"%d分", minute];
	}
	[dateString appendFormat:@"%d秒", second];
	
	return dateString;
}

static NSString *userAgentString = nil;
+(NSString *)getUserAgent {
  if ([NSString isEmpty:userAgentString]) {
    NSString *bundleName = @"DreamBook";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *model = [[UIDevice currentDevice] model];
    NSArray *aOsVersions = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    NSString *modelVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger iOsVersionMajor = [[aOsVersions objectAtIndex:0] intValue];
    NSInteger iOsVersionMinor1 = [[aOsVersions objectAtIndex:1] intValue];
    userAgentString = [NSString stringWithFormat:@"%@_%@_%@%@_iOS%d.%d", bundleName, version, model, modelVersion, iOsVersionMajor, iOsVersionMinor1];
  }
  
  return  userAgentString;
}

// 格式化 书籍zip资源包大小的字符串显示, 服务器传过来的是 byte 为单位的, 我们要进行格式化为 B KB MB 为单位的字符串
+(NSString *)formatBookZipResSizeString:(NSString *)bookZipResSize {
  if ([NSString isEmpty:bookZipResSize]) {
    RNAssert(NO, @"入参异常 bookZipResSize 为空.");
    return nil;
  }
  
  long long longLongValue = [bookZipResSize longLongValue];
  if (longLongValue <= 0) {
    return @"0 B";
  }
  
  if (longLongValue >= 1024 * 1024) {
    return [NSString stringWithFormat:@"%.2f M", longLongValue / (float)(1024 * 1024)];
  } else if (longLongValue >= 1024) {
    return [NSString stringWithFormat:@"%.2f K", longLongValue / (float)(1024)];
  } else {
    return [NSString stringWithFormat:@"%.2f B", (float)longLongValue];
  }
    
}
@end
