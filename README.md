ObjCPlus
========

"Extensions" for Objective-C - Coroutines, User Literals, Autoboxing

## Overview
I was recently reading about an interesting way to extend the literal syntax and autoboxing of Objective-C. The article, [OCUDL In Depth](http://www.dbachrach.com/posts/ocudl-in-depth/) by Dustin Bachrach got me thinking. I enjoy the clarity and succinctness of the standard literal syntax but like Dustin am disappointed with its completeness (or lack thereof).

I have also been intrigued by the addition of User Defined Literals in the latest [C++11](http://en.cppreference.com/w/cpp/language/user_literal). Adopting Objective-C++ to pull this in can be interesting as we will see in a bit. But before diving into C++ we should consider another option.

Clang now supports overloaded functions in C. Its not automatic but is made available with the addtion of a llvm annotation.

### Literal Syntax

### Autoboxing
	int i = 23;
	char *cstr = "A c-string";
	
	NSNumber *num = @(i);
	NSString *str = @(cstr);

But annoyingly, autoboxing an `id` or other ObjC instance results in an exception. It also only works on basic literals and is not extensible.

The standard system falls short on a number of points.

* You can't box Objective C objects - trying to do so raises an exception.
* Nothing can be done with nil / Nil
* Structures and supported
* It isn't user extensible.

see <http://clang.llvm.org/docs/ObjectiveCLiterals.html>

### Autoboxing - new and improved

	NSRect rect = NSZeroRect;
	NSValue *value = $(rect);
	
	NSValue* __attribute__((overloadable)) box(NSRect rect) { 
		return [NSValue valueWithRect:rect];
	}

### Literals++
[Using the C++ Literal Syntax](http://www.preney.ca/paul/archives/636)

<http://www.preney.ca/paul/archives/636>

	inline NSURL *operator "" _url(const char *url_s, std::size_t len) {
	    return [NSURL URLWithString:@(url_s)];
	}


### Coroutines
	-(void)alert
	{
	    id result;
	    BEGIN_COROUTINE();
	    
	    [[[UIAlertView alloc] initWithTitle:@"Alert One"
	                                message:@"This is a message"
	                               delegate:self
	                      cancelButtonTitle:@"Cancel"
	                      otherButtonTitles:@"OK", nil]
	     show];
	    
	    YIELD();
	    result = RETURN_VALUE;
	    
	    NSLog(@"Alert returns %@", result);
	    
	    [[[UIAlertView alloc] initWithTitle:@"Alert Two"
	                                message:@"This is a message"
	                               delegate:self
	                      cancelButtonTitle:@"Cancel"
	                      otherButtonTitles:@"OK", nil]
	     show];
	    
	    YIELD();
	    result = RETURN_VALUE;
	    
	    NSLog(@"Alert returns %@", result);
	    
	    END_COROUTINE();
	}
	
	- (void)alertView:(UIAlertView *)alertView 		didDismissWithButtonIndex:(NSInteger)buttonIndex
	{
	    [self resumeCoroutineForMethod:@selector(alert) 		returnValue:@(buttonIndex)];
	}