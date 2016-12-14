NDK_TOOLCHAIN_VERSION := clang

APP_PLATFORM := android-15

APP_STL := gnustl_static
APP_LDFLAGS := -latomic

APP_CPPFLAGS := -frtti -std=c++11 -fsigned-char
APP_CFLAGS   :=

ifeq ($(NDK_DEBUG), 1)
    APP_CPPFLAGS += -DDEBUG -DCOCOS2D_DEBUG=1
    APP_OPTIM := debug
else
    APP_CPPFLAGS += -DNDEBUG
    APP_OPTIM := release
endif

APP_CPPFLAGS += -DCC_LUA_ENGINE_ENABLED=1

CC_USE_CURL := 1
CC_USE_SOCKET := 1
CC_USE_WEBSOCKET := 1
CC_USE_SFS2XAPI := 1
CC_USE_SQLITE := 1
CC_USE_CCSTUDIO := 1
CC_USE_SPINE := 0
CC_USE_PHYSICS := 1
CC_USE_TMX := 1
CC_USE_FILTER := 1
CC_USE_NANOVG := 1

ifeq ($(CC_USE_CURL), 1)
    APP_CPPFLAGS += -DCC_USE_CURL=1
    APP_CFLAGS   += -DCC_USE_CURL=1
endif
ifeq ($(CC_USE_SOCKET), 1)
    APP_CPPFLAGS += -DCC_USE_SOCKET=1
    APP_CFLAGS   += -DCC_USE_SOCKET=1
endif
ifeq ($(CC_USE_WEBSOCKET), 1)
    APP_CPPFLAGS += -DCC_USE_WEBSOCKET=1
    APP_CFLAGS   += -DCC_USE_WEBSOCKET=1
endif
ifeq ($(CC_USE_SFS2XAPI), 1)
    APP_CPPFLAGS += -DCC_USE_SFS2XAPI=1
    APP_CFLAGS   += -DCC_USE_SFS2XAPI=1
endif
ifeq ($(CC_USE_SQLITE), 1)
    APP_CPPFLAGS += -DCC_USE_SQLITE=1
    APP_CFLAGS   += -DCC_USE_SQLITE=1
endif

ifeq ($(CC_USE_CCSTUDIO), 1)
    APP_CPPFLAGS += -DCC_USE_CCSTUDIO=1
endif
ifeq ($(CC_USE_SPINE), 1)
    APP_CPPFLAGS += -DCC_USE_SPINE=1
endif

ifeq ($(CC_USE_PHYSICS), 1)
    APP_CPPFLAGS += -DCC_USE_PHYSICS=1
    APP_CPPFLAGS += -DCC_ENABLE_CHIPMUNK_INTEGRATION=1
endif
ifeq ($(CC_USE_TMX), 1)
    APP_CPPFLAGS += -DCC_USE_TMX=1
endif
ifeq ($(CC_USE_FILTER), 1)
    APP_CPPFLAGS += -DCC_USE_FILTER=1
endif
ifeq ($(CC_USE_NANOVG), 1)
    APP_CPPFLAGS += -DCC_USE_NANOVG=1
endif

$(info APP_PLATFORM = $(APP_PLATFORM))
$(info APP_CPPFLAGS = $(APP_CPPFLAGS))
