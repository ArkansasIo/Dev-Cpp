// Single translation unit defining the engine framework stub globals
// that all Explorer test files share via Scene.h.
#include "Scene.h"
#include "Console.h"

FXStub FX;
HWND hwnd = NULL;
Options options_stub;
Options *options = &options_stub;
Scene *scene = NULL;
Camera camera;
Camera *camera_ptr = &camera;
Console *console = NULL;
