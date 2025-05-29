//
//  MXPageView.m
//  123
//
//  Created by shunxingzhang on 2022/12/26.
//  Copyright © 2022 shunxingzhang. All rights reserved.
//

#import "MXPageView.h"
#import "MXBundleUtil.h"

@interface MXPageView()<UIScrollViewDelegate, MXPageScrollItemDelegate, MXPageScrollMenuDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) int pageMaxSize;

@property (nonatomic, strong) NSMutableArray *itemViewArr;

@property (nonatomic, assign) int currentIndex;

@property (nonatomic, strong) MXPageScrollMenuView *menuView;

@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIButton *lastPageBtn;

@property (nonatomic, strong) UIButton *nextPageBtn;

@property (nonatomic, assign) CGFloat beginScrollOffsetX;

@property (nonatomic, copy) MXPageViewSelectedBlock pageBlock;

@end

@implementation MXPageView

- (instancetype)initWithFrame:(CGRect)frame dataArr:(NSArray<MXPageDataModel *> *)list pageMaxSize:(int)size block:(nonnull MXPageViewSelectedBlock)block {
    if (self = [super initWithFrame:frame]) {
        self.dataList = [[NSMutableArray alloc] initWithArray:list];
        self.currentIndex = 0;
        self.pageBlock = block;
        self.pageMaxSize = size;
        [self setupSubViews];
    }
    return self;
}

#pragma mark - Public Method

- (void)updateViewFrameWith:(CGFloat)maxWidth {

    CGFloat contentScrollHeight = self.pageMaxSize * (kMXPageItemYMargin + kMXPageItemContentHeight);

    if (self.dataList.count == 1) {
        self.bounds = CGRectMake(0, 0, maxWidth, contentScrollHeight);
    } else {
        self.bounds = CGRectMake(0, 0, maxWidth, contentScrollHeight + kMXPageScrollMenuViewHeight + kMXPageLineHeight);
        self.menuView.frame = CGRectMake(0, 0, self.bounds.size.width, kMXPageScrollMenuViewHeight);
        self.lineView.frame = CGRectMake(0, CGRectGetMaxY(self.menuView.frame), CGRectGetWidth(self.frame), kMXPageLineHeight);
    }

    [self.itemViewArr enumerateObjectsUsingBlock:^(MXPageScrollItemView *  _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemView updateViewFrameWith:maxWidth];
    }];
    self.contentScrollView.frame = CGRectMake(0, self.bounds.size.height - contentScrollHeight - kMXPageBottomButtonHeight, maxWidth, contentScrollHeight);
    self.contentScrollView.contentSize = CGSizeMake(maxWidth * self.dataList.count, contentScrollHeight);
    
    self.lastPageBtn.frame = CGRectMake(kMXPageItemLeftAndRightMargin, CGRectGetHeight(self.frame) - kMXPageBottomButtonHeight, self.lastPageBtn.bounds.size.width, kMXPageBottomButtonHeight);
    self.nextPageBtn.frame = CGRectMake(self.bounds.size.width - self.nextPageBtn.bounds.size.width, CGRectGetMinY(self.lastPageBtn.frame), self.nextPageBtn.bounds.size.width, kMXPageBottomButtonHeight);
}

#pragma mark - ButtonTapOnClick
- (void)pageButtonOnClick:(UIButton *)button {
    MXPageScrollItemView *itemView = self.itemViewArr[self.currentIndex];
    if (button == self.lastPageBtn) {
        [itemView toLastPage];
    } else {
        [itemView toNextPage];
    }
    [self updatePageButtonStatus];
}

#pragma mark - Private Method
- (void)setupSubViews {
    [self setupItems];
    [self setupOtherView];
    [self updatePageButtonStatus];
}

- (void)setupItems {
    if (self.dataList.count > 1) {
        NSMutableArray *titleArr = [NSMutableArray array];
        for (MXPageDataModel *dataModel in self.dataList) {
            [titleArr addObject:dataModel.titleStr];
        }
        self.menuView = [[MXPageScrollMenuView alloc] initPagescrollMenuViewWithFrame:CGRectMake(0, 0, self.bounds.size.width, kMXPageScrollMenuViewHeight) titles:titleArr currentIndex:0];
        self.menuView.delegate = self;
        [self addSubview:self.menuView];
        [self addSubview:self.lineView];
        self.lineView.frame = CGRectMake(0, CGRectGetMaxY(self.menuView.frame), CGRectGetWidth(self.frame), kMXPageLineHeight);
    }
    
    CGFloat contentScrollHeight = self.pageMaxSize * (kMXPageItemYMargin + kMXPageItemContentHeight);
    
    self.contentScrollView.frame = CGRectMake(0, self.bounds.size.height - contentScrollHeight - kMXPageBottomButtonHeight, self.bounds.size.width, contentScrollHeight);
    self.contentScrollView.contentSize = CGSizeMake(self.bounds.size.width * self.dataList.count, contentScrollHeight);
    [self addSubview:self.contentScrollView];
    
    int index = 0;
    for (MXPageDataModel *dataModel in self.dataList) {
        MXPageScrollItemView *itemView = [[MXPageScrollItemView alloc] initPagescrollWithFrame:CGRectMake(index * self.bounds.size.width, 0, self.bounds.size.width, contentScrollHeight) itemViewTitles:dataModel.contentArr pageMaxSize:self.pageMaxSize];
        itemView.delegate = self;
        [self.contentScrollView addSubview:itemView];
        [self.itemViewArr addObject:itemView];
        index += 1;
    }
}

