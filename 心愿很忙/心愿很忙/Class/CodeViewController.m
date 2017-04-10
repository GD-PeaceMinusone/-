//
//  CodeViewController.m
//  CCDraggableCard-Master
//
//  Created by jzzx on 2016/11/25.
//  Copyright © 2016年 Zechen Liu. All rights reserved.
//

#import "CodeViewController.h"
#import "CCDraggableContainer.h"
#import "CustomCardView.h"

@interface CodeViewController ()
<
CCDraggableContainerDataSource,
CCDraggableContainerDelegate
>

@property (nonatomic, strong) CCDraggableContainer *container;
@property (nonatomic, strong) NSMutableArray *dataSources;
@property(nonatomic,strong)CustomCardView *cardView;
@end

@implementation CodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self loadUI];
}

- (void)loadUI {
    // 防止视图变黑
    self.view.backgroundColor = [UIColor whiteColor];
    // 初始化Container
    self.container = [[CCDraggableContainer alloc] initWithFrame:CGRectMake(0, 64, CCWidth, CCHeight) style:CCDraggableStyleDownOverlay];
    self.container.delegate = self;
    self.container.dataSource = self;
    
    [self.view addSubview:self.container];
    // 重启加载
    [self.container reloadData];
}

- (void)loadData {
    
    _dataSources = [NSMutableArray array];
    
    
        NSDictionary *dict = @{@"image" : [NSString stringWithFormat:@"image_%d.jpg",1],
                               @"title" : [NSString stringWithFormat:@"Page %d",1]};
        [_dataSources addObject:dict];
    
}

-(void)setupPublishView {

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat closeButtonX = self.cardView.xmg_width - XMGMargin;
    CGFloat closeButtonY = XMGMargin;
    
    closeButton.frame = CGRectMake(closeButtonX, closeButtonY, 40, 40);
    
    
    
    UIImage *image = [UIImage imageNamed:@"关闭"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    
    imageView.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>);
    
    
    [closeButton addSubview:imageView];
    [self.cardView addSubview:closeButton];
}

#pragma mark - CCDraggableContainer DataSource

- (CCDraggableCardView *)draggableContainer:(CCDraggableContainer *)draggableContainer viewForIndex:(NSInteger)index {
    
    CustomCardView *cardView = [[CustomCardView alloc] initWithFrame:draggableContainer.bounds];
    [cardView installData:[_dataSources objectAtIndex:index]];
    
    
    return cardView;
}

- (NSInteger)numberOfIndexs {
    return _dataSources.count;
}

#pragma mark - CCDraggableContainer Delegate

- (void)draggableContainer:(CCDraggableContainer *)draggableContainer draggableDirection:(CCDraggableDirection)draggableDirection widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio {
    
    CGFloat scale = 1 + ((kBoundaryRatio > fabs(widthRatio) ? fabs(widthRatio) : kBoundaryRatio)) / 4;
    if (draggableDirection == CCDraggableDirectionLeft) {
        // self.disLikeButton.transform = CGAffineTransformMakeScale(scale, scale);
    }
    if (draggableDirection == CCDraggableDirectionRight) {
        // self.likeButton.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)draggableContainer:(CCDraggableContainer *)draggableContainer cardView:(CCDraggableCardView *)cardView didSelectIndex:(NSInteger)didSelectIndex {
    

}

- (void)draggableContainer:(CCDraggableContainer *)draggableContainer finishedDraggableLastCard:(BOOL)finishedDraggableLastCard {
    
    [draggableContainer reloadData];
}

@end
