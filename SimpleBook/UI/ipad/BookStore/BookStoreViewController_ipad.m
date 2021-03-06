//
//  DreamBook
//
//  Created by 唐志华 on 13-9-26.
//
//

#import "BookStoreViewController_ipad.h"

#import "StoreManager.h"

//#import "EAGLView.h"
//#import "FlipsideViewController.h"
#import "AppDelegate.h"

//
#import "MKNetworkKit.h"

#import "GlobalDataCacheForMemorySingleton.h"
#import "BookCategoriesNetRespondBean.h"
#import "GetBookDownloadUrlNetRequestBean.h"
#import "GetBookDownloadUrlNetRespondBean.h"

#import "BookInfo.h"
#import "LocalBook.h"
#import "LocalBookList.h"

#import "BookListInBookstoresNetRequestBean.h"
#import "BookListInBookstoresNetRespondBean.h"

#import "LogonNetRespondBean.h"

#import "BookStoreTableCell_ipad.h"


#import "BookSearchNetRequestBean.h"

@interface BookStoreViewController_ipad () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *bookTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewFooter;
@property (weak, nonatomic) IBOutlet UIButton    *refurbishButton;
@property (weak, nonatomic) IBOutlet UIView      *headerView;

// 书城图书列表(完成本地图书列表和从服务器新获取的图书列表进行了数据同步)
@property (nonatomic, strong) LocalBookList *bookList;

// 最后的搜索条件
@property (nonatomic, copy) NSString *latestSearchCriteria;

// 书籍列表 - cell 对应的 nib
@property (nonatomic, strong) UINib *bookListTableCellNib;

// 保存 "书籍内容" 的 View
//@property (nonatomic, strong) EAGLView *eaglView;

// 标识当前界面是 "公共账户" 还是企业账户, 根据不同的账号, UI会有所变化
@property (nonatomic, assign) BOOL isPublicAccount;

@end


@implementation BookStoreViewController_ipad {
  // 获取书城中的图书列表 网络请求
  NSInteger _netRequestIndexForGetBookListInBookstores;
  // 获取要下载的书籍的URL 网络请求
  NSInteger _netRequestIndexForGetBookDownloadUrl;
}

-(UINib *)bookListTableCellNib {
  if (_bookListTableCellNib == nil) {
    _bookListTableCellNib = [BookStoreTableCell_ipad nib];
  }
  return _bookListTableCellNib;
}

-(LocalBookList *)bookList {
  if (_bookList == nil) {
    _bookList = [[LocalBookList alloc] init];
  }
  
  return _bookList;
}
#pragma mark -
#pragma mark 私有方法
-(void)clearSearchCriteria {
  self.searchTextField.text = @"";
  self.latestSearchCriteria = @"";
}

-(void)openBookWithBookSaveDirPath:(NSString *)bookSaveDirPath {
  //  self.eaglView = [[EAGLView alloc] init];
  //
  //  [self.eaglView loadContents:bookSaveDirPath];
  //
  //  [AppDelegate sharedAppDelegate].orientation = [self.eaglView GetOrientation];
  //
  //  FlipsideViewController *flipsideView = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
  //  flipsideView.delegate = self;
  //  flipsideView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  //
  //  if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
  //    [self presentViewController:flipsideView animated:YES completion:NULL];
  //  } else {
  //    [self presentModalViewController:flipsideView animated:YES];
  //  }
  //
  //  [flipsideView.glView loadContents:bookSaveDirPath];
  //  [flipsideView.glView startAnimation];
  //
  //  [flipsideView reloadInputViews];
  //  flipsideView = nil;
  
}

