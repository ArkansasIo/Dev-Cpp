// Simple test main exercising the compiled Explorer engine classes.
#include "float3.h"
#include "float4.h"
#include "float4x4.h"
#include "Dropdown.h"
#include "Edit.h"
#include "Dirlight.h"
#include "Scene.h"
#include <cstdio>

int main()
{
	int failures = 0;
#define CHECK(cond, msg) do { if (!(cond)) { printf("FAIL: %s\n", msg); failures++; } else { printf("ok  : %s\n", msg); } } while(0)

	// --- float3 ---
	float3 a(1, 2, 3), b(4, 5, 6);
	CHECK(a.Dot(b) == 32.0f, "float3::Dot");
	CHECK(fabsf(a.Length() - 3.7416575f) < 1e-4f, "float3::Length");
	a.Normalize();
	CHECK(fabsf(a.Length() - 1.0f) < 1e-5f, "float3::Normalize");
	float3 lo = a.Min(b);
	CHECK(lo.x <= b.x, "float3::Min");

	// --- float4x4 ---
	float4x4 m;
	m.Identity();
	CHECK(fabsf(m.Determinant() - 1.0f) < 1e-5f, "float4x4::Identity det=1");
	float4x4 t;
	t.Translation(float3(10, 20, 30));
	CHECK(fabsf(t._41 - 10.0f) < 1e-5f && fabsf(t._42 - 20.0f) < 1e-5f, "float4x4::Translation");

	// --- Dropdown ---
	Dropdown dd(0, 0, 100, 20);
	dd.AddItem("alpha");
	dd.AddItem("beta");
	CHECK(dd.GetItemCount() == 2, "Dropdown::AddItem/GetItemCount");
	CHECK(strcmp(dd.GetItem(1), "beta") == 0, "Dropdown::GetItem");
	dd.SetSelection("beta");
	CHECK(strcmp(dd.GetSelection(), "beta") == 0, "Dropdown::SetSelection/GetSelection");
	dd.Toggle();
	CHECK(dd.dropped, "Dropdown::Toggle drop");
	dd.Toggle();
	CHECK(!dd.dropped, "Dropdown::Toggle collapse");
	dd.Clear();
	CHECK(dd.GetItemCount() == 0, "Dropdown::Clear");

	// --- Dropdown edge cases (ASan stress) ---
	CHECK(dd.GetItem(999) == NULL, "Dropdown::GetItem out-of-range returns NULL");
	CHECK(dd.GetSelection() == NULL, "Dropdown::GetSelection when empty returns NULL");
	dd.Toggle();
	CHECK(dd.dropped, "Dropdown::Toggle on empty list");

	// --- Edit ---
	Edit ed(0, 0, 100, 20, "hello");
	CHECK(ed.caption == "hello", "Edit::caption");
	CHECK(!ed.focused, "Edit::focused=false");

	// --- Scene / Dirlight ---
	Scene scene_storage;
	struct LightsImpl {
	void BeginUpdate() {}
	void EndUpdate() {}
	void AddDirlight(class Dirlight* d) { (void)d; }
	void DeleteDirlight(class Dirlight* d) { (void)d; }
	};
	static LightsImpl lights_impl;
	scene_storage.lights = (Lights*)&lights_impl;
	scene = &scene_storage;
	Dirlight dl(float3(0, -1, 0), float3(1, 1, 1), true);
	CHECK(dl.GetEnabled(), "Dirlight::GetEnabled");
	CHECK(fabsf(dl.GetColor().x - 1.0f) < 1e-5f, "Dirlight::GetColor");
	dl.SetColor(float3(0.5f, 0.5f, 0.5f));
	CHECK(fabsf(dl.GetColor().x - 0.5f) < 1e-5f, "Dirlight::SetColor");
	dl.SetEnabled(false);
	CHECK(!dl.GetEnabled(), "Dirlight::SetEnabled");

	if (failures == 0) {
		printf("ALL TESTS PASSED\n");
	} else {
		printf("%d TEST(S) FAILED\n", failures);
	}
	return failures ? 1 : 0;
}
