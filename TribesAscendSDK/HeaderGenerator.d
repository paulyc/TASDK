module HeaderGenerator;

private import Config;
private import IndentedStreamWriter;
private import ScriptClasses;

public void Generate()
{
	//IndentedStreamWriter wtr = new IndentedStreamWriter("TribesAscendSDKTest.log");
	ClassDescriptor[] classDescriptors;
	StructDescriptor[] structDescriptors;
	ConstantDescriptor[] constantDescriptors;
	EnumDescriptor[] enumDescriptors;
	FunctionDescriptor[] functionDescriptors;
	PropertyDescriptor[] propertyDescriptors;
	//wtr.WriteLine("Dumping %u objects.", (*ScriptObject.ObjectArray).Count);
	for (int i = 0; i < (*ScriptObject.ObjectArray).Count; i++)
	{
		ScriptObject classObject = (*ScriptObject.ObjectArray)[i];
		if (classObject)
		{
			//wtr.WriteLine("%u: %s", i, classObject.GetFullName());
			switch (classObject.ObjectClass.GetName())
			{
				case "Class":
				{
					ClassDescriptor cd = new ClassDescriptor(cast(ScriptClass)classObject);
					classDescriptors ~= cd;
					TypeDescriptorMap[classObject.GetFullName()] = cd;
					TypeIdentifiersTable[classObject.GetName()] = cd;
					break;
				}
				case "ScriptStruct":
				{
					StructDescriptor sd = new StructDescriptor(cast(ScriptStruct)classObject); 
					structDescriptors ~= sd;
					TypeDescriptorMap[classObject.GetFullName()] = sd;
					TypeIdentifiersTable[classObject.GetName()] = sd;
					break;
				}
				case "Const":
					constantDescriptors ~= new ConstantDescriptor(cast(ScriptConst)classObject);
					break;
				case "Enum":
				{
					EnumDescriptor ed = new EnumDescriptor(cast(ScriptEnum)classObject);
					enumDescriptors ~= ed;
					TypeIdentifiersTable[classObject.GetName()] = ed;
					break;
				}
				case "Function":
					functionDescriptors ~= new FunctionDescriptor(cast(ScriptFunction)classObject);
					break;
				case "ArrayProperty":
				case "BoolProperty":
				case "ByteProperty":
				case "ClassProperty":
				case "FloatProperty":
				case "IntProperty":
				case "NameProperty":
				case "ObjectProperty":
				case "StringRefProperty":
				case "StrProperty":
				case "StructProperty":
					propertyDescriptors ~= new PropertyDescriptor(cast(ScriptProperty)classObject);
					break;
				case "State":
					// TODO: Implement.
					break;
				default:
					break;
			}
		}
	}

	foreach (sd; structDescriptors)
		ProcessNested(sd, sd.InnerStruct);
	foreach (cd; constantDescriptors)
		ProcessNested(cd, cd.InnerConstant);
	foreach (ed; enumDescriptors)
		ProcessNested(ed, ed.InnerEnum);
	foreach (fd; functionDescriptors)
		ProcessNested(fd, fd.InnerFunction);
	foreach (pd; propertyDescriptors)
		ProcessNested(pd, pd.InnerProperty);

	foreach (c; classDescriptors)
		c.Generate();
}

private:
__gshared Descriptor[string] TypeDescriptorMap;
__gshared Descriptor[string] TypeIdentifiersTable;

void ProcessNested(Descriptor desc, ScriptObject innerVal)
{
	Descriptor parent = TypeDescriptorMap.get(innerVal.Outer.GetFullName(), null);
	if (parent)
	{
		switch (parent.Type)
		{
			case DescriptorType.Class:
			case DescriptorType.Struct:
			{
				NestableContainer cont = cast(NestableContainer)parent;
				switch (desc.Type)
				{
					case DescriptorType.Constant:
						cont.NestedConstants ~= cast(ConstantDescriptor)desc;
						break;
					case DescriptorType.Enum:
						cont.NestedEnums ~= cast(EnumDescriptor)desc;
						break;
					case DescriptorType.Function:
						cont.Functions ~= cast(FunctionDescriptor)desc;
						break;
					case DescriptorType.Property:
					{
						PropertyDescriptor pDesc = cast(PropertyDescriptor)desc;
						if (pDesc.IsBoolProperty)
							cont.BoolProperties ~= pDesc;
						else
							cont.Properties ~= pDesc;
						if (parent.Type == DescriptorType.Struct)
							pDesc.ParentIsStruct = true;
						break;
					}
					case DescriptorType.Struct:
						cont.NestedStructs ~= cast(StructDescriptor)desc;
						break;

					case DescriptorType.Class:
					case DescriptorType.FunctionArgument:
						throw new Exception("These shouldn't be making it here!");
					default:
						throw new Exception("Unknown DescriptorType!");
				}
				break;
			}
			default:
				throw new Exception("Unknown parent descriptor type!");
		}
	}
	else
	{
		// We weren't able to locate the parent of this Descriptor
		// TODO: Output some useful info here.
	}
}