#pragma mark -
#pragma mark Controller 生命周期
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    
    // 注册付费流程的监听消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTransactionSucceededNotification:)
                                                 name:kInAppPurchaseManagerTransactionSucceededNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTransactionFailedNotification:)
                                                 name:kInAppPurchaseManagerTransactionFailedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTransactionCanceledNotification:)
                                                 name:kInAppPurchaseManagerTransactionCanceledNotification
                                               object:nil];
    
    //
    _netRequestIndexForGetBookListInBookstores = NETWORK_REQUEST_ID_OF_IDLE;
    _netRequestIndexForGetBookDownloadUrl = NETWORK_REQUEST_ID_OF_IDLE;
    
    // 先同步下 "搜索输入框控件" 和 "最后的搜索条件", 都设为 @""
    [self clearSearchCriteria];
  }
  return self;
}

-(void)dealloc {
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 判断当前界面是否是 "公共账号"
  self.isPublicAccount = [[GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon isEqualToString:PUBLIC_USERNAME] ;
  
  // 对iOS7以下版本来标题更换图片，重新布局
  if (!IS_IOS7) {
    CGRect frame = self.headerView.frame;
    frame.size.height -= 20.0f;
    self.headerView.frame = frame;
    
    frame = self.imgviewHeader.frame;
    frame.size.height -= 20.0f;
    self.imgviewHeader.frame = frame;
    
    frame = self.bookTableView.frame;
    frame.size.height += 20.0f;
    frame.origin.y -= 20.0f;
    self.bookTableView.frame = frame;
  }
  
  // 请求书城书籍列表
  [self requestBookListInBookstores];
}


- (void)viewDidUnload NS_DEPRECATED_IOS(3_0,6_0) {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // 设置Header图片
  NSString *imageNameOfViewHeader = nil;
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    // 竖屏
    imageNameOfViewHeader = self.isPublicAccount ? @"d_jrsy.png" : @"d_qysy.png";
    [self.imgviewFooter setImage:[UIImage imageNamed:@"ddh.png"]];
    //对iOS7以下版本来标题更换图片
    if (!IS_IOS7) {
      imageNameOfViewHeader = self.isPublicAccount ? @"d_jrsy_6" : @"d_qysy_6";
    }
  } else {
    // 横屏
    imageNameOfViewHeader = self.isPublicAccount ? @"d_jrsy_H.png" : @"d_qysy_H.png";
    [self.imgviewFooter setImage:[UIImage imageNamed:@"ddh.png"]];
    //对iOS7以下版本来标题更换图片
    if (!IS_IOS7) {
      imageNameOfViewHeader = self.isPublicAccount ? @"d_jrsy_6_H.png" : @"d_qysy_6_H.png";
    }
  }
  [self.imgviewHeader setImage:[UIImage imageNamed:imageNameOfViewHeader]];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  // 注销 消息监听
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:&_netRequestIndexForGetBookDownloadUrl];
  [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:&_netRequestIndexForGetBookListInBookstores];
  
  // 释放table view cell 注册的KVO
  [self removeAllObserversForTableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

// New Autorotation support.
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0) {
  NSLog(@"shouldAutorotate");
  
  //画面回転を許可する
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0) {
  return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration; {
  NSLog(@"willRotateToInterfaceOrientation ifOrientation=%d", toInterfaceOrientation);
  
  [_bookTableView reloadData];
  
  NSString *imageNameOfViewHeader = nil;
  if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
    // 竖屏
    imageNameOfViewHeader = self.isPublicAccount ? @"d_jrsy.png" : @"d_qysy.png";
    [self.imgviewFooter setImage:[UIImage imageNamed:@"ddh.png"]];
    //对iOS7以下版本来标题更换图片
    if (!IS_IOS7) {
      imageNameOfViewHeader = self.isPublicAccount ? @"d_jrsy_6" : @"d_qysy_6";
    }
  } else {
    // 横屏
    imageNameOfViewHeader = self.isPublicAccount ? @"d_jrsy_H.png" : @"d_qysy_H.png";
    [self.imgviewFooter setImage:[UIImage imageNamed:@"ddh.png"]];
    //对iOS7以下版本来标题更换图片
    if (!IS_IOS7) {
      imageNameOfViewHeader = self.isPublicAccount ? @"d_jrsy_6_H.png" : @"d_qysy_6_H.png";
    }
  }
  [self.imgviewHeader setImage:[UIImage imageNamed:imageNameOfViewHeader]];
  
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
  // ios6以降 viewDidUnloadがCALLされない。
  if([self isViewLoaded] && self.view.window == nil) {
    self.view = nil;
  }
}

