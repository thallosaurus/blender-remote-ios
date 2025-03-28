import bpy
import re
from .tcp import start_server, stop_server
from .video import start_capture, stop_capture, opencv_window

running = False

# START SERVER
class StartServerOperator(bpy.types.Operator):
    """Starts the Camera Server"""
    bl_idname = "camserver.start_server"
    bl_label = "Start Camera Server"
    #server_addr: bpy.props.StringProperty(name="addr", description="TCP Server Address", default="0.0.0.0")
    #server_port: bpy.props.IntProperty(name="port", description="TCP Server Port", default=56789, min=1000, max=2**16-1)

    #server_addr: None
    #server_port: None


    @classmethod
    def poll(cls, context):
        # !!!
        #return sock is None
        return not running
    
    def execute(self, context):
        #return self.invoke(context, None)
        global running

        preferences = context.preferences
        addon_prefs = preferences.addons[__package__].preferences

        running = start_server(addon_prefs.host, addon_prefs.port)
        start_capture()
        return {"RUNNING_MODAL"}
  
# STOP SERVER
class StopServerOperator(bpy.types.Operator):
    """Stops the Camera Server"""
    bl_idname = "camserver.stop_server"
    bl_label = "Stop Camera Server"

    @classmethod
    def poll(cls, context):
        # !!!
        #return sock is not None
        return running
    
    def execute(self, context):
        #return self.invoke(context, None)
        global running
        running = not stop_server()
        stop_capture()
        return {"FINISHED"}

class CaptureViewport(bpy.types.Operator):
    """Debugs the Capture Viewport Operator"""
    bl_idname = "objects.debug_capture_viewport"
    bl_label = "Debug Capture Viewport"

    @classmethod
    def poll(cls, context):
        return True

    def execute(self, context):
        start_capture()
        #data = capture_viewport()
        #print(data)
        return {'RUNNING_MODAL'}
    
class StopCaptureViewport(bpy.types.Operator):
    """Stops the Viewport Capture"""
    bl_idname = "objects.debug_stop_capture_viewport"
    bl_label = "Stop Capture Viewport"

    @classmethod
    def poll(cls, context):
        return True

    def execute(self, context):
        stop_capture()
        #data = capture_viewport()
        #print(data)
        return {'FINISHED'}

class OpenCVDebugWindow(bpy.types.Operator):
    bl_idname = "objects.opencv_debug"
    bl_label = "Show OpenCV Window"

    @classmethod
    def poll(cls, context):
        return True
    
    def execute(self, context):
        opencv_window()