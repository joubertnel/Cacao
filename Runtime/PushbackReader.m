//
//  PushbackReader.m
//  Cacao
//
//    Copyright 2010, Joubert Nel. All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modification, are
//    permitted provided that the following conditions are met:
//
//    1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
//    2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other materials
//    provided with the distribution.
//
//    THIS SOFTWARE IS PROVIDED BY JOUBERT NEL "AS IS'' AND ANY EXPRESS OR IMPLIED
//    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//    FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JOUBERT NEL OR
//    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//    The views and conclusions contained in the software and documentation are those of the
//    authors and should not be interpreted as representing official policies, either expressed
//    or implied, of Joubert Nel.

#import "PushbackReader.h"


@implementation PushbackReader

@synthesize history;
@synthesize stream;


- (unichar)read
{
	if ([self.history count] > 0)
	{
        unichar ch = [[self.history objectAtIndex:0] unsignedShortValue];
        [self.history removeObjectAtIndex:0];
        return ch;
	}
	else {
		uint8_t aChar;
		[stream read:&aChar maxLength:1];      
		return (unichar)aChar;		
	}
}


- (void)unreadSoThatNextCharIs:(unichar)nextChar
{
    [self.history setArray:[NSArray arrayWithObject:[NSNumber numberWithUnsignedShort:nextChar]]];
}

- (void)unreadSoThatNextCharsAre:(NSArray *)nextCharacters
{
    [self.history setArray:nextCharacters];
}

- (id)init:(NSInputStream *)theStream
{
	[super init];
	
	[self setStream:theStream];	
    [self setHistory:[NSMutableArray arrayWithCapacity:1]];
	
	return self;
}


@end