- (void)setupOtherView {
    [self addSubview:self.lastPageBtn];
    [self addSubview:self.nextPageBtn];
    self.lastPageBtn.frame = CGRectMake(kMXPageItemLeftAndRightMargin, CGRectGetHeight(self.frame) - kMXPageBottomButtonHeight, self.lastPageBtn.bounds.size.width, kMXPageBottomButtonHeight);
    self.nextPageBtn.frame = CGRectMake(self.bounds.size.width - self.nextPageBtn.bounds.size.width - kMXPageItemLeftAndRightMargin,  CGRectGetMinY(self.lastPageBtn.frame), self.nextPageBtn.bounds.size.width, kMXPageBottomButtonHeight);
}

- (void)adjustItemPositionWithCurrentIndex:(int)index {
    self.currentIndex = index;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentScrollView.contentOffset = CGPointMake(self.bounds.size.width * index, 0);
    } completion:^(BOOL finished) {
        [self updatePageButtonStatus];
    }];
}

- (void)updatePageButtonStatus {
    MXPageScrollItemView *itemView = self.itemViewArr[self.currentIndex];
    self.lastPageBtn.hidden = itemView.currentPageIndex == 0;
    self.nextPageBtn.hidden = !(itemView.totalPage > 1 && itemView.currentPageIndex + 1 < itemView.totalPage);
}

- (void)setPageButtonEnable:(BOOL)enable {
    self.lastPageBtn.enabled = enable;
    self.nextPageBtn.enabled = enable;
}


#pragma mark - Lazy Method

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
    }
    return _contentScrollView;
}

- (NSMutableArray *)itemViewArr {
    if (!_itemViewArr) {
        _itemViewArr = [[NSMutableArray alloc] init];
    }
    return _itemViewArr;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:244/255 green:242/255 blue:241/255 alpha:0.2];
    }
    return _lineView;
}

- (UIButton *)lastPageBtn {
    if (!_lastPageBtn) {
        _lastPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lastPageBtn setTitle:[NSString stringWithFormat:@"< %@", [MXBundleUtil localizedStringForKey:@"last_page"]] forState:UIControlStateNormal];
        _lastPageBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_lastPageBtn setTitleColor:[UIColor colorWithRed:111.0/255.0 green:117.0/255.0 blue:146.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_lastPageBtn addTarget:self action:@selector(pageButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_lastPageBtn sizeToFit];
    }
    return _lastPageBtn;
}

- (UIButton *)nextPageBtn{
    if (!_nextPageBtn) {
        _nextPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextPageBtn setTitle:[NSString stringWithFormat:@"%@ >", [MXBundleUtil localizedStringForKey:@"next_page"]] forState:UIControlStateNormal];
        _nextPageBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_nextPageBtn setTitleColor:[UIColor colorWithRed:111.0/255.0 green:117.0/255.0 blue:146.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_nextPageBtn addTarget:self action:@selector(pageButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_nextPageBtn sizeToFit];
    }
    return _nextPageBtn;
}

#pragma mark - MXPageScrollMenuDelegate
- (void)selectedMenuIndex:(NSInteger)index {
    if (index == self.currentIndex) {
        return;
    }
    [self adjustItemPositionWithCurrentIndex:(int)index];
}

#pragma mark - MXPageScrollItemDelegate
- (void)selectedItemContent:(NSString *)content {
    if (self.pageBlock) {
        self.pageBlock(content);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginScrollOffsetX = scrollView.contentOffset.x;
    [self setPageButtonEnable:NO];
    [self.menuView beginScrollContent];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        
        [self setPageButtonEnable:YES];
        
        
        CGFloat itemWidth = self.bounds.size.width;
        CGFloat currentPostion = scrollView.contentOffset.x;
        int index = (int)roundf(currentPostion / itemWidth);
        [self.menuView endScrollContentIndex:index];
        [self adjustItemPositionWithCurrentIndex:index];
    }
}

/// scrollView滚动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setPageButtonEnable:YES];
    CGFloat itemWidth = self.bounds.size.width;
    CGFloat currentPostion = scrollView.contentOffset.x;
    int index = (int)roundf(currentPostion / itemWidth);
    [self.menuView endScrollContentIndex:index];
    [self adjustItemPositionWithCurrentIndex:index];
}

/// scrollView滚动ing
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat currentPostion = scrollView.contentOffset.x;

    CGFloat offsetX = currentPostion / self.bounds.size.width;

    int currentIndex = (int)floorf(offsetX);
    float indexPercent = offsetX - currentIndex;
    if (self.menuView) {
        [self.menuView updateScrollContentIndex:(NSInteger)currentIndex indexPercent:indexPercent];
    }
}

@end
