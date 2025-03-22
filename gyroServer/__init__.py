# pyright: reportMissingImports=false, reportUnusedVariable=warning, reportUntypedBaseClass=error

bl_info = {
    "name": "My First Addon",
    "author": "Nn Nn",
    "description": "This is my first addon...",
    "version": (1, 0),
    "blender": (2, 80, 0),
    "location": "View3D > Object > My First Addon",
    "warning": "",
    "category": "Object"
}

# Blender imports
import bpy
import bpy.types
from .panels import ServerPanel
from .operators import SimpleOperator, StartServerOperator, StopServerOperator
from .settings import WebSocketServerSettings

classes = [
#    ServerOperator
#    MYFIRSTADDON_OT_test, 
#           MYFIRSTADDON_PT_main_panel)
]

def register():
    from bpy.utils import register_class
    for cls in classes:
        register_class(cls)

    bpy.utils.register_class(ServerPanel)
    bpy.utils.register_class(SimpleOperator)
    bpy.utils.register_class(StartServerOperator)
    bpy.utils.register_class(StopServerOperator)
    bpy.utils.register_class(WebSocketServerSettings)

    #bpy.app.timers.register(tcp_handle_data)
    

    #bpy.types.VIEW3D_MT_object.append(server_menu_func)

def unregister():
    from bpy.utils import unregister_class
    for cls in reversed(classes):
        unregister_class(cls)

    bpy.utils.unregister_class(ServerPanel)
    bpy.utils.unregister_class(SimpleOperator)
    bpy.utils.unregister_class(StartServerOperator)
    bpy.utils.unregister_class(StopServerOperator)
    bpy.utils.unregister_class(WebSocketServerSettings)
    #bpy.utils.unregister_class(AsyncLoopModalOperator)
    #bpy.types.VIEW3D_MT_object.remove(server_menu_func)

    #bpy.app.timers.unregister(tcp_handle_data)
    #if sock is not None:
    
    #stop_server()
        

if __name__ == "__main__":
    register()