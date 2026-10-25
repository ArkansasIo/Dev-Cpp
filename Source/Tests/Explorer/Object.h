// Stub framework header for the Explorer parser test files.
#ifndef OBJECT_H
#define OBJECT_H
#include <string>
#include <list>
#include "float3.h"

class Object
{
public:
	std::string name;
	bool castshadows;
	float3 worldcenter;
	float worldr;
	Object(const char *n) : name(n), castshadows(false), worldcenter(float3()), worldr(0.0f) {}
	const char *GetName() { return name.c_str(); }
	virtual ~Object() {}
};

class Scene;

extern Scene *scene; // stub
#endif
