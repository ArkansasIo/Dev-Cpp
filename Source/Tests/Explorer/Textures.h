// Stub framework header for the Explorer parser test files.
#ifndef TEXTURES_H
#define TEXTURES_H
#include <d3dx9.h>

class Texture
{
public:
	LPDIRECT3DTEXTURE9 texture;
	Texture() : texture(NULL) {}
};

class RenderTarget;
#endif
