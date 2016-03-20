//
//  CCZMemoryCache.m
//  CCZCacheDemo
//
//  Created by cuocuo on 16/2/28.
//  Copyright © 2016年 cuocuo.
//  This source code is licensed under the MIT-style license.
//

#import "CCZMemoryCache.h"
#import <QuartzCore/QuartzCore.h>
#import "CCZLinedHashMap.h"
#import <UIKit/UIKit.h>

#define DEFAULTMAXCOUNT 100
#define DEFAULTMAXSIZE 20*1024*1024

@protocol CCZQueue <NSObject>
@property (nonatomic, strong) CCZLinedHashMap *linedMap;
@property (nonatomic, assign) NSUInteger maxCountLimit;
@property (nonatomic, assign) NSUInteger maxSizeLimit;
- (void)ccz_pushNode:(CCZLinedHashMapNode*)node;
- (void)ccz_popNode:(CCZLinedHashMapNode*)node;
- (void)ccz_hitNode:(CCZLinedHashMapNode*)node;
- (void)ccz_setObject:(id)object forKey:(nonnull id<NSCopying>)key size:(NSUInteger)size;
- (CCZLinedHashMapNode *)ccz_NodeForKey:(nonnull id<NSCopying>)key ;
- (void)ccz_removeObjectForKey:(nonnull id)key;
- (void)ccz_removeAllNodes;

@end

/* FIFO 队列 */
@interface CCZFIFOQueue : NSObject<CCZQueue>
@property (nonatomic, strong) CCZLinedHashMap *linedMap;
@property (nonatomic, assign) NSUInteger maxCountLimit;
@property (nonatomic, assign) NSUInteger maxSizeLimit;
@end

@implementation CCZFIFOQueue

- (instancetype)init{
    self = [super init];
    if (self) {
        _linedMap = [[CCZLinedHashMap alloc]init];
        _maxCountLimit = DEFAULTMAXCOUNT;
        _maxSizeLimit = DEFAULTMAXSIZE;
    }
    return self;
}

- (void)ccz_pushNode:(CCZLinedHashMapNode*)node {
    [_linedMap ccz_insertNodeAtFirst:node];
    if (_linedMap.totalSize > _maxSizeLimit) {
        [self ccz_popNode:_linedMap.last];
    }
    if (_linedMap.count > _maxCountLimit) {
        [self ccz_popNode:_linedMap.last];
    }
}

- (void)ccz_popNode:(CCZLinedHashMapNode*)node {
    [_linedMap ccz_removeNode:node];
}

- (void)ccz_hitNode:(CCZLinedHashMapNode*)node {
    node.hitCount++;
}

- (void)ccz_setObject:(id)object forKey:(id<NSCopying>)key size:(NSUInteger)size {
    if (!key) {
        return;
    }
    if (!object) {
        [self ccz_removeObjectForKey:key];
        return;
    }
    CFTimeInterval time = CACurrentMediaTime();
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    if (node) {
        _linedMap.totalSize -= node.size;
        _linedMap.totalSize += size;
        node.size = size;
        node.value = object;
        node.time = time;
    } else {
        node = [[CCZLinedHashMapNode alloc]init];
        node.key = key;
        node.value = object;
        node.size = size;
        node.time = time;
        [self ccz_pushNode:node];
    }
}

- (void)ccz_removeObjectForKey:(id)key {
    if (!key) {
        return;
    }
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    [self ccz_popNode:node];
}

- (CCZLinedHashMapNode *)ccz_NodeForKey:(id<NSCopying>)key {
    if (!key) {
        return nil;
    }
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    if (!node) {
        return nil;
    }
    node.time = CACurrentMediaTime();
    [self ccz_hitNode:node];
    return node;
}

- (void)ccz_removeAllNodes{
    [_linedMap ccz_removeAll];
}

@end

/* LRU 队列 */
@interface CCZLRUQueue : NSObject<CCZQueue>
@property (nonatomic, strong) CCZLinedHashMap *linedMap;
@property (nonatomic, assign) NSUInteger maxCountLimit;
@property (nonatomic, assign) NSUInteger maxSizeLimit;
@end

@implementation CCZLRUQueue

- (instancetype)init{
    self = [super init];
    if (self) {
        _linedMap = [[CCZLinedHashMap alloc]init];
        _maxCountLimit = DEFAULTMAXCOUNT;
        _maxSizeLimit = DEFAULTMAXSIZE;
    }
    return self;
}

