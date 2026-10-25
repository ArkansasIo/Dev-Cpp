// Stub framework header for the Explorer parser test files.
#ifndef CONSOLE_H
#define CONSOLE_H
#include <string>
#include <windows.h>

class Console
{
public:
	void WriteVar(const char *n, const std::string &v)
	{
		(void)n;
		(void)v;
	}
	void WriteVar(const char *n, int v)
	{
		(void)n;
		(void)v;
	}
	void WriteVar(const char *n, bool v)
	{
		(void)n;
		(void)v;
	}
	void WriteVar(const char *n, void *v)
	{
		(void)n;
		(void)v;
	}
	void WriteVar(const char *n, float v)
	{
		(void)n;
		(void)v;
	}
	void Write(const char *s)
	{
		(void)s;
	}
};

extern Console *console; // stub, defined in globals.cpp
#endif
