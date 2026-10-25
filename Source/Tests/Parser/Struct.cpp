/*
	Correct forward struct, struct
*/
struct UnfinishedStructName; // forward declaration
struct StructName {
	int VarA;
	float VarB;
	bool VarC;
	struct Child {
		float ChildVar;
	};
};

/*
	Correct forward class, class and derived class
*/
class UnfinishedClassName; // forward declaration
class ClassName {
	int PrivVarA;
	protected:
		int ProtVarA;
	public:
		int VarA;
		float VarB;
		bool VarC;
		struct Child {
			float ChildVar;
		};
};
class DerivedClassName : public ClassName {
	public:
		int VarD;
};

/*
	Correct union
*/
union UnionName {
	int PartAVar;
	int PartBVar;
	struct PartA {
		int PartAVar2;
	};
	struct PartB {
		int PartBVar2;
	};
};

/*
	Correct typedef
*/
typedef struct UnfinishedStructName UnfinishedStructName2; typedef struct UnfinishedStructName* UnfinishedClassName2;

/*
	Complicated typedef
*/
typedef struct tagRECT {
  LONG left;
  LONG top;
  LONG right;
  LONG bottom;
} RECT,*PRECT,*NPRECT,*LPRECT;

/*
	Correct enum
*/
enum EnumName {
	A,
	B,
	C,
	D,
	E
};

/*
	Struct usage. Hover above statements to check if they are parsed correctly
*/
int main() {
	StructName S;
	ClassName C;
	DerivedClassName D;
	UnionName U;
	UnionName::PartA PA;
	UnionName::PartB PB;
	U.PartAVar;
	U.PartBVar;
	PA.PartAVar2;
	PB.PartBVar2;
	ClassName::Child ChildObj;
	S.VarA;
	S.VarB;
	S.VarC;
	C.VarA;
	C.VarB;
	C.VarC;
	D.VarA;
	D.VarB;
	D.VarC;
	D.VarD;
	ChildObj.ChildVar;
	PA.PartAVar2;
	PB.PartBVar2;
}