#pragma mark -
#pragma mark UITextFieldDelegate 代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  [self searchButtonOnClickListener:nil];
  return YES;
}

// テキストフィールドをクリア
-(BOOL)textFieldShouldClear:(UITextField*)textField {
  [self clearSearchCriteria];
  
  [_bookTableView reloadData];
  return YES;
}

#pragma mark -
#pragma mark Button IBAction
// "返回 按钮"
-(IBAction) backButtonOnClickListener:(UIButton *)sender{
  // 自身のビューを削除してhomeに戻る
  // 子でdismissした場合、親にforwardされる。
  [self dismissViewControllerAnimated:YES completion:nil];
}

// "刷新 按钮"
-(IBAction) refreshButtonOnClickListener:(UIButton *)sender{
  
  // ネットワークエラー
  NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
  if(NotReachable == networkStatus){
    
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error")
                                                         message:NSLocalizedString(@"Network is not available", @"Network is not available")
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [alertView show];
    return;
  }
  
  
  
  [self requestBookListInBookstores];
  if (_netRequestIndexForGetBookListInBookstores != NETWORK_REQUEST_ID_OF_IDLE) {
    // 发起网络请求成功
    
    //
    [self clearSearchCriteria];
    
    // 为了防止用户快速点击 "刷新按钮", 暂时禁用, 当本次网络请求返回时, 在解禁.
    self.refurbishButton.enabled = NO;
  }
}

// "搜索 按钮"
-(IBAction) searchButtonOnClickListener:(UIButton *)sender{
  if ([NSString isEmpty:self.searchTextField.text] && [NSString isEmpty:self.latestSearchCriteria]) {
    // 搜索条件没有变化
    return;
  }
  if ([self.searchTextField.text isEqualToString:self.latestSearchCriteria]) {
    // 搜索条件没有变化
    return;
  }
  
  // 更新最新的搜索条件
  self.latestSearchCriteria = self.searchTextField.text;
  
  
  /*
   // 测试搜索接口
   BookSearchNetRequestBean *bookSearchNetRequestBean = [[BookSearchNetRequestBean alloc] init];
   bookSearchNetRequestBean.search = self.latestSearchCriteria;
   [[DomainBeanNetworkEngineSingleton sharedInstance] requestDomainProtocolWithRequestDomainBean:bookSearchNetRequestBean currentNetRequestIndexToOut:&_netRequestIndexForGetBookDownloadUrl successedBlock:^(id respondDomainBean) {
   
   
   } failedBlock:^(NetRequestErrorBean *error) {
   
   }];
   */
  // 重刷界面
  [_bookTableView reloadData];
}



#pragma mark -
#pragma mark - 网络相关方法群