- (void)ccz_pushNode:(CCZLinedHashMapNode*)node {
    [_linedMap ccz_insertNodeAtFirst:node];
    if (_linedMap.totalSize > _maxSizeLimit) {
        [self ccz_popNode:_linedMap.last];
    }
    if (_linedMap.count > _maxCountLimit) {
        [self ccz_popNode:_linedMap.last];
    }
}

- (void)ccz_popNode:(CCZLinedHashMapNode*)node {
    [_linedMap ccz_removeNode:node];
}

- (void)ccz_hitNode:(CCZLinedHashMapNode*)node {
    node.hitCount++;
    [_linedMap ccz_bringNodeToFirst:node];
}

- (void)ccz_setObject:(id)object forKey:(id<NSCopying>)key size:(NSUInteger)size {
    if (!key) {
        return;
    }
    if (!object) {
        [self ccz_removeObjectForKey:key];
        return;
    }
    CFTimeInterval time = CACurrentMediaTime();
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    if (node) {
        _linedMap.totalSize -= node.size;
        _linedMap.totalSize += size;
        node.size = size;
        node.value = object;
        node.time = time;
        node.hitCount++;
        [_linedMap ccz_bringNodeToFirst:node];
    } else {
        node = [[CCZLinedHashMapNode alloc]init];
        node.key = key;
        node.value = object;
        node.size = size;
        node.time = time;
        [self ccz_pushNode:node];
    }
}

- (void)ccz_removeObjectForKey:(id)key {
    if (!key) {
        return;
    }
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    [self ccz_popNode:node];
}

- (CCZLinedHashMapNode *)ccz_NodeForKey:(id<NSCopying>)key  {
    if (!key) {
        return nil;
    }
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    if (!node) {
        return nil;
    }
    node.time = CACurrentMediaTime();
    [self ccz_hitNode:node];
    return node;
}

- (void)ccz_removeAllNodes{
    [_linedMap ccz_removeAll];
}

@end

/* LFU 队列 */
@interface CCZLFUQueue : NSObject<CCZQueue>
@property (nonatomic, strong) CCZLinedHashMap *linedMap;
@property (nonatomic, assign) NSUInteger maxCountLimit;
@property (nonatomic, assign) NSUInteger maxSizeLimit;
@end

@implementation CCZLFUQueue

- (instancetype)init{
    self = [super init];
    if (self) {
        _linedMap = [[CCZLinedHashMap alloc]init];
        _maxCountLimit = DEFAULTMAXCOUNT;
        _maxSizeLimit = DEFAULTMAXSIZE;
    }
    return self;
}

- (void)ccz_pushNode:(CCZLinedHashMapNode*)node {
    node.time = CACurrentMediaTime();
    [_linedMap ccz_addNode:node];
    if (_linedMap.totalSize > _maxSizeLimit) {
        [self ccz_popNode:node.front];
    }
    if (_linedMap.count > _maxCountLimit) {
        [self ccz_popNode:node.front];
    }
}

- (void)ccz_popNode:(CCZLinedHashMapNode*)node {
    [_linedMap ccz_removeNode:node];
}

- (void)ccz_hitNode:(CCZLinedHashMapNode*)node {
    node.hitCount++;
    while (node.front && node.hitCount >= node.front.hitCount) {
        [_linedMap ccz_bringNode:node toIndexedNode:node.front front:YES];
    }
}

- (void)ccz_setObject:(id)object forKey:(_Nonnull id<NSCopying>)key size:(NSUInteger)size {
    if (!key) {
        return;
    }
    if (!object) {
        [self ccz_removeObjectForKey:key];
        return;
    }
    CFTimeInterval time = CACurrentMediaTime();
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    if (node) {
        _linedMap.totalSize -= node.size;
        _linedMap.totalSize += size;
        node.size = size;
        node.value = object;
        node.time = time;
    } else {
        node = [[CCZLinedHashMapNode alloc]init];
        node.key = key;
        node.value = object;
        node.size = size;
        node.time = time;
        [self ccz_pushNode:node];
    }
}

- (void)ccz_removeObjectForKey:(id)key {
    if (!key) {
        return;
    }
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    [self ccz_popNode:node];
}

- (CCZLinedHashMapNode *)ccz_NodeForKey:(id<NSCopying>)key  {
    if (!key) {
        return nil;
    }
    CCZLinedHashMapNode *node = _linedMap.nodes[key];
    if (!node) {
        return nil;
    }
    node.time = CACurrentMediaTime();
    [self ccz_hitNode:node];
    return node;
}

- (void)ccz_removeAllNodes{
    [_linedMap ccz_removeAll];
}

@end

