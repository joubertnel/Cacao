//
//  CacaoQuotedForm.m
//  Cacao
//
//  Created by Joubert Nel on 1/4/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import "CacaoQuotedForm.h"


@implementation CacaoQuotedForm

@synthesize form;

- (NSString *)printable
{
    return [form printable];
}

- (BOOL)isEqual:(id)object
{    
    if ([object isKindOfClass:[CacaoQuotedForm class]])
        return [self.form isEqual:[(CacaoQuotedForm *)object form]];
    else
        return NO;
}

@end
