// Stub framework header for the Explorer parser test files.
#ifndef SCENE_H
#define SCENE_H
#include <windows.h>
#include <d3dx9.h>
#include <d3dx9math.h>
#include <list>
#include "Object.h"
#include "Textures.h"
#include "float3.h"

class Options
{
public:
	float shadowdistance;
};

class Lights;
class ObjectList
{
public:
	std::list<Object *>::iterator begin() { return objects.begin(); }
	std::list<Object *>::iterator end() { return objects.end(); }
	std::list<Object *> objects;
};

class Camera
{
public:
	float3 worldcenter;
	bool castshadows;
	float3 GetPos() { return worldcenter; }
};

class Scene
{
public:
	ObjectList objects;
	Lights *lights;
	Camera *camera_ptr;
};

// Stubs for the missing engine framework globals:
// FX is the active D3DX effect, hwnd the engine window.
// Declared extern here; defined once in globals.cpp to avoid
// duplicate-symbol link errors when several .cpp files include this.
struct FXStub
{
	LPD3DXEFFECT effect;
	LPD3DXEFFECT operator->() { return effect; }
	operator bool() { return effect != NULL; }
	HRESULT GetParameterByName(D3DXHANDLE h, const char *n) { (void)h; (void)n; return E_FAIL; }
	HRESULT GetTechniqueByName(const char *n) { (void)n; return E_FAIL; }
	HRESULT SetValue(D3DXHANDLE h, const void *d, DWORD s) { (void)h; (void)d; (void)s; return E_FAIL; }
	HRESULT SetTexture(D3DXHANDLE h, LPDIRECT3DBASETEXTURE9 t) { (void)h; (void)t; return E_FAIL; }
};

extern FXStub FX;
extern HWND hwnd;
extern Options options_stub;
extern Options* options;
extern Scene* scene;
extern Camera camera;
extern Camera* camera_ptr;

#endif
