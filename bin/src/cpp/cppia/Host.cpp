// Generated by Haxe 4.0.5
#include <hxcpp.h>

#ifndef INCLUDED_cpp_cppia_Host
#include <cpp/cppia/Host.h>
#endif
#ifndef INCLUDED_haxe_io_Bytes
#include <haxe/io/Bytes.h>
#endif
#ifndef INCLUDED_sys_io_File
#include <sys/io/File.h>
#endif
#include <hx/Scriptable.h>

HX_LOCAL_STACK_FRAME(_hx_pos_9d6ec36837266167_43_runFile,"cpp.cppia.Host","runFile",0x3aa8557f,"cpp.cppia.Host.runFile","/home/kaiz0r/haxe/std/cpp/cppia/Host.hx",43,0x1442aaa6)
namespace cpp{
namespace cppia{

void Host_obj::__construct() { }

Dynamic Host_obj::__CreateEmpty() { return new Host_obj; }

void *Host_obj::_hx_vtable = 0;

Dynamic Host_obj::__Create(hx::DynamicArray inArgs)
{
	hx::ObjectPtr< Host_obj > _hx_result = new Host_obj();
	_hx_result->__construct();
	return _hx_result;
}

bool Host_obj::_hx_isInstanceOf(int inClassId) {
	return inClassId==(int)0x00000001 || inClassId==(int)0x51eac280;
}

void Host_obj::runFile(::String filename){
            	HX_STACKFRAME(&_hx_pos_9d6ec36837266167_43_runFile)
HXLINE(  44)		 ::haxe::io::Bytes source = ::sys::io::File_obj::getBytes(filename);
HXLINE(  45)		 hx::CppiaLoadedModule module = __scriptable_cppia_from_data(source->b);
HXLINE(  46)		module->boot();
HXLINE(  47)		module->run();
            	}


STATIC_HX_DEFINE_DYNAMIC_FUNC1(Host_obj,runFile,(void))


Host_obj::Host_obj()
{
}

bool Host_obj::__GetStatic(const ::String &inName, Dynamic &outValue, hx::PropertyAccess inCallProp)
{
	switch(inName.length) {
	case 7:
		if (HX_FIELD_EQ(inName,"runFile") ) { outValue = runFile_dyn(); return true; }
	}
	return false;
}

#ifdef HXCPP_SCRIPTABLE
static hx::StorageInfo *Host_obj_sMemberStorageInfo = 0;
static hx::StaticInfo *Host_obj_sStaticStorageInfo = 0;
#endif

class Host_obj__scriptable : public Host_obj {
   typedef Host_obj__scriptable __ME;
   typedef Host_obj super;
   typedef Host_obj __superString;
   HX_DEFINE_SCRIPTABLE(HX_ARR_LIST0)
	HX_DEFINE_SCRIPTABLE_DYNAMIC;
};


static void CPPIA_CALL __s_runFile(hx::CppiaCtx *ctx) {
Host_obj::runFile(ctx->getString(sizeof(void*)));
}
#ifndef HXCPP_CPPIA_SUPER_ARG
#define HXCPP_CPPIA_SUPER_ARG(x)
#endif
static hx::ScriptNamedFunction __scriptableFunctions[] = {
  hx::ScriptNamedFunction("runFile",__s_runFile,"vs", true HXCPP_CPPIA_SUPER_ARG(0) ),
  hx::ScriptNamedFunction(0,0,0 HXCPP_CPPIA_SUPER_ARG(0) ) };
hx::Class Host_obj::__mClass;

hx::ScriptFunction Host_obj::__script_construct(0,0);
static ::String Host_obj_sStaticFields[] = {
	HX_("runFile",67,e3,f8,d0),
	::String(null())
};

void Host_obj::__register()
{
	Host_obj _hx_dummy;
	Host_obj::_hx_vtable = *(void **)&_hx_dummy;
	hx::Static(__mClass) = new hx::Class_obj();
	__mClass->mName = HX_("cpp.cppia.Host",86,fa,b7,e8);
	__mClass->mSuper = &super::__SGetClass();
	__mClass->mConstructEmpty = &__CreateEmpty;
	__mClass->mConstructArgs = &__Create;
	__mClass->mGetStaticField = &Host_obj::__GetStatic;
	__mClass->mSetStaticField = &hx::Class_obj::SetNoStaticField;
	__mClass->mStatics = hx::Class_obj::dupFunctions(Host_obj_sStaticFields);
	__mClass->mMembers = hx::Class_obj::dupFunctions(0 /* sMemberFields */);
	__mClass->mCanCast = hx::TCanCast< Host_obj >;
#ifdef HXCPP_SCRIPTABLE
	__mClass->mMemberStorageInfo = Host_obj_sMemberStorageInfo;
#endif
#ifdef HXCPP_SCRIPTABLE
	__mClass->mStaticStorageInfo = Host_obj_sStaticStorageInfo;
#endif
	hx::_hx_RegisterClass(__mClass->mName, __mClass);
  HX_SCRIPTABLE_REGISTER_CLASS("cpp.cppia.Host",Host_obj);
}

} // end namespace cpp
} // end namespace cppia