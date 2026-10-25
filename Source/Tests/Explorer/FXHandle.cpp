#include "FXHandle.h"

FXHandle::FXHandle(const char* name) {
	handle = NULL;
	this->name = _strdup(name);
}

FXHandle::~FXHandle() {
}
