module UnrealScript.TribesGame.TrDeployableHologram_RadarSensor;

import ScriptClasses;
import UnrealScript.Helpers;
import UnrealScript.TribesGame.TrDeployableHologram;

extern(C++) interface TrDeployableHologram_RadarSensor : TrDeployableHologram
{
public extern(D):
	private static __gshared ScriptClass mStaticClass;
	@property final static ScriptClass StaticClass() { mixin(MGSCC("Class TribesGame.TrDeployableHologram_RadarSensor")); }
	private static __gshared TrDeployableHologram_RadarSensor mDefaultProperties;
	@property final static TrDeployableHologram_RadarSensor DefaultProperties() { mixin(MGDPC("TrDeployableHologram_RadarSensor", "TrDeployableHologram_RadarSensor TribesGame.Default__TrDeployableHologram_RadarSensor")); }
}
