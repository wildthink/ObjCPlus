//
//  Coroutine.h
//  Sampler
//
//  Created by Jobe,Jason on 12/4/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coroutine : NSObject

@property (nonatomic) char *goto_name;
@property (nonatomic) void *goto_address;

@property (nonatomic)id target;
@property (nonatomic)  SEL method;
@property (nonatomic) id continuation_value;

+ (instancetype)coroutineForTarget:target method:(SEL)method;

- objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

- objectForKey:(id)aKey;
-(void)setObject:anObject forKey:(id <NSCopying>)key;

@end

@interface NSObject (CoroutineCache)

- (Coroutine*)coroutineForMethod:(SEL)selector;
- (Coroutine*)releaseCoroutineForMethod:(SEL)selector;

- (void)resumeCoroutineForMethod:(SEL)methodSelector withValue:value;
- (void)resumeCoroutineForMethod:(SEL)methodSelector;

@end



#define BEGIN_COROUTINE() \
    Coroutine *__crx = [self coroutineForMethod:_cmd]; \
    void *__goto_tag = __crx.goto_address; \
    if (__goto_tag != NULL) goto *(__goto_tag);

#define END_COROUTINE() [self releaseCoroutineForMethod:_cmd]

#define RETURN_VALUE __crx.continuation_value

#define RESUME(_target, _method, ...) [\
    [_target resumeCoroutineForMethod:@selector(_method)] withValue:__VA_ARGS__]; \
    [_target _method]

#define TOKENPASTE(x, y) x ## y
#define TOKENPASTE2(x, y) TOKENPASTE(x, y)

#define YIELD(...) \
    __goto_tag = && TOKENPASTE2(L_, __LINE__); __crx.goto_address = __goto_tag; \
    return __VA_ARGS__; \
    TOKENPASTE2(L_, __LINE__):

#define YIELD_RETURNING(_return_value) YIELD(); continuation_value = RETURN_VALUE

