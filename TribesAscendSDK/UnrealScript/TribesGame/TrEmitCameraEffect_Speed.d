module UnrealScript.TribesGame.TrEmitCameraEffect_Speed;

import ScriptClasses;
import UnrealScript.Helpers;
import UnrealScript.UDKBase.UDKEmitCameraEffect;
import UnrealScript.Engine.SoundCue;

extern(C++) interface TrEmitCameraEffect_Speed : UDKEmitCameraEffect
{
public extern(D):
	private static __gshared ScriptClass mStaticClass;
	@property final static ScriptClass StaticClass() { mixin(MGSCC("Class TribesGame.TrEmitCameraEffect_Speed")); }
	private static __gshared TrEmitCameraEffect_Speed mDefaultProperties;
	@property final static TrEmitCameraEffect_Speed DefaultProperties() { mixin(MGDPC("TrEmitCameraEffect_Speed", "TrEmitCameraEffect_Speed TribesGame.Default__TrEmitCameraEffect_Speed")); }
	static struct Functions
	{
		private static __gshared
		{
			ScriptFunction mUpdateLocation;
			ScriptFunction mActivate;
			ScriptFunction mDeactivate;
		}
		public @property static final
		{
			ScriptFunction UpdateLocation() { mixin(MGF("mUpdateLocation", "Function TribesGame.TrEmitCameraEffect_Speed.UpdateLocation")); }
			ScriptFunction Activate() { mixin(MGF("mActivate", "Function TribesGame.TrEmitCameraEffect_Speed.Activate")); }
			ScriptFunction Deactivate() { mixin(MGF("mDeactivate", "Function TribesGame.TrEmitCameraEffect_Speed.Deactivate")); }
		}
	}
	@property final
	{
		auto ref
		{
			float m_fFadeOutWeatherSoundTime() { mixin(MGPC("float", 512)); }
			float m_fFadeInWeatherSoundTime() { mixin(MGPC("float", 508)); }
			SoundCue m_WeatherSound() { mixin(MGPC("SoundCue", 504)); }
			// ERROR: Unsupported object class 'ComponentProperty' for the property named 'm_WeatherAC'!
		}
		bool m_bUpdateLocationBasedOnVelocity() { mixin(MGBPC(496, 0x2)); }
		bool m_bUpdateLocationBasedOnVelocity(bool val) { mixin(MSBPC(496, 0x2)); }
		bool m_bUpdateRotation() { mixin(MGBPC(496, 0x1)); }
		bool m_bUpdateRotation(bool val) { mixin(MSBPC(496, 0x1)); }
	}
final:
	void UpdateLocation(ref in Vector CamLoc, ref in Rotator CamRot, float CamFOVDeg)
	{
		ubyte params[28];
		params[] = 0;
		*cast(Vector*)params.ptr = cast(Vector)CamLoc;
		*cast(Rotator*)&params[12] = cast(Rotator)CamRot;
		*cast(float*)&params[24] = CamFOVDeg;
		(cast(ScriptObject)this).ProcessEvent(Functions.UpdateLocation, params.ptr, cast(void*)0);
	}
	void Activate()
	{
		(cast(ScriptObject)this).ProcessEvent(Functions.Activate, cast(void*)0, cast(void*)0);
	}
	void Deactivate()
	{
		(cast(ScriptObject)this).ProcessEvent(Functions.Deactivate, cast(void*)0, cast(void*)0);
	}
}