// ダウンロードのリスト一覧を取得する
-(void)requestBookListInBookstores {
  
  NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
  if(NotReachable == networkStatus){
    
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error")
                                                         message:NSLocalizedString(@"Network is not available", @"Network is not available")
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [alertView show];
    return;
  }
  
  BookListInBookstoresNetRequestBean *netRequestBean = [[BookListInBookstoresNetRequestBean alloc] init];
  __weak BookStoreViewController_ipad *weakSelf = self;
  [[DomainBeanNetworkEngineSingleton sharedInstance] requestDomainProtocolWithRequestDomainBean:netRequestBean currentNetRequestIndexToOut:&_netRequestIndexForGetBookListInBookstores successedBlock:^(id respondDomainBean) {
    
    PRPLog(@"获取 书城图书列表 成功!");
    
    // 缓存书城图书列表
    BookListInBookstoresNetRespondBean *bookListInBookstoresNetRespondBean = (BookListInBookstoresNetRespondBean *) respondDomainBean;
    LocalBookList *localBookFromBookshelf = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
    
    for (BookInfo *bookInfo in bookListInBookstoresNetRespondBean.bookInfoList) {
      LocalBook *bookAlreadyExists = [localBookFromBookshelf bookByContentID:bookInfo.content_id];
      if (bookAlreadyExists != nil) {
        // 对于已经存在的书籍, 需要更新当前书籍最新的bookInfo, 一定要及时更新, 因为服务器可能修改某本书的 bookInfo
        bookAlreadyExists.bookInfo = bookInfo;
      } else {
        // 刷新到一本新书籍, 就插入到 书籍列表中
        bookAlreadyExists = [[LocalBook alloc] initWithBookInfo:bookInfo];
      }
      
      [weakSelf.bookList addBook:bookAlreadyExists];
    }
    
    // 刷新界面
    [_bookTableView reloadData];
    
    // 解禁 "刷新按钮".
    self.refurbishButton.enabled = YES;
    
  } failedBlock:^(NetRequestErrorBean *error) {
    
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error")
                                                         message:error.message
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [alertView show];
    
    // 解禁 "刷新按钮".
    self.refurbishButton.enabled = YES;
  }];
}

-(void)requestBookDownlaodUrlWithContentID:(NSString *)contentID bindAccount:(LogonNetRespondBean *)bindAccount {
  [self requestBookDownlaodUrlWithContentID:contentID receipt:nil bindAccount:bindAccount];
}

-(void)requestBookDownlaodUrlWithContentID:(NSString *)contentID receipt:(NSData *)receipt bindAccount:(LogonNetRespondBean *)bindAccount {
  GetBookDownloadUrlNetRequestBean *netRequestBean = [[GetBookDownloadUrlNetRequestBean alloc] initWithContentId:contentID bindAccount:bindAccount];
  if (receipt != nil) {
    netRequestBean.receipt = receipt;
  } else {
    
  }
  __weak BookStoreViewController_ipad *weakSelf = self;
  [[DomainBeanNetworkEngineSingleton sharedInstance] requestDomainProtocolWithRequestDomainBean:netRequestBean currentNetRequestIndexToOut:&_netRequestIndexForGetBookDownloadUrl successedBlock:^(id respondDomainBean) {
    
    PRPLog(@"获取要下载的书籍URL 成功!");
    GetBookDownloadUrlNetRespondBean *logonNetRespondBean = (GetBookDownloadUrlNetRespondBean *) respondDomainBean;
    
    LocalBook *book = [weakSelf.bookList bookByContentID:contentID];
    [book startDownloadBookWithURLString:logonNetRespondBean.bookDownloadUrl];
    
  } failedBlock:^(NetRequestErrorBean *error) {
    
    // コンンテンツのリスト情報に変化があったのでその旨通知する必要がある
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:NSLocalizedString(@"PleaseRefresh", @"PleaseRefresh")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
  }];
  
}

#pragma mark - Table view data source

