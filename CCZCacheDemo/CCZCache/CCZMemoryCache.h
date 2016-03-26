//
//  CCZMemoryCache.h
//  CCZCacheDemo
//
//  Created by cuocuo on 16/2/28.
//  Copyright © 2016年 cuocuo.
//  This source code is licensed under the MIT-style license.
//

#import <Foundation/Foundation.h>
#import "CCZLinedHashMap.h"

NS_ASSUME_NONNULL_BEGIN

//缓存算法
typedef NS_ENUM(NSInteger,CCZMemoryCacheAlgorithmicType) {
    CCZMemoryCacheTypeDefault,  
    CCZMemoryCacheTypeLRU = CCZMemoryCacheTypeDefault ,      // LRU（Least Recently Used),最近最少使用。
    CCZMemoryCacheTypeLRU2,
    CCZMemoryCacheType2Q,
    CCZMemoryCacheTypeLFU
};

@interface CCZMemoryCache : NSObject{
    @protected
    dispatch_semaphore_t _semaphoreLock;
    NSUInteger _maxCountLimit;
    NSUInteger _maxSizeLimit;
}

//初始化方法，‘CCZMemoryCacheAlgorithmicType’可选择缓存算法。
- (instancetype)initWithType:(CCZMemoryCacheAlgorithmicType)algorithmicType;
+ (instancetype)memoryCacheWithType:(CCZMemoryCacheAlgorithmicType)algorithmicType;

//缓存最大数量，默认是100。
@property (nonatomic, assign) NSUInteger maxCountLimit;
//缓存最大容量，默认是20MB。缓存淘汰先以'maxSizeLimit'为基准进行淘汰。
@property (nonatomic, assign) NSUInteger maxSizeLimit;

/*
 * 储存一个缓存对象。
 *
 * @param object
 * 需要缓存的对象。如果为空，key在缓存中有对应缓存对象，那么默认删除次缓存对象。
 *
 * @param key
 * 不可为空，需实现'NSCopying'协议。
 *
 */
- (void)storeObject:(nullable id)object forKey:(id<NSCopying>)key;
/*
 * 储存一个缓存对象。
 *
 * @param object
 * 需要缓存的对象。如果为空，key在缓存中有对应缓存对象，那么默认删除次缓存对象。
 *
 * @param key
 * 缓存对象对应的唯一key值，不可为空，需实现'NSCopying'协议。
 *
 * @param size
 * 储存缓存对象的大小，作为判断是否超出'maxSizeLimit'的依据。如果不需要通过大小来限制缓存容量可以传入0。
 *
 */
- (void)storeObject:(id)object forKey:(id<NSCopying>)key size:(NSUInteger)size;
/*
 * 获取一个缓存对象。
 *
 * @param key
 * 缓存对象对应的唯一key值。如果为空，返回值亦为空。
 *
 * @return id
 * 获取的缓存对象。
 *
 */
- (nullable id)objectForKey:(id<NSCopying>)key;
/*
 * 通过key删除对应的缓存对象。
 */
- (void)removeObjectForKey:(id<NSCopying>)key;
/*
 * 清空内存中的缓存数据。
 */
- (void)clearMemoryCache;
@end

NS_ASSUME_NONNULL_END