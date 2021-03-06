
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "XMutableURLRequest.h"
#import <XFace/XUtils.h>

//TODO:状态非法的回调
#define checkState(state)\
if(self.readyState != state)\
{\
    return;\
}\

enum {
    UNSENT,
    OPENED,
    HEADERS_RECEIVED,
    LOADING,
    DONE
} _State;

/**
   ajax的错误码
 */
 enum ErrorCode {
     INVALID_STATE_ERR,
     INVALID_HEADER_VALUE,
     METHOD_NOT_SUPPORT,
     HTTP_REQUEST_ERROR
} _ErrorCode;

enum {
    ONABORT,
    ONERROR,
    ONLOADSTART,
    ONPROGRESS,
    ONLOAD,
    ONLOADEND,
    ONTIMEOUT
} _EventType;

typedef uint EventType;

static NSArray* errorMsg;

@implementation XMutableURLRequest

+(void)initialize
{
    errorMsg = @[@"Invalid status",
                 @"Invalid header value",
                 @"Not spport method",
                 @"Network error"];
}

- (void)open:(NSString*)method url:(NSString*)url
{
    self.readyState = OPENED;
    //TODO: 检查method的有效性
    [self setHTTPMethod:method];
    [self setURL:[NSURL URLWithString:url]];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    checkState(OPENED)
    //TODO: 检查header新值的合法性和安全性
    [super setValue:value forHTTPHeaderField:field];
}

- (void)sendData:(id)data
{
    checkState(OPENED)

    if(![[self HTTPMethod] isEqualToString: @"GET"] && ![[self HTTPMethod] isEqualToString: @"HEAD"])
    {
        NSData* rawData = nil;
        if ([data isKindOfClass:[NSString class]]) {
            rawData = [data dataUsingEncoding:NSUTF8StringEncoding];
            //TODO:支持其他类型的数据
        }
        [self setHTTPBody:rawData];
    }

    _theConnection = [[NSURLConnection alloc] initWithRequest:self delegate:self];

    if (_theConnection) {
        _data = [NSMutableData data];
        [self fireEvent:ONLOADSTART];
    }
}

- (void)abort
{
    [_theConnection cancel];
    _readyState = UNSENT;
    [self fireEvent:ONABORT];
    [self fireEvent:ONLOADEND];
}

- (void)setReadyState:(State)readyState
{
    if (readyState != _readyState) {
        _readyState = readyState;
        [self readyStateDIdChange];
    }
}

#pragma mark - private api

- (void)fireEvent:(EventType)eventType
{
    self.errorCallBack([self errorObjectForEvent:eventType]);
}

-(NSDictionary*) errorObjectForEvent:(EventType)eventType
{
    NSMutableDictionary* errorObject = [NSMutableDictionary dictionaryWithDictionary:[self ajaxObject]];
    [errorObject setObject:@(eventType) forKey:@"eventType"];
    return errorObject;
}

-(NSDictionary*) ajaxObject
{
    NSDictionary* ajaxObject =
    @{@"status"        :   @(self.status),
      @"readyState"    :   @(self.readyState),
      @"responseText"  :   CAST_TO_NSNULL_IF_NIL(self.responseText),
      @"headers"       :   CAST_TO_NSNULL_IF_NIL([_response allHeaderFields])};
    return ajaxObject;
}

- (void)readyStateDIdChange
{
    self.successCallBack([self ajaxObject]);
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = (NSHTTPURLResponse*)response;
    self.status = _response.statusCode;
    self.readyState = HEADERS_RECEIVED;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //TODO:如果是timemout，fire timeout 事件
    self.status = error.code;
    self.readyState = DONE;
    [self fireEvent:ONERROR];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
    self.readyState = LOADING;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.responseText = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    self.readyState = DONE;
    [self fireEvent:ONLOAD];
    [self fireEvent:ONLOADEND];
}

- (void)dealloc
{
    [_theConnection cancel];
}

@end
