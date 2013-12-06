//
//  Coroutine.m
//  Sampler
//
//  Created by Jobe,Jason on 12/4/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "objc/runtime.h"
#import "Coroutine.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
    do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
    } while (0);


@interface Coroutine ()
@property (strong, nonatomic) NSMutableDictionary *attributes;
@end

@implementation Coroutine

+ (instancetype)coroutineForTarget:target method:(SEL)method;
{
    Coroutine *cr = [[Coroutine alloc] init];
    cr.target = target;
    cr.method = method;
    return cr;
}

- (void)resume {
    SuppressPerformSelectorLeakWarning ([_target performSelector:_method];)
}

#pragma mark - Dictionary get/set and Subscripting

- (id)objectForKeyedSubscript:(id)key {
    return [self.attributes objectForKeyedSubscript:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    [self.attributes setObject:obj forKeyedSubscript:key];
}

- (id)objectForKey:(id)aKey {
    return [self.attributes objectForKey:aKey];
}

-(void)setObject:anObject forKey:(id <NSCopying>)key {
    [self.attributes setObject:anObject forKey:key];
}

@end


@implementation NSObject (CoroutineCache)

static const char *CoroutineCacheKey = "CoroutineCacheKey";

- (Coroutine*)coroutineForMethod:(SEL)selector
{
    Coroutine *cr = objc_getAssociatedObject(self, CoroutineCacheKey);
    if (cr == nil) {
        cr = [Coroutine coroutineForTarget:self method:selector];
        objc_setAssociatedObject (self, CoroutineCacheKey, cr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cr;
}

- (Coroutine*)releaseCoroutineForMethod:(SEL)selector
{
    Coroutine *cr = objc_getAssociatedObject(self, CoroutineCacheKey);
    if (cr != nil) {
        objc_setAssociatedObject (self, CoroutineCacheKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cr;
}

- (void)resumeCoroutineForMethod:(SEL)methodSelector withValue:value
{
    Coroutine *cr = [self coroutineForMethod:methodSelector];
    cr.continuation_value = value;
    [cr resume];
}

- (void)resumeCoroutineForMethod:(SEL)methodSelector
{
    Coroutine *cr = [self coroutineForMethod:methodSelector];
    cr.continuation_value = nil;
    [cr resume];
}


@end
