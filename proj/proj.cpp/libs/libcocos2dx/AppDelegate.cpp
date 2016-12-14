
#include "AppDelegate.h"
#include "SimpleAudioEngine.h"
#include "CCLuaEngine.h"

#include "lua_module_register.h"

USING_NS_CC;
using namespace CocosDenshion;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = { 8, 8, 8, 8, 24, 8 };

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if(!glview) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
        extern void createSimulator(const char* viewName, float width, float height, bool isLandscape = true, float frameZoomFactor = 1.0f);
        createSimulator("QuickV6", 960, 640, true);
#else
        glview = cocos2d::GLViewImpl::createWithRect("QuickV6", Rect(0, 0, 960, 640));
        director->setOpenGLView(glview);
#endif
        director->startAnimation();
    }

    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();

    // lua module
    lua_module_register(L);

    engine->getLuaStack()->setXXTEAKeyAndSign("QuickV6", strlen("QuickV6"), "XT", strlen("XT"));

    // load script
    string env = "";

#if COCOS2D_DEBUG
    env.append("COCOS2D_DEBUG    = 1                                                            \n");
#endif

#if CC_USE_CURL
    env.append("CC_USE_CURL      = 1                                                            \n");
#endif
#if CC_USE_SOCKET
    env.append("CC_USE_SOCKET    = 1                                                            \n");
#endif
#if CC_USE_WEBSOCKET
    env.append("CC_USE_WEBSOCKET = 1                                                            \n");
#endif
#if CC_USE_SFS2XAPI
    env.append("CC_USE_SFS2XAPI  = 1                                                            \n");
#endif
#if CC_USE_SQLITE
    env.append("CC_USE_SQLITE    = 1                                                            \n");
#endif
#if CC_USE_CCSTUDIO
    env.append("CC_USE_CCSTUDIO  = 1                                                            \n");
#endif
#if CC_USE_SPINE
    env.append("CC_USE_SPINE     = 1                                                            \n");
#endif
#if CC_USE_PHYSICS
    env.append("CC_USE_PHYSICS   = 1                                                            \n");
#endif
#if CC_USE_TMX
    env.append("CC_USE_TMX       = 1                                                            \n");
#endif
#if CC_USE_FILTER
    env.append("CC_USE_FILTER    = 1                                                            \n");
#endif
#if CC_USE_NANOVG
    env.append("CC_USE_NANOVG    = 1                                                            \n");
#endif

    engine->executeString(env.c_str());

    // load script
    engine->executeString("print 'loading src/main.lua'");
    engine->executeScriptFile("src/main.lua");

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    Director::getInstance()->pause();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();

    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_BACKGROUND_EVENT");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->resume();
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();

    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_FOREGROUND_EVENT");
}
