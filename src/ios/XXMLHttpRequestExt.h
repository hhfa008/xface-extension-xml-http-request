
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

#import <XFace/CDVPlugin+XPlugin.h>

@class XMutableURLRequest;

@interface XXMLHttpRequestExt : CDVPlugin
{
    NSMutableDictionary* _requests;
}

/*
    打开ajax请求
    @param arguments
    - 0 id     ajax的标识符
    - 1 method 操作类型，post或者get
    - 2 url    链接地址
 */
- (void)open:(CDVInvokedUrlCommand*)command;

/*
    发送ajax请求
    @param arguments
    - 0 id     ajax的标识符
    - 1 data   待发送的数据
 */
- (void)send:(CDVInvokedUrlCommand*)command;

/*
    设置http头部
    @param arguments
    - 0 id       ajax的标识符
    - 1 field    数据域
    - 2 value    数据域的新值
 */
- (void)setRequestHeader:(CDVInvokedUrlCommand*)command;

/*
    停止请求
    @param arguments
    - 0 id       ajax的标识符
 */
- (void)abort:(CDVInvokedUrlCommand*)command;

@end
