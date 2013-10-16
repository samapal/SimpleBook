//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>

// 序列化对象到文件
@interface NSObject (Serialization)


-(void)serializeObjectToFileWithFileName:(NSString *)fileName directoryPath:(NSString *)directoryPath;
+(id)deserializeObjectFromFileWithFileName:(NSString *)fileName directoryPath:(NSString *)directoryPath;
@end