string EscapeName(string name)
{
	switch (name)
	{
		case "Interface":
			return "UInterface";
		case "Object":
			return "UObject";
		default:
			return name;
	}
}
final class DependencyManager
{
	bool NeedsScriptClasses;
	ScriptObject[string] RequiredImports;
	ScriptObject ParentType;

	this(ScriptObject parentType)
	{
		ParentType = parentType;
	}

	static final immutable(string) GetImportName(ScriptObject type)
	{
		string n = EscapeName(type.GetName());
		for (ScriptObject outer = type.Outer; outer; outer = outer.Outer)
		{
			n = EscapeName(outer.GetName()) ~ "." ~ n;
		}
		return "UnrealScript." ~ n;
	}

	void ProcessProperty(ScriptProperty prop)
	{
		switch (prop.ObjectClass.GetName())
		{
			case "ObjectProperty":
			case "StructProperty":
				RequireType((cast(ScriptObjectProperty)prop).PropertyClass);
				break;
			case "ByteProperty":
				if ((cast(ScriptByteProperty)prop).EnumType)
					RequireType((cast(ScriptByteProperty)prop).EnumType);
				break;
			case "ClassProperty":
			case "NameProperty":
			case "StrProperty":
			case "StringRefProperty":
				NeedsScriptClasses = true;
				break;
			case "ArrayProperty":
				NeedsScriptClasses = true;
				ProcessProperty((cast(ScriptArrayProperty)prop).InnerProperty);
				break;
			default:
				break;
		}
	}

	void RequireType(ScriptObject type)
	{
		if (type == ParentType)
			return;
		if (Descriptor.IsManaullyDefinedType(type.GetName()))
		{
			NeedsScriptClasses = true;
			return;
		}
		if (type.Outer.Outer)
		{
			// Ensure that we only require the class-level
			// include.
			RequireType(type.Outer);
			return;
		}
		RequiredImports[GetImportName(type)] = type;
	}

	void Write(IndentedStreamWriter wtr)
	{
		if (NeedsScriptClasses)
			wtr.WriteLine("import ScriptClasses;");
		// TODO: Sort these before writing them out.
		foreach (ri; RequiredImports.byValue())
			wtr.WriteLine("import %s;", GetImportName(ri));
	}
}

abstract class Descriptor
{
	@property abstract DescriptorType Type();

	abstract void RequireDependencies(DependencyManager mgr);
	abstract void Write(IndentedStreamWriter wtr);

	static final bool IsManaullyDefinedType(string name)
	{
		switch (name)
		{
			case "QWord":
			case "Rotator":
			case "Vector":
				return true;
			default:
				return false;
		}
	}

	final immutable(string) GetTypeName(ScriptObject obj)
	{
		switch (obj.ObjectClass.GetName())
		{
			case "ObjectProperty":
			case "StructProperty":
				return GetTypeName((cast(ScriptObjectProperty)obj).PropertyClass);
			case "Class":
			case "Enum":
			case "ScriptStruct":
			{
				string tp = EscapeName(obj.GetName());
				if (IsManaullyDefinedType(tp))
					return tp;
				for (ScriptObject outer = obj.Outer; outer.Outer; outer = outer.Outer)
					tp = EscapeName(outer.GetName()) ~ "." ~ tp;
				return tp;
			}
			case "ArrayProperty":
				return "ScriptArray!(" ~ GetTypeName((cast(ScriptArrayProperty)obj).InnerProperty) ~ ")";
			case "ByteProperty":
				if ((cast(ScriptByteProperty)obj).EnumType)
					return GetTypeName((cast(ScriptByteProperty)obj).EnumType);
				else
					return "ubyte";
			case "IntProperty":
				return "int";
			case "FloatProperty":
				return "float";
			case "BoolProperty":
				return "bool";
			case "StrProperty":
				return "ScriptString";
			case "StringRefProperty":
				return "ScriptString*";
			case "NameProperty":
				return "ScriptName";
			case "ClassProperty":
				return "ScriptClass";
			default:
				return "\n// ERROR: Unknown object class '" ~ obj.ObjectClass.GetFullName() ~ "'!\nvoid*";
		}
	}
}

