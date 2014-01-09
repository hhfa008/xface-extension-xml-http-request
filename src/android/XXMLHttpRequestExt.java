
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

package com.polyvi.xface.extension.xmlhttprequest;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

public class XXMLHttpRequestExt extends CordovaPlugin {
    private static final String CLASS_NAME = XXMLHttpRequestExt.class
                .getSimpleName();

    private static final String COMMAND_OPEN = "open";
    private static final String COMMAND_SEND = "send";
    private static final String COMMAND_SET_REQUEST_HEADER = "setRequestHeader";
    private static final String COMMAND_ABORT = "abort";

    private XXMLHttpRequestContainer mAjaxContainer;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        mAjaxContainer = new XXMLHttpRequestContainer(this.cordova.getActivity());
    }

    @Override
    public boolean execute(String action, JSONArray args,
            CallbackContext callbackCtx) throws JSONException {
        String xhrId = args.getString(0);
        XXMLHttpRequest request = mAjaxContainer.getXMLRequestObj(xhrId);
        XAjaxRequestListener requestListener = request.getRequestListener();
        if (null == requestListener) {
            XAjaxRequestListener listener = new XAjaxRequestListener(callbackCtx);
            request.setRequestListener(listener);
        }
        try {
            if (action.equals(COMMAND_OPEN)) {
                String method = args.getString(1);
                String url = args.getString(2);
                request.open(method, url);
                return true;
            } else if (action.equals(COMMAND_SEND)) {
                String data = args.getString(1);
                request.send(data);
                return true;
            } else if (action.equals(COMMAND_ABORT)) {
                request.abort();
                return true;
            } else if (action.equals(COMMAND_SET_REQUEST_HEADER)) {
                String name = args.getString(1);
                String value = args.getString(2);
                request.setRequestHeader(name, value);
                return true;
            }
        } catch (XAjaxException e) {
            Log.e(CLASS_NAME, e.getMessage());
            // FIXME:需要让js层扔出异常
            return false;
        }
        return false;
    }

    @Override
    public void onReset() {
        // 页面切换需要清除所有的ajax对象 否则可能导致内存泄露
        mAjaxContainer.removeAllRequestObj();
    }

}