// LRU2 (Least Recently Used 2), FIFO + LRU(Cache)
@interface _CCZMemoryCacheLRU2 : CCZMemoryCache
@property (nonatomic, strong) CCZFIFOQueue *fifoQueue;
@property (nonatomic, strong) CCZLRUQueue *lruQueue;
@end

@implementation _CCZMemoryCacheLRU2

- (instancetype)init{
    self = [super init];
    if (self) {
        _fifoQueue = [[CCZFIFOQueue alloc]init];
        _fifoQueue.maxCountLimit = self.maxCountLimit;
        _fifoQueue.maxSizeLimit = self.maxSizeLimit;
        _lruQueue = [[CCZLRUQueue alloc]init];
        _lruQueue.maxCountLimit = self.maxCountLimit;
        _lruQueue.maxSizeLimit = self.maxSizeLimit;
    }
    return self;
}

- (void)storeObject:(id)object forKey:(id<NSCopying>)key {
    [self storeObject:object forKey:key size:0];
}

- (void)storeObject:(id)object forKey:(id<NSCopying>)key size:(NSUInteger)size{
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    CCZLinedHashMapNode *lruNode = _lruQueue.linedMap.nodes[key];
    CFTimeInterval time = CACurrentMediaTime();
    if (lruNode) {
        _lruQueue.linedMap.totalSize -= lruNode.size;
        _lruQueue.linedMap.totalSize += size;
        lruNode.size = size;
        lruNode.value = object;
        lruNode.time = time;
        lruNode.hitCount++;
        [_lruQueue.linedMap ccz_bringNodeToFirst:lruNode];
    } else {
        CCZLinedHashMapNode *fifoNode = _fifoQueue.linedMap.nodes[key];
        if (fifoNode && fifoNode.hitCount == 1) {
            [_fifoQueue ccz_popNode:fifoNode];
            [_lruQueue ccz_setObject:object forKey:key size:size];
        } else {
            [_fifoQueue ccz_setObject:key forKey:key size:size];
        }
    }
    dispatch_semaphore_signal(_semaphoreLock);
    
}

- (id)objectForKey:(id<NSCopying>)key {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    CCZLinedHashMapNode *node = [_fifoQueue ccz_NodeForKey:key];
    if (node) {
        dispatch_semaphore_signal(_semaphoreLock);
        return nil;
    } else {
        node = [_lruQueue ccz_NodeForKey:key];
    }
    dispatch_semaphore_signal(_semaphoreLock);
    return node.value;
    
}

- (void)removeObjectForKey:(id)key {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_lruQueue ccz_removeObjectForKey:key];
    dispatch_semaphore_signal(_semaphoreLock);
}

- (void)clearMemoryCache {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_fifoQueue ccz_removeAllNodes];
    [_lruQueue ccz_removeAllNodes];
    dispatch_semaphore_signal(_semaphoreLock);
}

@end

// 2Q (Two Queues),FIFO(Cache) + LRU(Cache).
@interface _CCZMemoryCache2Q : CCZMemoryCache
@property (nonatomic, strong) CCZFIFOQueue *fifoQueue;
@property (nonatomic, strong) CCZLRUQueue *lruQueue;
@end

@implementation _CCZMemoryCache2Q

- (instancetype)init{
    self = [super init];
    if (self) {
        _fifoQueue = [[CCZFIFOQueue alloc]init];
        _fifoQueue.maxCountLimit = self.maxCountLimit/2;
        _fifoQueue.maxSizeLimit = self.maxSizeLimit/2;
        _lruQueue = [[CCZLRUQueue alloc]init];
        _lruQueue.maxCountLimit = self.maxCountLimit - self.maxCountLimit/2;
        _lruQueue.maxSizeLimit = self.maxSizeLimit - self.maxSizeLimit/2;
    }
    return self;
}

- (void)storeObject:(id)object forKey:(id<NSCopying>)key {
    [self storeObject:object forKey:key size:0];
}

- (void)storeObject:(id)object forKey:(id<NSCopying>)key size:(NSUInteger)size{
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    CFTimeInterval time = CACurrentMediaTime();
    CCZLinedHashMapNode *lruNode = _lruQueue.linedMap.nodes[key];
    if (lruNode) {
        _lruQueue.linedMap.totalSize -= lruNode.size;
        _lruQueue.linedMap.totalSize += size;
        lruNode.size = size;
        lruNode.value = object;
        lruNode.time = time;
        lruNode.hitCount++;
        [_lruQueue.linedMap ccz_bringNodeToFirst:lruNode];
    } else {
        [_fifoQueue ccz_setObject:object forKey:key size:size];
    }
    dispatch_semaphore_signal(_semaphoreLock);
    
}