enum DescriptorType
{
	Class,
	Constant,
	Enum,
	Function,
	FunctionArgument,
	Property,
	Struct,
}

final class EnumDescriptor : Descriptor
{
	@property final override DescriptorType Type() { return DescriptorType.Enum; }

	ScriptEnum InnerEnum;
	this(ScriptEnum innerEnum)
	{
		InnerEnum = innerEnum;
	}

	override void RequireDependencies(DependencyManager mgr) { }
	override void Write(IndentedStreamWriter wtr)
	{
		wtr.WriteLine("enum %s : ubyte", InnerEnum.GetName());
		wtr.WriteLine("{");
		wtr.Indent++;

		for (int i = 0; i < InnerEnum.ValueNames.Count; i++)
		{
			wtr.WriteLine("%s = %u,", InnerEnum.ValueNames[i].GetName(), i);
		}

		wtr.Indent--;
		wtr.WriteLine("}");
	}
}

final class ConstantDescriptor : Descriptor
{
	@property final override DescriptorType Type() { return DescriptorType.Constant; }

	ScriptConst InnerConstant;
	this(ScriptConst innerConstant)
	{
		InnerConstant = innerConstant;
	}

	override void RequireDependencies(DependencyManager mgr) { }
	override void Write(IndentedStreamWriter wtr) { assert(0, "This method isn't implemented!"); }
	void Write(IndentedStreamWriter wtr, bool alone)
	{
		string valString = InnerConstant.Value.ToString();
		if (valString.length > 2)
		{
			switch(valString[valString.length - 1])
			{
				case 'f':
					if (valString[valString.length - 2] == '.')
						valString = valString[0..(valString.length - 3)] ~ ".0f";
					break;
				case '\'':
					if (valString[0] == '\'')
						valString = `"` ~ valString[1..(valString.length - 1)] ~ `"`;
					break;
				default:
					break;
			}
		}
		if (alone)
			wtr.WriteLine("enum %s = %s;", InnerConstant.GetName(), valString);
		else
			wtr.WriteLine("%s = %s,", InnerConstant.GetName(), valString);
	}
}

final class PropertyDescriptor : Descriptor
{
	@property final override DescriptorType Type() { return DescriptorType.Property; }

	ScriptProperty InnerProperty;
	bool ParentIsStruct;
	bool IsBoolProperty;
	this(ScriptProperty innerProperty)
	{
		InnerProperty = innerProperty;
		ParentIsStruct = false;
		IsBoolProperty = InnerProperty.ObjectClass.GetName() == "BoolProperty";
	}

	// TODO: Add support for DelegateProperty, MapProperty, FixedArrayProperty, PointerProperty, InterfaceProperty, and ComponentProperty

	override void RequireDependencies(DependencyManager mgr) { mgr.ProcessProperty(InnerProperty); }
	override void Write(IndentedStreamWriter wtr) { assert(0, "This method is not implemented!"); }

