// Stub framework headers for the Explorer parser test files.
// The originals belonged to an external engine project not included in this repo.
#ifndef COMPONENT_H
#define COMPONENT_H
#include <d3dx9.h>
#include <string>
#include <vector>
#include "float4.h"

enum ComponentType { ctDropdown, ctEdit };

class Component {
	public:
		int left, top, width, height;
		ComponentType type;
		float4 backcolor;
		Component(int left,int top,int width,int height) :
			left(left), top(top), width(width), height(height) {}
		void Resize(int w,int h) { width = w; height = h; }
		void Clear() {}
		virtual ~Component() {}
};
#endif
