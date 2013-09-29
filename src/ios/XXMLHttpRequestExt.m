
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

#import "XXMLHttpRequestExt.h"
#import "XMutableURLRequest.h"
#import <Cordova/CDVInvokedUrlCommand.h>
#import <Cordova/CDVPluginResult.h>
#import <Cordova/NSArray+Comparisons.h>

@implementation XXMLHttpRequestExt

- (id)initWithWebView:(UIWebView*)theWebView
{
    self = [super initWithWebView:theWebView];
    if (self) {
        _requests = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (void)open:(CDVInvokedUrlCommand*)command
{
    NSString* requestId = [command.arguments objectAtIndex:0];
    NSString* method = [command.arguments objectAtIndex:1];
    NSString* url = [command.arguments objectAtIndex:2];

    //TODO: set timeout
    XMutableURLRequest *newRequest = [XMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    newRequest.Id = requestId;

    //成功回调返回ajax的js对象
    newRequest.successCallBack = ^(NSDictionary* ajaxObject)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:ajaxObject];
        [result setKeepCallbackAsBool:YES];

        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

    };

    newRequest.errorCallBack = ^(NSDictionary* error)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error];
        [result setKeepCallbackAsBool:YES];

        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    };
    [_requests setObject:newRequest forKey:requestId];

    [newRequest open:method url:url];
}

- (void)send:(CDVInvokedUrlCommand*)command
{
    NSString* requestId = [command.arguments objectAtIndex:0];
    NSString* data = [command.arguments objectAtIndex:1 withDefault:nil];
    XMutableURLRequest* request = [_requests objectForKey:requestId];
    [request sendData:data];
}

- (void)setRequestHeader:(CDVInvokedUrlCommand*)command
{
    NSString* requestId = [command.arguments objectAtIndex:0];
    NSString* field     = [command.arguments objectAtIndex:1];
    NSString* value     = [command.arguments objectAtIndex:2];

    XMutableURLRequest* request = [_requests objectForKey:requestId];
    [request setValue:value forHTTPHeaderField:field];

}

- (void)abort:(CDVInvokedUrlCommand*)command
{
    NSString* requestId = [command.arguments objectAtIndex:0];
    XMutableURLRequest* request = [_requests objectForKey:requestId];
    [request abort];
}

- (void) onPageStarted:(NSString*)appId
{
    [_requests removeAllObjects];
}

@end