	void Write(IndentedStreamWriter wtr, bool alone)
	{
		// Check to see if the property name is the same as a valid type.
		if (TypeIdentifiersTable.get(InnerProperty.GetName(), null))
		{
			wtr.WriteLine("// WARNING: Property '%s' has the same name as a defined type!", InnerProperty.GetName());
			return;
		}

		if (alone)
			wtr.Write("@property final ");
		switch (InnerProperty.ObjectClass.GetName())
		{
			case "BoolProperty":
				if (ParentIsStruct)
				{
					wtr.WriteLine("bool %s() { return (*cast(uint*)(cast(size_t)&this + %u) & 0x%X) != 0; }", InnerProperty.GetName(), InnerProperty.Offset, (cast(ScriptBoolProperty)InnerProperty).BitMask);
					wtr.WriteLine("bool %s(bool val) { if (val) { *cast(uint*)(cast(size_t)&this + %u) |= 0x%X; } else { *cast(uint*)(cast(size_t)&this + %u) &= ~0x%X; } return val; }", InnerProperty.GetName(), InnerProperty.Offset, (cast(ScriptBoolProperty)InnerProperty).BitMask, InnerProperty.Offset, (cast(ScriptBoolProperty)InnerProperty).BitMask);
				}
				else
				{
					wtr.WriteLine("bool %s() { return (*cast(uint*)(cast(size_t)cast(void*)this + %u) & 0x%X) != 0; }", InnerProperty.GetName(), InnerProperty.Offset, (cast(ScriptBoolProperty)InnerProperty).BitMask);
					wtr.WriteLine("bool %s(bool val) { if (val) { *cast(uint*)(cast(size_t)cast(void*)this + %u) |= 0x%X; } else { *cast(uint*)(cast(size_t)cast(void*)this + %u) &= ~0x%X; } return val; }", InnerProperty.GetName(), InnerProperty.Offset, (cast(ScriptBoolProperty)InnerProperty).BitMask, InnerProperty.Offset, (cast(ScriptBoolProperty)InnerProperty).BitMask);
				}
				break;
			case "ObjectProperty":
			case "StringRefProperty":
			case "ClassProperty":
			case "StructProperty":
			case "ByteProperty":
			case "IntProperty":
			case "FloatProperty":
			case "StrProperty":
			case "NameProperty":
			case "ArrayProperty":
				if (alone)
					wtr.Write("auto ref ");
				if (ParentIsStruct)
					wtr.WriteLine("%s %s() { return *cast(%s*)(cast(size_t)&this + %u); }", GetTypeName(InnerProperty), InnerProperty.GetName(), GetTypeName(InnerProperty), InnerProperty.Offset);
				else
					wtr.WriteLine("%s %s() { return *cast(%s*)(cast(size_t)cast(void*)this + %u); }", GetTypeName(InnerProperty), InnerProperty.GetName(), GetTypeName(InnerProperty), InnerProperty.Offset);
				break;
			default:
				// TODO: This never actually gets hit, find a way to make it get hit so we can output this useful information.
				wtr.WriteLine("// ERROR: Unknown object class '%s' for the property named '%s'!", InnerProperty.ObjectClass.GetName(), InnerProperty.GetName());
				break;
		}
	}
}

final class FunctionArgumentDescriptor : Descriptor
{
	@property final override DescriptorType Type() { return DescriptorType.FunctionArgument; }

	string ArgumentName;
	ScriptProperty InnerProperty;
	this(ScriptProperty innerProperty)
	{
		InnerProperty = innerProperty;
	}
	
	override void RequireDependencies(DependencyManager mgr) { mgr.ProcessProperty(InnerProperty); }

	// We don't implement this method, instead we implement a set of 3 methods.
	override void Write(IndentedStreamWriter wtr) { }

	void WriteDeclaration(IndentedStreamWriter wtr)
	{
		ArgumentName = InnerProperty.GetName();
		// Check to see if the parameter name is the same as a valid type.
		if (TypeIdentifiersTable.get(InnerProperty.GetName(), null))
			ArgumentName = "p" ~ ArgumentName;

		if (InnerProperty.PropertyFlags.HasFlag(ScriptPropertyFlags.OutParam))
			wtr.Write("%s* %s", GetTypeName(InnerProperty), ArgumentName);
		else
			wtr.Write("%s %s", GetTypeName(InnerProperty), ArgumentName);
	}

	void WriteLoadToBuffer(IndentedStreamWriter wtr, string bufName)
	{
		string tpName = GetTypeName(InnerProperty);
		if (InnerProperty.PropertyFlags.HasFlag(ScriptPropertyFlags.OutParam))
		{
			if (InnerProperty.Offset != 0)
			{
				if (tpName == "ubyte")
					wtr.WriteLine("%s[%u] = *%s;", bufName, InnerProperty.Offset, ArgumentName);
				else
					wtr.WriteLine("*cast(%s*)&%s[%u] = *%s;", tpName, bufName, InnerProperty.Offset, ArgumentName);
			}
			else
			{
				if (tpName == "ubyte")
					wtr.WriteLine("%s[0] = *%s;", bufName, ArgumentName);
				else
					wtr.WriteLine("*cast(%s*)%s.ptr = *%s;", tpName, bufName, ArgumentName);
			}
		}
		else
		{
			if (InnerProperty.Offset != 0)
			{
				if (tpName == "ubyte")
					wtr.WriteLine("%s[%u] = %s;", bufName, InnerProperty.Offset, ArgumentName);
				else
					wtr.WriteLine("*cast(%s*)&%s[%u] = %s;", tpName, bufName, InnerProperty.Offset, ArgumentName);
			}
			else
			{
				if (tpName == "ubyte")
					wtr.WriteLine("%s[0] = %s;", bufName, ArgumentName);
				else
					wtr.WriteLine("*cast(%s*)%s.ptr = %s;", tpName, bufName, ArgumentName);
			}
		}
	}

