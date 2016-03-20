//
//  ViewController.m
//  CCZCacheDemo
//
//  Created by cuocuo on 16/2/19.
//  Copyright © 2016年 cuocuo. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
#import <QuartzCore/QuartzCore.h>
#import "CCZCache.h"

@interface ViewController ()<UIGestureRecognizerDelegate>
{
    NSLock *_testLock;
    pthread_mutex_t _lock;
    dispatch_semaphore_t _semaphoreLock;
}
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
