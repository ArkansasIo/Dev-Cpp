// Stub framework header for the Explorer parser test files.
#ifndef RENDER_TARGET_H
#define RENDER_TARGET_H
#include "Textures.h"

class RenderTarget : public Texture
{
public:
	LPDIRECT3DSURFACE9 surface;
	RenderTarget() : surface(NULL) {}
};
#endif
