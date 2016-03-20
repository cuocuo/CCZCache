//
//  CCZLinedHashMap.m
//  CCZCacheDemo
//
//  Created by cuocuo on 16/3/7.
//  Copyright © 2016年 cuocuo. All rights reserved.
//

#import "CCZLinedHashMap.h"

/* 一个双链表节点。 */
@interface CCZLinedHashMapNode()
@property (nonatomic, weak, nullable) CCZLinedHashMapNode *front;
@property (nonatomic, weak, nullable) CCZLinedHashMapNode *behind;
@end

@implementation CCZLinedHashMapNode

@end

@interface CCZLinedHashMap ()
@property (nonatomic, weak, nullable) CCZLinedHashMapNode *first;
@property (nonatomic, weak, nullable) CCZLinedHashMapNode *last;

@end

@implementation CCZLinedHashMap

- (instancetype)init {
    self = [super init];
    if (self) {
        _nodes = [NSMutableDictionary dictionary];
        _count = 0;
        _totalSize = 0;
    }
    return self;
}

- (void)ccz_addNode:(CCZLinedHashMapNode*)node {
    [self ccz_insertNode:node atIndexedNode:_last front:NO];
}

- (void)ccz_insertNodeAtFirst:(CCZLinedHashMapNode*)node {
    [self ccz_insertNode:node atIndexedNode:_first front:YES];
}

- (void)ccz_insertNode:(CCZLinedHashMapNode*)node atIndexedNode:(CCZLinedHashMapNode*)indexedNode front:(BOOL)isFront {
    if (!node || (!indexedNode && _count != 0) || (indexedNode && _count == 0)) {
        return;
    }
    
    [_nodes setObject:node forKey:node.key];
    if (_count == 0) {
        _first = _last = node;
        return;
    }
    if (isFront) {
        node.behind = indexedNode;
        node.front = indexedNode.front;
        if (indexedNode != _first) {
            indexedNode.front.behind = node;
        }
        indexedNode.front = node;
        if (indexedNode == _first) {
            _first = node;
        }
        
    } else {
        node.front = indexedNode;
        node.behind = indexedNode.behind;
        if (indexedNode != _last) {
            indexedNode.behind.front = node;
        }
        indexedNode.behind = node;
        if (indexedNode == _last) {
            _last = node;
        }
    }
    _count ++;
    _totalSize += node.size;
}

- (void)ccz_bringNode:(CCZLinedHashMapNode*)node toIndexedNode:(CCZLinedHashMapNode*)indexedNode front:(BOOL)isFront {
    if (!node || !indexedNode || _count < 2 || node == _first) {
        return;
    }
    
    if (isFront) {
        if (node == _last) {
            node.front.behind = nil;
            _last = node.front;
        } else {
            node.front.behind = node.behind;
            node.behind.front = node.front;
        }
        node.front = indexedNode.front;
        node.behind = indexedNode;
        indexedNode.front = indexedNode;
        if (node == _first) {
            _first = node;
        }
    } else {
        if (node == _first) {
            node.behind.front = nil;
            _first = node.behind;
        } else {
            node.front.behind = node.behind;
            node.behind.front = node.front;
        }
        node.behind = indexedNode.behind;
        node.front = indexedNode;
        indexedNode.behind = indexedNode;
        if (node == _last) {
            _last = node;
        }
    }
}

- (void)ccz_bringNodeToFirst:(CCZLinedHashMapNode*)node {
    [self ccz_bringNode:node toIndexedNode:_first front:YES];
    
}

- (void)ccz_removeNode:(CCZLinedHashMapNode*)node {
    if (!node) {
        return;
    }
    if (_count == 1) {
        [self ccz_removeAll];
        return;
    }
    [_nodes removeObjectForKey:_last.key];
    if (node == _last) {
        node.front.behind = nil;
        _last = node.front;
    } else if (node == _first) {
        node.behind.front = nil;
        _first = node.behind;
    } else {
        node.front.behind = node.behind;
        node.behind.front = node.front;
    }
    _count--;
    _totalSize -= node.size;
}

- (CCZLinedHashMapNode*)ccz_removeLastNode {
    CCZLinedHashMapNode *last = _last;
    [self ccz_removeNode:_last];
    return last;
}

- (void)ccz_removeAll {
    _count = 0;
    _totalSize = 0;
    _nodes = nil;
    _first = nil;
    _last = nil;
}

@end
