module UnrealScript.TribesGame.GFxTrUI_VehicleMenu;

import ScriptClasses;
import UnrealScript.Helpers;
import UnrealScript.UTGame.UTGFxTweenableMoviePlayer;

extern(C++) interface GFxTrUI_VehicleMenu : UTGFxTweenableMoviePlayer
{
public extern(D):
	private static __gshared ScriptClass mStaticClass;
	@property final static ScriptClass StaticClass() { mixin(MGSCC("Class TribesGame.GFxTrUI_VehicleMenu")); }
	private static __gshared GFxTrUI_VehicleMenu mDefaultProperties;
	@property final static GFxTrUI_VehicleMenu DefaultProperties() { mixin(MGDPC("GFxTrUI_VehicleMenu", "GFxTrUI_VehicleMenu TribesGame.Default__GFxTrUI_VehicleMenu")); }
	static struct Functions
	{
		private static __gshared
		{
			ScriptFunction mStart;
			ScriptFunction mConfigureOptions;
			ScriptFunction mVehicleOptionsComplete;
			ScriptFunction mVehicleOptionsClear;
			ScriptFunction mSetVehicleOption;
			ScriptFunction mGetSelectedVehicle;
			ScriptFunction mOnVehicleScreenFinished;
		}
		public @property static final
		{
			ScriptFunction Start() { mixin(MGF("mStart", "Function TribesGame.GFxTrUI_VehicleMenu.Start")); }
			ScriptFunction ConfigureOptions() { mixin(MGF("mConfigureOptions", "Function TribesGame.GFxTrUI_VehicleMenu.ConfigureOptions")); }
			ScriptFunction VehicleOptionsComplete() { mixin(MGF("mVehicleOptionsComplete", "Function TribesGame.GFxTrUI_VehicleMenu.VehicleOptionsComplete")); }
			ScriptFunction VehicleOptionsClear() { mixin(MGF("mVehicleOptionsClear", "Function TribesGame.GFxTrUI_VehicleMenu.VehicleOptionsClear")); }
			ScriptFunction SetVehicleOption() { mixin(MGF("mSetVehicleOption", "Function TribesGame.GFxTrUI_VehicleMenu.SetVehicleOption")); }
			ScriptFunction GetSelectedVehicle() { mixin(MGF("mGetSelectedVehicle", "Function TribesGame.GFxTrUI_VehicleMenu.GetSelectedVehicle")); }
			ScriptFunction OnVehicleScreenFinished() { mixin(MGF("mOnVehicleScreenFinished", "Function TribesGame.GFxTrUI_VehicleMenu.OnVehicleScreenFinished")); }
		}
	}
final:
	bool Start(bool* StartPaused = null)
	{
		ubyte params[8];
		params[] = 0;
		if (StartPaused !is null)
			*cast(bool*)params.ptr = *StartPaused;
		(cast(ScriptObject)this).ProcessEvent(Functions.Start, params.ptr, cast(void*)0);
		return *cast(bool*)&params[4];
	}
	void ConfigureOptions(ScriptClass FamilyInfo)
	{
		ubyte params[4];
		params[] = 0;
		*cast(ScriptClass*)params.ptr = FamilyInfo;
		(cast(ScriptObject)this).ProcessEvent(Functions.ConfigureOptions, params.ptr, cast(void*)0);
	}
	void VehicleOptionsComplete(int Credits)
	{
		ubyte params[4];
		params[] = 0;
		*cast(int*)params.ptr = Credits;
		(cast(ScriptObject)this).ProcessEvent(Functions.VehicleOptionsComplete, params.ptr, cast(void*)0);
	}
	void VehicleOptionsClear()
	{
		(cast(ScriptObject)this).ProcessEvent(Functions.VehicleOptionsClear, cast(void*)0, cast(void*)0);
	}
	void SetVehicleOption(ScriptString ClassName, ScriptString DisplayName, int Cost, int nIconIndex)
	{
		ubyte params[32];
		params[] = 0;
		*cast(ScriptString*)params.ptr = ClassName;
		*cast(ScriptString*)&params[12] = DisplayName;
		*cast(int*)&params[24] = Cost;
		*cast(int*)&params[28] = nIconIndex;
		(cast(ScriptObject)this).ProcessEvent(Functions.SetVehicleOption, params.ptr, cast(void*)0);
	}
	ScriptString GetSelectedVehicle()
	{
		ubyte params[12];
		params[] = 0;
		(cast(ScriptObject)this).ProcessEvent(Functions.GetSelectedVehicle, params.ptr, cast(void*)0);
		return *cast(ScriptString*)params.ptr;
	}
	void OnVehicleScreenFinished()
	{
		(cast(ScriptObject)this).ProcessEvent(Functions.OnVehicleScreenFinished, cast(void*)0, cast(void*)0);
	}
}