	void WriteLoadFromBuffer(IndentedStreamWriter wtr, string bufName)
	{
		if (InnerProperty.PropertyFlags.HasFlag(ScriptPropertyFlags.OutParam))
		{
			string tpName = GetTypeName(InnerProperty);
			if (InnerProperty.Offset != 0)
			{
				if (tpName == "ubyte")
					wtr.WriteLine("*%s = %s[%u];", ArgumentName, bufName, InnerProperty.Offset);
				else
					wtr.WriteLine("*%s = *cast(%s*)&%s[%u];", ArgumentName, tpName, bufName, InnerProperty.Offset);
			}
			else
			{
				if (tpName == "ubyte")
					wtr.WriteLine("*%s = %s[0];", ArgumentName, bufName);
				else
					wtr.WriteLine("*%s = *cast(%s*)%s.ptr;", ArgumentName, tpName, bufName);
			}
		}
	}
}

final class FunctionDescriptor : Descriptor
{
	@property final override DescriptorType Type() { return DescriptorType.Function; }

	ScriptFunction InnerFunction;
	FunctionArgumentDescriptor[] Arguments;
	ScriptProperty ReturnProperty;
	this(ScriptFunction innerFunction)
	{
		InnerFunction = innerFunction;
		for (ScriptProperty functionArgument = cast(ScriptProperty)InnerFunction.Children; functionArgument; functionArgument = cast(ScriptProperty)functionArgument.Next)
		{
			if (functionArgument.PropertyFlags.HasAnyFlags(ScriptPropertyFlags.ParamFlags))
			{
				if (functionArgument.PropertyFlags.HasFlag(ScriptPropertyFlags.ReturnParam))
				{
					if (ReturnProperty)
						throw new Exception("Found multiple return parameters!");
					ReturnProperty = functionArgument;
				}
				else if (functionArgument.PropertyFlags.HasFlag(ScriptPropertyFlags.Param))
					Arguments ~= new FunctionArgumentDescriptor(functionArgument);
				else
					throw new Exception("Unknown property with param flags!");
			}
			else
			{
				// We don't currently do anything with any children other than the params.
			}
		}
	}

	override void RequireDependencies(DependencyManager mgr)
	{
		mgr.NeedsScriptClasses = true;
		if (ReturnProperty)
			mgr.ProcessProperty(ReturnProperty);
		foreach (arg; Arguments)
			arg.RequireDependencies(mgr);
	}

	override void Write(IndentedStreamWriter wtr) { assert(0, "This method is not implemented!"); }
	void Write(IndentedStreamWriter wtr, bool alone)
	{
		// Check to see if the function name is the same as a valid type.
		if (TypeIdentifiersTable.get(InnerFunction.GetName(), null))
		{
			wtr.WriteLine("// WARNING: Function '%s' has the same name as a defined type!", InnerFunction.GetName());
			return;
		}

		if (alone)
			wtr.Write("final ");
		if (InnerFunction.FunctionFlags.HasFlag(ScriptFunctionFlags.Static))
			wtr.Write("static ");
		if (ReturnProperty)
			wtr.Write("%s", GetTypeName(ReturnProperty));
		else
			wtr.Write("void");
		wtr.Write(" %s(", InnerFunction.GetName());

		for (int i = 0; i < Arguments.length; i++)
		{
			Arguments[i].WriteDeclaration(wtr);
			if (i + 1 != Arguments.length)
				wtr.Write(", ");
		}

		wtr.WriteLine(")");
		wtr.WriteLine("{");
		wtr.Indent++;

		if (InnerFunction.ParamsSize > 0)
		{
			wtr.WriteLine("ubyte params[%u];", InnerFunction.ParamsSize);
			wtr.WriteLine("params[] = 0;");
		}

		foreach (arg; Arguments)
			arg.WriteLoadToBuffer(wtr, "params");

		if (InnerFunction.FunctionFlags.HasFlag(ScriptFunctionFlags.Static))
			wtr.Write("StaticClass");
		else
			wtr.Write("(cast(ScriptObject)this)");
		wtr.Write(".ProcessEvent(ScriptObject.Find!(ScriptFunction)(\"%s\"), ", InnerFunction.GetFullName());
		if (InnerFunction.ParamsSize > 0)
			wtr.Write("params.ptr");
		else
			wtr.Write("cast(void*)0");
		wtr.WriteLine(", cast(void*)0);");

		foreach (arg; Arguments)
			arg.WriteLoadFromBuffer(wtr, "params");

		if (ReturnProperty)
		{
			string tpName = GetTypeName(ReturnProperty);
			if (ReturnProperty.Offset != 0)
			{
				if (tpName == "ubyte")
					wtr.WriteLine("return params[%u];", ReturnProperty.Offset,);
				else
					wtr.WriteLine("return *cast(%s*)&params[%u];", tpName, ReturnProperty.Offset);
			}
			else
			{
				if (tpName == "ubyte")
					wtr.WriteLine("return params[0];");
				else
					wtr.WriteLine("return *cast(%s*)params.ptr;", tpName);
			}
		}

		wtr.Indent--;
		wtr.WriteLine("}");
	}
}

