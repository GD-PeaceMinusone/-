//
//  WSIHomeTableViewController.m
//  心愿很忙
//
//  Created by Jackeylove on 2017/4/21.
//  Copyright © 2017年 Jackeylove. All rights reserved.
//

#import "WSIHomeTableViewController.h"
#import "WSILoginViewController.h"
#import "WSIMeViewController.h"
#import <AFNetworking.h>
#import "WSIRefreshHeader.h"
#import "WSIRefreshFooter.h"
#import <BmobSDK/Bmob.h>
#import "HUDUtils.h"
#import "ListObject.h"
#import "HomeTableViewCell.h"
#import "CodeViewController.h"
#import "AppDelegate.h"
#import "MJRefreshGifHeader+HeaderRefresh.h"
#import "UIScrollView+Refresh.h"


@interface WSIHomeTableViewController ()
/**数据数组*/
@property(nonatomic,strong)NSMutableArray *itObjs;
/** window */
@property (nonatomic, strong) UIWindow *window;
/**数据数组*/
@property(nonatomic,strong)NSMutableArray *moreItobjs;

@end

@implementation WSIHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self networkStatus];
    [self registerCell];
    [self setupRefresh];
    
    
}

-(void)viewDidAppear:(BOOL)animated{//显示tabbar
    
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated {//隐藏tabbar
   
    self.tabBarController.tabBar.hidden = YES;
}


/**
 *  懒加载
 */

-(NSMutableArray *)itObjs {

    if (!_itObjs) {
        
        _itObjs = [NSMutableArray array];
    }
    
    return _itObjs;
}

/**
 *  注册cell
 */
-(void)registerCell {
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"HomeCell"];
}


/**
 *  设置刷新操作
 */
-(void)setupRefresh {
    
    WSIWeakSelf
    [self.tableView addHeaderRefresh:^{
        [weakSelf loadNewTopics];
    }];
    
    [weakSelf.tableView beginHeaderRefresh];
    
    [self.tableView addFooterRefresh:^{
        [weakSelf loadMoreTopics];
    }];
}


/**
 *  设置导航栏样式
 */
-(void)setupNavigationBar {
    
    UIImage *image1 = [UIImage imageNamed:@"列表 "];
    image1 = [image1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *image2 = [UIImage imageNamed:@"发表"];
    image2 = [image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage: image1 style:UIBarButtonItemStylePlain target:self action:@selector(goMe)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage: image2 style:UIBarButtonItemStylePlain target:self action:@selector(publish:)];

    [self.navigationController.navigationBar.subviews firstObject].hidden = YES;
    
    
}

//-(void)setupPublishButton {
//    
//    _button = [UIButton new];
//    [_button setImage:[UIImage imageNamed:@"发布"] forState:UIControlStateNormal];
//    
//    /**
//     CGFloat buttonW = 75;
//     CGFloat buttonH = 40;
//     CGFloat buttonX = (self.view.xmg_width - buttonW)*0.5;
//     CGFloat buttonY = self.view.xmg_height - WSIMargin - buttonH;
//     */
//    
//    _button.frame =  CGRectMake(0,0, 64, 64);
//    [_button addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
//    
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//    
//    //悬浮按钮所处的顶端UIWindow
//    _window = [[UIWindow alloc] initWithFrame:CGRectMake(screenWidth*0.5-32, screenHeight-70, 64, 64)];
//    
//    //使得新建window在最顶端
//    _window.windowLevel = UIWindowLevelAlert + 1;
//    _window.backgroundColor = [UIColor clearColor];
//    [_window addSubview:_button];
//    
//    //显示window
//    [_window makeKeyAndVisible];
//}


/**
 *  设置发布按钮
 */
-(void)publish: (UIButton*)button {
    
    if ([BmobUser currentUser]) {
        
        CodeViewController *codeVc = [CodeViewController new];
        [self presentViewController:codeVc animated:YES completion:nil];
        
    }else {
        
        WSILoginViewController *loginVc = [WSILoginViewController new];
        [self presentViewController:loginVc animated:YES completion:nil];
        
    }
    
}

/**
 *  监听按钮响应
 */
-(void)goMe {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"clickButton" object:nil];
    
}


#pragma mark - 数据加载

-(void)loadNewTopics {
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"ListObject"];
    
    query.limit = 10;
    
    [query orderByDescending:@"createdAt"];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (error) {
            
            [HUDUtils setupErrorWithStatus:@"加载失败" WithDelay:2.0f completion:^{
                
                WSIWeakSelf
                [weakSelf.tableView endHeaderRefresh];
                
            }];
        }{
            
        self.itObjs = [[ListObject ListObjcetArrayFromBmobObjectArray:array] mutableCopy];
        [self.tableView reloadData];
        self.moreItobjs = [array mutableCopy];
        WSIWeakSelf
        [weakSelf.tableView endHeaderRefresh];
            
        }
    }];
    
    
    //把数据保存
////    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.itObjs];
//    
//    [data writeToFile:kITObjsPath atomically:YES];
    
}


-(void)loadMoreTopics {
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"ListObject"];
    
    query.limit = 10;
    
    BmobObject *obj = self.moreItobjs[self.moreItobjs.count - 1];
    
    [query whereKey:@"createdAt" lessThan:obj.createdAt];
   
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (error) {
            
            [HUDUtils setupErrorWithStatus:@"加载失败" WithDelay:2.0f completion:^{
                
                WSIWeakSelf
                [weakSelf.tableView endFooterRefresh];
                
            }];
        }{
            NSArray<ListObject*> *moreItObjs = [ListObject ListObjcetArrayFromBmobObjectArray:array];
            [self.itObjs addObjectsFromArray:moreItObjs];
            [self.moreItobjs addObjectsFromArray:array];
            [self.tableView reloadData];
            
            WSIWeakSelf
            [weakSelf.tableView endFooterRefresh];
            
        }
    }];
}

//判断网络状态
-(void)networkStatus {
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                
                [HUDUtils setupInfoWithStatus:@"网络似乎有点问题" WithDelay:1.5f completion:nil];
                
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                
                [HUDUtils setupErrorWithStatus:@"网络未连接" WithDelay:1.5f completion:nil];
                
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:

                
                break;
                
            default:
                break;
        }
        
    }];
    
    [manager startMonitoring];
}




#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return self.itObjs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    
    homeCell.itObj = self.itObjs[indexPath.row];
    
    return homeCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        ListObject *obj = self.itObjs[indexPath.row];
        return obj.cellHeight;


}

/**
 *  设置bar随滚动隐藏和显示
 */

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [UIView animateWithDuration:1 animations:^{
        
        self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 49);
        self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, -49);
       
        
    }];
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

    [UIView animateWithDuration:1 animations:^{
        
        self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
        self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0);
        
    }];
}


@end
