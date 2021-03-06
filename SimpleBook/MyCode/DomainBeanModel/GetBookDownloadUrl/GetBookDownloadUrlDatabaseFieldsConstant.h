//
//  DreamBook
//
//  Created by 唐志华 on 13-9-18.
//
//

#ifndef DreamBook_GetBookDownloadUrlDatabaseFieldsConstant_h
#define DreamBook_GetBookDownloadUrlDatabaseFieldsConstant_h

/************      RequestBean       *************/

// 要下载的书籍ID 必填
#define k_GetBookDownloadUrl_RequestKey_contentId       @"contentId"
// 跟要下载的书籍绑定的账号, 这里是服务器端做的安全策略, 要检测跟目标书籍绑定的账号是否有下载权限.
#define k_GetBookDownloadUrl_RequestKey_username        @"user_id"
#define k_GetBookDownloadUrl_RequestKey_password        @"user_password"




/************      RespondBean       *************/

//
#define k_GetBookDownloadUrl_RespondKey_content         @"content"
// 校验
#define k_GetBookDownloadUrl_RespondKey_validate        @"validate"
//
#define k_GetBookDownloadUrl_RespondKey_url             @"url"


#endif
