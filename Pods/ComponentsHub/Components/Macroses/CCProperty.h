//
//  NSObject+Property.h
//
//  Created by Ivan Zezyulya on 20.04.12.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


#define CC_IMPLEMENT_PROPERTY(type, Name, name, assocPolicy)                \
                                                                            \
- (void)set##Name:(type)value                                               \
{                                                                           \
    objc_setAssociatedObject(self, @selector(name), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);        \
}                                                                           \
                                                                            \
- (type)name                                                                \
{                                                                           \
    return objc_getAssociatedObject(self, @selector(name));                 \
}
