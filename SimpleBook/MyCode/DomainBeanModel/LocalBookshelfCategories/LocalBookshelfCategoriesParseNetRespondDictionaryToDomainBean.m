//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import "LocalBookshelfCategoriesParseNetRespondDictionaryToDomainBean.h"

#import "LocalBookshelfCategoriesDatabaseFieldsConstant.h"
#import "LocalBookshelfCategoriesNetRespondBean.h"

#import "NSString+isEmpty.h"
#import "NSDictionary+SafeValue.h"
#import "NSDictionary+Helper.h"

#import "TBXML.h"
#import "TBXML+NSDictionary.h"

static const NSString *const TAG = @"<LocalBookshelfCategoriesParseNetRespondStringToDomainBean>";

@implementation LocalBookshelfCategoriesParseNetRespondDictionaryToDomainBean
- (id) init {
	
	if ((self = [super init])) {
		PRPLog(@"init %@ [0x%x]", TAG, [self hash]);
    
	}
	
	return self;
}

#pragma mark 实现 IParseNetRespondStringToDomainBean 接口
- (id) parseNetRespondDictionaryToDomainBean:(in NSDictionary *) netRespondDictionary {
  do {
    if (![netRespondDictionary isKindOfClass:[NSDictionary class]]) {
      RNAssert(NO, @"入参 netRespondDictionary 类型不正确.");
      break;
    }
   	
    return [[LocalBookshelfCategoriesNetRespondBean alloc] initWithDictionary:netRespondDictionary];
  } while (NO);
  
  return nil;
}

@end