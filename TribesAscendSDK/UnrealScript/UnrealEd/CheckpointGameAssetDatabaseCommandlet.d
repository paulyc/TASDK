module UnrealScript.UnrealEd.CheckpointGameAssetDatabaseCommandlet;

import ScriptClasses;
import UnrealScript.Helpers;
import UnrealScript.Core.Commandlet;

extern(C++) interface CheckpointGameAssetDatabaseCommandlet : Commandlet
{
public extern(D):
	private static __gshared ScriptClass mStaticClass;
	@property final static ScriptClass StaticClass() { mixin(MGSCC("Class UnrealEd.CheckpointGameAssetDatabaseCommandlet")); }
	private static __gshared CheckpointGameAssetDatabaseCommandlet mDefaultProperties;
	@property final static CheckpointGameAssetDatabaseCommandlet DefaultProperties() { mixin(MGDPC("CheckpointGameAssetDatabaseCommandlet", "CheckpointGameAssetDatabaseCommandlet UnrealEd.Default__CheckpointGameAssetDatabaseCommandlet")); }
}