- (void)removeAllObserversForTableView {
  NSArray *subviews = _bookTableView.subviews;
  for (id v in subviews) {
    if ([v isKindOfClass:[BookStoreTableCell_ipad class]]) {
      BookStoreTableCell_ipad *cell = v;
      // 注销监听下载KVO
      LocalBook *book = [_bookList bookByContentID:cell.contentID];
      [book removeObserver:cell forKeyPath:kLocalBookProperty_bookStateEnum context:(__bridge void *)cell];
      [book removeObserver:cell forKeyPath:kLocalBookProperty_downloadProgress context:(__bridge void *)cell];
    }
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.bookList != nil ? [self.bookList bookCategoryTotalByBookNameSearch:self.latestSearchCriteria] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [self.bookList bookCategoryDictionaryByBookNameSearch:self.latestSearchCriteria];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[section];
  NSArray *bookInfoListOfSection = bookCategoryDictionaryByBookNameSearch[categoryIDOfSection];
  return bookInfoListOfSection.count;
}

// テーブルビューにセルを追加する
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BookStoreTableCell_ipad *cell = [BookStoreTableCell_ipad cellForTableView:tableView fromNib:self.bookListTableCellNib];
  if (![NSString isEmpty:cell.contentID]) {
    // 注销监听下载KVO
    LocalBook *book = [self.bookList bookByContentID:cell.contentID];
    [book removeObserver:cell forKeyPath:kLocalBookProperty_bookStateEnum context:(__bridge void *)cell];
    [book removeObserver:cell forKeyPath:kLocalBookProperty_downloadProgress context:(__bridge void *)cell];
  }
  
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [self.bookList bookCategoryDictionaryByBookNameSearch:self.latestSearchCriteria];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[indexPath.section];
  NSArray *bookInfoListOfSection = bookCategoryDictionaryByBookNameSearch[categoryIDOfSection];
  
  LocalBook *book = bookInfoListOfSection[indexPath.row];
  // 注册KVO
  [book addObserver:cell
         forKeyPath:kLocalBookProperty_bookStateEnum
            options:NSKeyValueObservingOptionNew
            context:(__bridge void *)cell];
  [book addObserver:cell
         forKeyPath:kLocalBookProperty_downloadProgress
            options:NSKeyValueObservingOptionNew
            context:(__bridge void *)cell];
  
  __weak BookStoreViewController_ipad *weakSelf = self;
  cell.bookStoreTableCellFunctionButtonClickHandleBlock
  = ^(BookStoreTableCell_ipad* tableCell, NSString *contentIDString) {
    LocalBook *book = [weakSelf.bookList bookByContentID:contentIDString];
    switch (book.bookStateEnum) {
        
      case kBookStateEnum_Unpaid:{
        
        if ([[StoreManager sharedInstance] canMakePayments]) {
          [[StoreManager sharedInstance] purchaseProductWithIdentifier:book.bookInfo.productid];
          // 更新状态->支付中...
          book.bookStateEnum = kBookStateEnum_Paiding;
        } else {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                              message:@"您的设备不支持应用内付费购买"
                                                             delegate:nil
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
          [alertView show];
          
        }
        
      }break;
        
      case kBookStateEnum_Paid:{
        if (NETWORK_REQUEST_ID_OF_IDLE == _netRequestIndexForGetBookDownloadUrl) {
          
          // 给将要保存到本地的书籍, 绑定当前处于登录状态的账号(企业账号/公共账号 都需要绑定).
          LogonNetRespondBean *account = [[LogonNetRespondBean alloc] init];
          account.username = [GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon;
          account.password = [GlobalDataCacheForMemorySingleton sharedInstance].passwordForLastSuccessfulLogon;
          book.bindAccount = account;
          
          // 向本地书籍列表中, 插入一本书(localBookList 中已经做了放置重复插入的处理, 外部不用担心).
          [[GlobalDataCacheForMemorySingleton sharedInstance].localBookList addBook:book];
          
          [weakSelf requestBookDownlaodUrlWithContentID:book.bookInfo.content_id bindAccount:book.bindAccount];
        }
      }break;
        
      case kBookStateEnum_Downloading:{
        [book stopDownloadBook];
      }break;
        
      case kBookStateEnum_Pause:{
        if (NETWORK_REQUEST_ID_OF_IDLE == _netRequestIndexForGetBookDownloadUrl) {
          [weakSelf requestBookDownlaodUrlWithContentID:book.bookInfo.content_id bindAccount:book.bindAccount];
        }
      }break;
        
      case kBookStateEnum_NotInstalled:{
        [book unzipBook];
      }break;
        
      case kBookStateEnum_Installed:{
        [weakSelf openBookWithBookSaveDirPath:book.bookSaveDirPath];
      }break;
        
      case kBookStateEnum_Update:{
        
      }break;
      default:
        break;
    }
  };
  
  [cell bind:book];
  return cell;
}

// cellの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return 244;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [self.bookList bookCategoryDictionaryByBookNameSearch:self.latestSearchCriteria];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[section];
  
  // 通过 "分类ID" 获取 "分类Name"
  NSString *categoryNameString = [[GlobalDataCacheForMemorySingleton sharedInstance].bookCategoriesNetRespondBean categoryNameByCategoryID:categoryIDOfSection];
  
  UIImage *headerViewBackgroundImage = nil;
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    // 竖屏
    if ([categoryNameString isEqual:@"通用"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_ty_hb"];
    } else if ([categoryNameString isEqual:@"宣传"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_xc_hb"];
    } else if ([categoryNameString isEqual:@"学习"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_xx_hb"];
    }
    
  } else {
    // 横屏
    if ([categoryNameString isEqual:@"通用"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_ty_hb_H"];
    } else if ([categoryNameString isEqual:@"宣传"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_xc_hb_H"];
    } else if ([categoryNameString isEqual:@"学习"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_xx_hb_H"];
    }
  }
  
  //
  UIView *headerView = nil;
  if (CURRENT_IOS_VERSION > 6.0) {
    static NSString *headerViewIdentifier = @"headerViewIdentifier";
    headerView = [self.bookTableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewIdentifier];
    if (headerView == nil) {
      headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewIdentifier];
    }
    ((UITableViewHeaderFooterView *)headerView).backgroundView = [[UIImageView alloc] initWithImage:headerViewBackgroundImage];
  } else {
    headerView = [[UIImageView alloc] initWithImage:headerViewBackgroundImage];
  }
  
  return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 31;
}

#pragma mark - 交易完成通知
- (void)receiveTransactionSucceededNotification:(NSNotification *)notification {
  @synchronized(self) {
    SKPaymentTransaction *transaction = [notification.userInfo objectForKey:@"transaction"];
    
    // 根据productID找到contentsData对象
    for (LocalBook *book in self.bookList.localBookList) {
      BookInfo *bookInfo = book.bookInfo;
      if ([bookInfo.productid isEqualToString:transaction.payment.productIdentifier]) {
        
        // 向本地书籍列表中, 插入一本书(localBookList 中已经做了放置重复插入的处理, 外部不用担心).
        [[GlobalDataCacheForMemorySingleton sharedInstance].localBookList addBook:book];
        
        // 支付成功后的收据
        NSData *receipt = transaction.transactionReceipt;
        [self requestBookDownlaodUrlWithContentID:bookInfo.content_id receipt:receipt bindAccount:book.bindAccount];
        
        break;
      }
    }
  }
}

- (void)receiveTransactionFailedNotification:(NSNotification *)notification {
  @synchronized(self) {
    SKPaymentTransaction *transaction = [notification.userInfo objectForKey:@"transaction"];
    // 根据productID找到contentsData对象
    for (LocalBook *localBook in self.bookList.localBookList) {
      BookInfo *bookInfo = localBook.bookInfo;
      if ([bookInfo.productid isEqualToString:transaction.payment.productIdentifier]) {
        // 更新状态 --> 未支付
        localBook.bookStateEnum = kBookStateEnum_Unpaid;
        
        break;
      }
    }
    
    NSString *message = [NSString stringWithFormat:@"ProductID:%@", transaction.payment.productIdentifier];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"交易失败"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
  }
}

- (void)receiveTransactionCanceledNotification:(NSNotification *)notification{
  @synchronized(self) {
    SKPaymentTransaction *transaction = [notification.userInfo objectForKey:@"transaction"];
    // 根据productID找到contentsData对象
    for (LocalBook *localBook in self.bookList.localBookList) {
      BookInfo *bookInfo = localBook.bookInfo;
      if ([bookInfo.productid isEqualToString:transaction.payment.productIdentifier]) {
        // 更新状态 --> 未支付
        localBook.bookStateEnum = kBookStateEnum_Unpaid;
        
        break;
      }
    }
  }
}

#pragma mark -
#pragma mark FlipsideViewControllerDelegate 代理
// flipsideView終了
//- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
//  [self dismissViewControllerAnimated:YES completion:nil];
//}
@end