abstract class NestableContainer : Descriptor
{
	@property final bool HasChildren() { return NestedConstants.length + NestedEnums.length + NestedStructs.length + Properties.length + BoolProperties.length + Functions.length != 0; }
	ConstantDescriptor[] NestedConstants;
	EnumDescriptor[] NestedEnums;
	StructDescriptor[] NestedStructs;
	PropertyDescriptor[] Properties;
	PropertyDescriptor[] BoolProperties;
	FunctionDescriptor[] Functions;

	final void WriteChildren(IndentedStreamWriter wtr)
	{
		// Nested Constants
		if (NestedConstants.length > 1)
		{
			wtr.WriteLine("enum");
			wtr.WriteLine("{");
			wtr.Indent++;
		}
		foreach (nc; NestedConstants)
			nc.Write(wtr, NestedConstants.length <= 1);
		if (NestedConstants.length > 1)
		{
			wtr.Indent--;
			wtr.WriteLine("}");
		}

		// Nested Enums
		foreach (ne; NestedEnums)
			ne.Write(wtr);

		// Nested Structs
		foreach (ns; NestedStructs)
			ns.Write(wtr);

		// Properties & Bool Properties
		if (Properties.length > 1 && BoolProperties.length == 0)
		{
			wtr.WriteLine("@property final auto ref");
			wtr.WriteLine("{");
			wtr.Indent++;
		}
		else
		{
			if (Properties.length + (BoolProperties.length * 2) > 1)
			{
				wtr.WriteLine("@property final");
				wtr.WriteLine("{");
				wtr.Indent++;
			}
			if (Properties.length > 1)
			{
				wtr.WriteLine("auto ref");
				wtr.WriteLine("{");
				wtr.Indent++;
			}
		}
		foreach (p; Properties)
			p.Write(wtr, Properties.length <= 1);
		if (Properties.length > 1)
		{
			wtr.Indent--;
			wtr.WriteLine("}");
		}
		// Bool properties require 2 functions to define, thus,
		// if it calls Write on a BoolProperty, it is not alone.
		foreach (bp; BoolProperties)
			bp.Write(wtr, false);
		if (BoolProperties.length >= 1)
		{
			wtr.Indent--;
			wtr.WriteLine("}");
		}

		// Functions
		if (Functions.length > 0) // The StaticClass property comes at the very end of the container.
		{
			wtr.Indent--;
			wtr.WriteLine("final:");
			wtr.Indent++;
		}
		foreach (f; Functions)
			f.Write(wtr, Functions.length <= 1);
	}
}

final class ClassDescriptor : NestableContainer
{
	@property final override DescriptorType Type() { return DescriptorType.Class; }

	ScriptClass InnerClass;
	DependencyManager DepManager;
	this(ScriptClass innerClass)
	{
		InnerClass = innerClass;
		DepManager = new DependencyManager(innerClass);
	}

	override void RequireDependencies(DependencyManager mgr)
	{
		if (InnerClass.Super)
			mgr.RequireType(InnerClass.Super);

		foreach (nc; NestedConstants)
			nc.RequireDependencies(mgr);
		foreach (ne; NestedEnums)
			ne.RequireDependencies(mgr);
		foreach (ns; NestedStructs)
			ns.RequireDependencies(mgr);
		foreach (p; Properties)
			p.RequireDependencies(mgr);
		foreach (bp; BoolProperties)
			bp.RequireDependencies(mgr);
		foreach (f; Functions)
			f.RequireDependencies(mgr);
	}

