module UnrealScript.UTGame.UTAutoCrouchVolume;

import ScriptClasses;
import UnrealScript.Helpers;
import UnrealScript.Engine.Pawn;
import UnrealScript.Engine.Actor;
import UnrealScript.Engine.Volume;

extern(C++) interface UTAutoCrouchVolume : Volume
{
public extern(D):
	private static __gshared ScriptClass mStaticClass;
	@property final static ScriptClass StaticClass() { mixin(MGSCC("Class UTGame.UTAutoCrouchVolume")); }
	private static __gshared UTAutoCrouchVolume mDefaultProperties;
	@property final static UTAutoCrouchVolume DefaultProperties() { mixin(MGDPC("UTAutoCrouchVolume", "UTAutoCrouchVolume UTGame.Default__UTAutoCrouchVolume")); }
	static struct Functions
	{
		private static __gshared
		{
			ScriptFunction mTouch;
			ScriptFunction mSetCrouch;
			ScriptFunction mUnTouch;
			ScriptFunction mCrouchTimer;
		}
		public @property static final
		{
			ScriptFunction Touch() { mixin(MGF("mTouch", "Function UTGame.UTAutoCrouchVolume.Touch")); }
			ScriptFunction SetCrouch() { mixin(MGF("mSetCrouch", "Function UTGame.UTAutoCrouchVolume.SetCrouch")); }
			ScriptFunction UnTouch() { mixin(MGF("mUnTouch", "Function UTGame.UTAutoCrouchVolume.UnTouch")); }
			ScriptFunction CrouchTimer() { mixin(MGF("mCrouchTimer", "Function UTGame.UTAutoCrouchVolume.CrouchTimer")); }
		}
	}
final:
	void Touch(Actor Other, 
// ERROR: Unknown object class 'Class Core.ComponentProperty'!
void* OtherComp, Vector HitLocation, Vector HitNormal)
	{
		ubyte params[32];
		params[] = 0;
		*cast(Actor*)params.ptr = Other;
		*cast(
// ERROR: Unknown object class 'Class Core.ComponentProperty'!
void**)&params[4] = OtherComp;
		*cast(Vector*)&params[8] = HitLocation;
		*cast(Vector*)&params[20] = HitNormal;
		(cast(ScriptObject)this).ProcessEvent(Functions.Touch, params.ptr, cast(void*)0);
	}
	void SetCrouch(Pawn P, ubyte bCrouch)
	{
		ubyte params[5];
		params[] = 0;
		*cast(Pawn*)params.ptr = P;
		params[4] = bCrouch;
		(cast(ScriptObject)this).ProcessEvent(Functions.SetCrouch, params.ptr, cast(void*)0);
	}
	void UnTouch(Actor Other)
	{
		ubyte params[4];
		params[] = 0;
		*cast(Actor*)params.ptr = Other;
		(cast(ScriptObject)this).ProcessEvent(Functions.UnTouch, params.ptr, cast(void*)0);
	}
	void CrouchTimer()
	{
		(cast(ScriptObject)this).ProcessEvent(Functions.CrouchTimer, cast(void*)0, cast(void*)0);
	}
}
