//
//  CCZLinedHashMap.h
//  CCZCacheDemo
//
//  Created by cuocuo on 16/3/7.
//  Copyright © 2016年 cuocuo.
//  This source code is licensed under the MIT-style license.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCZLinedHashMapNode : NSObject

@property (nonatomic, weak, readonly, nullable) CCZLinedHashMapNode *front;
@property (nonatomic, weak, readonly, nullable) CCZLinedHashMapNode *behind;
@property (nonatomic, strong) id<NSCopying> key;   //对应的唯一标识
@property (nonatomic, strong) id value;            //节点数据
@property (nonatomic, assign) NSUInteger size;     //数据大小
@property (nonatomic, assign) CFTimeInterval time; //最近访问时间
@property (nonatomic, assign) NSUInteger hitCount; //命中次数
@end

@interface CCZLinedHashMap : NSObject

@property (nonatomic, weak, readonly, nullable) CCZLinedHashMapNode *first;
@property (nonatomic, weak, readonly, nullable) CCZLinedHashMapNode *last;
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, CCZLinedHashMapNode*> *nodes; //缓存容器
@property (nonatomic, assign) NSUInteger count; //总数量
@property (nonatomic, assign) NSUInteger totalSize; //总大小

- (void)ccz_addNode:(CCZLinedHashMapNode*)node;

- (void)ccz_insertNodeAtFirst:(CCZLinedHashMapNode*)node;

- (void)ccz_insertNode:(CCZLinedHashMapNode*)node atIndexedNode:(CCZLinedHashMapNode*)indexedNode front:(BOOL)isFront;

- (void)ccz_bringNode:(CCZLinedHashMapNode*)node toIndexedNode:(CCZLinedHashMapNode*)indexedNode front:(BOOL)isFront;

- (void)ccz_bringNodeToFirst:(CCZLinedHashMapNode*)node;

- (void)ccz_removeNode:(CCZLinedHashMapNode*)node;

- (CCZLinedHashMapNode*)ccz_removeLastNode;

- (void)ccz_removeAll;

@end

NS_ASSUME_NONNULL_END