//
//  CacaoEnvironment.h
//  Cacao
//
//  Created by Joubert Nel on 11/13/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "sqlite3.h"

#import "CacaoFn.h"
#import "CacaoNil.h"
#import "CacaoSymbol.h"
#import "CacaoVector.h"
#import "NSArray+Functional.h"
#import "CacaoNilNotCallableException.h"
#import "CacaoSymbolNotFoundException.h"


@interface CacaoEnvironment : NSObject {
    NSMutableDictionary * mappingTable;
    CacaoEnvironment * outer;
}

@property (nonatomic, retain) NSMutableDictionary * mappingTable;
@property (nonatomic, retain) CacaoEnvironment * outer;

+ (CacaoEnvironment *)environmentWith:(NSDictionary *)paramsAndArgs outerEnvironment:(CacaoEnvironment *)theOuter;
+ (CacaoEnvironment *)environmentFromVector:(CacaoVector *)bindings 
                           outerEnvironment:(CacaoEnvironment *)theOuter;
+ (CacaoEnvironment *)globalEnvironment;
- (CacaoEnvironment *)find:(id)theVar;
- (id)getMappingValue:(id)theVar;
- (void)setVar:(id)theVar to:(id)theValue;


+ (id)eval:(id)expression inEnvironment:(CacaoEnvironment *)env;



@end
