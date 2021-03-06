module UnrealScript.UTGame.UTCTFHUDMessage;

import ScriptClasses;
import UnrealScript.Helpers;
import UnrealScript.UTGame.UTLocalMessage;
import UnrealScript.Core.UObject;
import UnrealScript.Engine.PlayerReplicationInfo;
import UnrealScript.UTGame.UTAnnouncer;

extern(C++) interface UTCTFHUDMessage : UTLocalMessage
{
public extern(D):
	private static __gshared ScriptClass mStaticClass;
	@property final static ScriptClass StaticClass() { mixin(MGSCC("Class UTGame.UTCTFHUDMessage")); }
	private static __gshared UTCTFHUDMessage mDefaultProperties;
	@property final static UTCTFHUDMessage DefaultProperties() { mixin(MGDPC("UTCTFHUDMessage", "UTCTFHUDMessage UTGame.Default__UTCTFHUDMessage")); }
	static struct Functions
	{
		private static __gshared
		{
			ScriptFunction mGetColor;
			ScriptFunction mGetString;
			ScriptFunction mAddAnnouncement;
		}
		public @property static final
		{
			ScriptFunction GetColor() { mixin(MGF("mGetColor", "Function UTGame.UTCTFHUDMessage.GetColor")); }
			ScriptFunction GetString() { mixin(MGF("mGetString", "Function UTGame.UTCTFHUDMessage.GetString")); }
			ScriptFunction AddAnnouncement() { mixin(MGF("mAddAnnouncement", "Function UTGame.UTCTFHUDMessage.AddAnnouncement")); }
		}
	}
	@property final auto ref
	{
		UObject.Color YellowColor() { mixin(MGPC("UObject.Color", 140)); }
		UObject.Color RedColor() { mixin(MGPC("UObject.Color", 136)); }
		ScriptString BothFlagsString() { mixin(MGPC("ScriptString", 124)); }
		ScriptString EnemyHasFlagString() { mixin(MGPC("ScriptString", 112)); }
		ScriptString YouHaveFlagString() { mixin(MGPC("ScriptString", 100)); }
	}
final:
	static UObject.Color GetColor(int* Switch = null, PlayerReplicationInfo* RelatedPRI_1 = null, PlayerReplicationInfo* RelatedPRI_2 = null, UObject* OptionalObject = null)
	{
		ubyte params[20];
		params[] = 0;
		if (Switch !is null)
			*cast(int*)params.ptr = *Switch;
		if (RelatedPRI_1 !is null)
			*cast(PlayerReplicationInfo*)&params[4] = *RelatedPRI_1;
		if (RelatedPRI_2 !is null)
			*cast(PlayerReplicationInfo*)&params[8] = *RelatedPRI_2;
		if (OptionalObject !is null)
			*cast(UObject*)&params[12] = *OptionalObject;
		StaticClass.ProcessEvent(Functions.GetColor, params.ptr, cast(void*)0);
		return *cast(UObject.Color*)&params[16];
	}
	static ScriptString GetString(int* Switch = null, bool* bPRI1HUD = null, PlayerReplicationInfo* RelatedPRI_1 = null, PlayerReplicationInfo* RelatedPRI_2 = null, UObject* OptionalObject = null)
	{
		ubyte params[32];
		params[] = 0;
		if (Switch !is null)
			*cast(int*)params.ptr = *Switch;
		if (bPRI1HUD !is null)
			*cast(bool*)&params[4] = *bPRI1HUD;
		if (RelatedPRI_1 !is null)
			*cast(PlayerReplicationInfo*)&params[8] = *RelatedPRI_1;
		if (RelatedPRI_2 !is null)
			*cast(PlayerReplicationInfo*)&params[12] = *RelatedPRI_2;
		if (OptionalObject !is null)
			*cast(UObject*)&params[16] = *OptionalObject;
		StaticClass.ProcessEvent(Functions.GetString, params.ptr, cast(void*)0);
		return *cast(ScriptString*)&params[20];
	}
	static bool AddAnnouncement(UTAnnouncer Announcer, int MessageIndex, PlayerReplicationInfo* PRI = null, UObject* OptionalObject = null)
	{
		ubyte params[20];
		params[] = 0;
		*cast(UTAnnouncer*)params.ptr = Announcer;
		*cast(int*)&params[4] = MessageIndex;
		if (PRI !is null)
			*cast(PlayerReplicationInfo*)&params[8] = *PRI;
		if (OptionalObject !is null)
			*cast(UObject*)&params[12] = *OptionalObject;
		StaticClass.ProcessEvent(Functions.AddAnnouncement, params.ptr, cast(void*)0);
		return *cast(bool*)&params[16];
	}
}
