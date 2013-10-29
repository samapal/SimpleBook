//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#import <Foundation/Foundation.h>



/* ------------   引擎设计说明
 
 
 这个引擎的设计想法是, 想最低限度的降低 "控制层 Controller/Activity" 的开发难度,
 在控制层如果想和服务器端的一个接口进行通信, 只需要知道这个接口的两个业务Bean即可,
 一个是 NetRequestBean (网络请求业务Bean) , 一个是 NetRespondBean (网络响应业务Bean),
 
 这样就可以隐藏很多客户端和服务器端通信的协议细节,
 如 数据交换协议(XML,JSON), 数据加密(AES) 等,
 这样, 当这些细节发生变化时, 控制层代码将不受影响.
 
 另外就是, 不想在控制层直接使用 MKNetworkKit 这样具体的网络引擎,
 因为这样会增加控制层的开发难度, 控制层应该专注于 "业务逻辑和UI界面" 的处理,
 
 
 */

// 空闲状态下的网络索引
#define NETWORK_REQUEST_ID_OF_IDLE (-2012)

@class NetRequestErrorBean;



typedef void (^DomainNetRespondHandleInUIThreadSuccessedBlock)(id respondDomainBean);
typedef void (^DomainNetRespondHandleInUIThreadFailedBlock)(NetRequestErrorBean *error);





@interface DomainBeanNetworkEngineSingleton : NSObject {
  
}


+ (DomainBeanNetworkEngineSingleton *) sharedInstance;

- (void) requestDomainProtocolWithRequestDomainBean:(in id) netRequestDomainBean
                        currentNetRequestIndexToOut:(out NSInteger *) pCurrentNetRequestIndexToOut
                                     successedBlock:(DomainNetRespondHandleInUIThreadSuccessedBlock) successedBlock
                                        failedBlock:(DomainNetRespondHandleInUIThreadFailedBlock) failedBlock;

/**
 * 取消一个 "网络请求索引" 所对应的 "网络请求命令"
 *
 * @param netRequestIndex : 网络请求命令对应的索引
 */
- (void) cancelNetRequestByRequestIndex:(out NSInteger *) pNetRequestIndex;





@end
