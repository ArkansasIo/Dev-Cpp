// Stub framework header for the Explorer parser test files.
#ifndef LABEL_H
#define LABEL_H
#include "Component.h"
#include <string>

class Label : public Component
{
public:
	std::string caption;
	bool focused;
	void (*OnReturn)();
	Label(int left, int top, int width, int height, const char *text, bool focused_)
		: Component(left, top, width, height), caption(text), focused(focused_), OnReturn(NULL) {}
	void GetRect(RECT *rect)
	{
		rect->left = left;
		rect->top = top;
		rect->right = left + width;
		rect->bottom = top + height;
	}
	virtual ~Label() {}
};
#endif