- (id)objectForKey:(id<NSCopying>)key {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    CCZLinedHashMapNode *node = [_fifoQueue ccz_NodeForKey:key];
    if (node) {
        if (node.hitCount == 1) {
            node.hitCount = 0;
            [_lruQueue ccz_pushNode:node];
            [_fifoQueue ccz_popNode:node];
        }
    } else {
        node = [_lruQueue ccz_NodeForKey:key];
    }
    dispatch_semaphore_signal(_semaphoreLock);
    return node.value;
    
}

- (void)removeObjectForKey:(id)key {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_fifoQueue ccz_removeObjectForKey:key];
    [_lruQueue ccz_removeObjectForKey:key];
    dispatch_semaphore_signal(_semaphoreLock);
}

- (void)clearMemoryCache {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_fifoQueue ccz_removeAllNodes];
    [_lruQueue ccz_removeAllNodes];
    dispatch_semaphore_signal(_semaphoreLock);
}

@end

@interface _CCZMemoryCacheLFU : CCZMemoryCache
@property (nonatomic, strong) CCZLFUQueue *lfuQueue;

@end

@implementation _CCZMemoryCacheLFU

- (instancetype)init{
    self = [super init];
    if (self) {
        _lfuQueue = [[CCZLFUQueue alloc]init];
        _lfuQueue.maxCountLimit = self.maxCountLimit;
        _lfuQueue.maxSizeLimit = self.maxSizeLimit;
    }
    return self;
}

- (void)storeObject:(id)object forKey:(id<NSCopying>)key {
    [self storeObject:object forKey:key size:0];
}

- (void)storeObject:(id)object forKey:(id<NSCopying>)key size:(NSUInteger)size{
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_lfuQueue ccz_setObject:object forKey:key size:size];
    dispatch_semaphore_signal(_semaphoreLock);
    
}

- (id)objectForKey:(id<NSCopying>)key {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    CCZLinedHashMapNode *node = [_lfuQueue ccz_NodeForKey:key];
    dispatch_semaphore_signal(_semaphoreLock);
    return node.value;
    
}

- (void)removeObjectForKey:(id)key {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_lfuQueue ccz_removeObjectForKey:key];
    dispatch_semaphore_signal(_semaphoreLock);
}

- (void)clearMemoryCache {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_lfuQueue ccz_removeAllNodes];
    dispatch_semaphore_signal(_semaphoreLock);
}

@end

@interface CCZMemoryCache ()
@property (nonatomic, strong)CCZLRUQueue *lruQueue;
@end

@implementation CCZMemoryCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _lruQueue = [[CCZLRUQueue alloc]init];
        _lruQueue.maxCountLimit = self.maxCountLimit;
        _lruQueue.maxSizeLimit = self.maxSizeLimit;
        _semaphoreLock = dispatch_semaphore_create(1);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemoryCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (instancetype)initWithType:(CCZMemoryCacheAlgorithmicType)algorithmicType {
    switch (algorithmicType) {
        case CCZMemoryCacheTypeDefault:
            return [[CCZMemoryCache alloc]init];
            break;
        case CCZMemoryCacheTypeLRU2:
            return [[_CCZMemoryCacheLRU2 alloc]init];
            break;
        case CCZMemoryCacheType2Q:
            return [[_CCZMemoryCache2Q alloc]init];
            break;
        case CCZMemoryCacheTypeLFU:
            return [[_CCZMemoryCacheLFU alloc]init];
            break;
        default:
            break;
    }
}

+ (instancetype)memoryCacheWithType:(CCZMemoryCacheAlgorithmicType)algorithmicType {
    return [[CCZMemoryCache alloc] initWithType:algorithmicType];
}

- (void)storeObject:(id)object forKey:(id<NSCopying>)key {
    [self storeObject:object forKey:key size:0];
}

- (void)storeObject:(id)object forKey:(id<NSCopying>)key size:(NSUInteger)size{
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_lruQueue ccz_setObject:object forKey:key size:size];
    dispatch_semaphore_signal(_semaphoreLock);
    
}

- (id)objectForKey:(id<NSCopying>)key {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    CCZLinedHashMapNode *node = [_lruQueue ccz_NodeForKey:key];
    dispatch_semaphore_signal(_semaphoreLock);
    return node.value;
   
}

- (void)removeObjectForKey:(id)key {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_lruQueue ccz_removeObjectForKey:key];
    dispatch_semaphore_signal(_semaphoreLock);
}

- (void)clearMemoryCache {
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    [_lruQueue ccz_removeAllNodes];
    dispatch_semaphore_signal(_semaphoreLock);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end