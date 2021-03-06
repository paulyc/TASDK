module UnrealScript.TribesGame.TrPartySettings;

import ScriptClasses;
import UnrealScript.Helpers;
import UnrealScript.Engine.OnlineGameSettings;
import UnrealScript.Engine.OnlineSubsystem;
import UnrealScript.Engine.LocalPlayer;

extern(C++) interface TrPartySettings : OnlineGameSettings
{
public extern(D):
	private static __gshared ScriptClass mStaticClass;
	@property final static ScriptClass StaticClass() { mixin(MGSCC("Class TribesGame.TrPartySettings")); }
	private static __gshared TrPartySettings mDefaultProperties;
	@property final static TrPartySettings DefaultProperties() { mixin(MGDPC("TrPartySettings", "TrPartySettings TribesGame.Default__TrPartySettings")); }
	static struct Functions
	{
		private static __gshared
		{
			ScriptFunction mInit;
			ScriptFunction mClose;
			ScriptFunction mOnLoginChange;
			ScriptFunction mRefreshMembersList;
		}
		public @property static final
		{
			ScriptFunction Init() { mixin(MGF("mInit", "Function TribesGame.TrPartySettings.Init")); }
			ScriptFunction Close() { mixin(MGF("mClose", "Function TribesGame.TrPartySettings.Close")); }
			ScriptFunction OnLoginChange() { mixin(MGF("mOnLoginChange", "Function TribesGame.TrPartySettings.OnLoginChange")); }
			ScriptFunction RefreshMembersList() { mixin(MGF("mRefreshMembersList", "Function TribesGame.TrPartySettings.RefreshMembersList")); }
		}
	}
	@property final auto ref
	{
		ScriptArray!(OnlineSubsystem.OnlinePartyMember) MemberList() { mixin(MGPC("ScriptArray!(OnlineSubsystem.OnlinePartyMember)", 184)); }
		// ERROR: Unsupported object class 'InterfaceProperty' for the property named 'PlayerInterface'!
		OnlineSubsystem OnlineSub() { mixin(MGPC("OnlineSubsystem", 172)); }
	}
final:
	void Init(LocalPlayer InPlayer)
	{
		ubyte params[4];
		params[] = 0;
		*cast(LocalPlayer*)params.ptr = InPlayer;
		(cast(ScriptObject)this).ProcessEvent(Functions.Init, params.ptr, cast(void*)0);
	}
	void Close()
	{
		(cast(ScriptObject)this).ProcessEvent(Functions.Close, cast(void*)0, cast(void*)0);
	}
	void OnLoginChange(ubyte LocalUserNum)
	{
		ubyte params[1];
		params[] = 0;
		params[0] = LocalUserNum;
		(cast(ScriptObject)this).ProcessEvent(Functions.OnLoginChange, params.ptr, cast(void*)0);
	}
	void RefreshMembersList()
	{
		(cast(ScriptObject)this).ProcessEvent(Functions.RefreshMembersList, cast(void*)0, cast(void*)0);
	}
}
