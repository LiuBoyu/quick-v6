LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared
LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := src/main.cpp \
                   ../../../../proj.cpp/libs/libcocos2dx/AppDelegate.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../../proj.cpp/libs/libcocos2dx \
                    $(COCOS2DX_ROOT)/quick/lib/quick-src/extra \
                    $(COCOS2DX_ROOT)/quick/lib/quick-src \
                    $(COCOS2DX_ROOT)/external

LOCAL_STATIC_LIBRARIES := lua_extensions_static
LOCAL_STATIC_LIBRARIES += extra_static
LOCAL_STATIC_LIBRARIES += cocos2d_lua_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module, quick/lib/quick-src/lua_extensions)
$(call import-module, quick/lib/quick-src/extra)
$(call import-module, cocos/scripting/lua-bindings/proj.android)