	static bool IsFactory(ScriptClass sc)
	{
		if (sc.GetName() == "Factory")
			return true;
		if (sc.Super)
			return IsFactory(cast(ScriptClass)sc.Super);
		return false;
	}

	override void Write(IndentedStreamWriter wtr)
	{
		this.RequireDependencies(DepManager);

		wtr.WriteLine("module %s;", DependencyManager.GetImportName(InnerClass));
		wtr.WriteLine();
		DepManager.Write(wtr);
		wtr.WriteLine();

		wtr.Write("extern(C++) interface %s", EscapeName(InnerClass.GetName()));
		if (InnerClass.Super)
			wtr.Write(" : %s", EscapeName(InnerClass.Super.GetName()));
		wtr.WriteLine();
		wtr.WriteLine("{");
		if (HasChildren)
			wtr.WriteLine("public extern(D):");
		wtr.Indent++;
		
		WriteChildren(wtr);

		if (Functions.length == 0)
			wtr.Write("final ");
		wtr.WriteLine("static @property ScriptClass StaticClass() { return ScriptObject.Find!(ScriptClass)(\"%s\"); }", InnerClass.GetFullName());

		wtr.Indent--;
		wtr.WriteLine("}");
	}

	void Generate()
	{
		if (InnerClass.Super && IsFactory(InnerClass))
		{
			// TODO: Output something useful here.
			//wtr.WriteLine("// ERROR: Factories are not generatable!");
			return;
		}
		else if (InnerClass.GetName() == "Default__Class")
		{
			// Don't emit the default class.
			// TODO: Output something useful here.
			return;
		}
		char[] headerNameBuf = cast(char[])DependencyManager.GetImportName(InnerClass);
		for (int i = 0; i < headerNameBuf.length; i++)
		{
			if (headerNameBuf[i] == '.')
				headerNameBuf[i] = '/';
		}
		string headerName = cast(string)headerNameBuf;
		IndentedStreamWriter wtr = new IndentedStreamWriter(SDKSourcePath ~ "TribesAscendSDK/" ~ headerName ~ ".d");
		this.Write(wtr);
		wtr.Close();
	}
}

final class StructDescriptor : NestableContainer
{
	@property final override DescriptorType Type() { return DescriptorType.Struct; }

	ScriptStruct InnerStruct;
	this(ScriptStruct innerStruct)
	{
		InnerStruct = innerStruct;
	}
	
	override void RequireDependencies(DependencyManager mgr)
	{
		if (InnerStruct.Super)
			(cast(StructDescriptor)TypeDescriptorMap[InnerStruct.Super.GetFullName()]).RequireDependencies(mgr);
		
		foreach (nc; NestedConstants)
			nc.RequireDependencies(mgr);
		foreach (ne; NestedEnums)
			ne.RequireDependencies(mgr);
		foreach (ns; NestedStructs)
			ns.RequireDependencies(mgr);
		foreach (p; Properties)
			p.RequireDependencies(mgr);
		foreach (bp; BoolProperties)
			bp.RequireDependencies(mgr);
		foreach (f; Functions)
			f.RequireDependencies(mgr);
	}
	
	override void Write(IndentedStreamWriter wtr)
	{
		wtr.Write("struct %s", EscapeName(InnerStruct.GetName()));
		wtr.WriteLine();
		wtr.WriteLine("{");
		wtr.Indent++;

		wtr.WriteLine("private ubyte __buffer__[%u];", InnerStruct.PropertySize);
		wtr.Indent--;
		wtr.WriteLine("public extern(D):");
		wtr.Indent++;

		WriteBody(wtr);

		if (Functions.length == 0)
			wtr.Write("final ");
		wtr.WriteLine("static @property ScriptStruct StaticClass() { return ScriptObject.Find!(ScriptStruct)(\"%s\"); }", InnerStruct.GetFullName());
		
		wtr.Indent--;
		wtr.WriteLine("}");
	}

	void WriteBody(IndentedStreamWriter wtr)
	{
		if (InnerStruct.Super)
			(cast(StructDescriptor)TypeDescriptorMap[InnerStruct.Super.GetFullName()]).WriteBody(wtr);
		WriteChildren(wtr);
	}
}
