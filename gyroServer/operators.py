import bpy
import re
from .tcp import start_server, stop_server, wserver

running = False

# START SERVER
class StartServerOperator(bpy.types.Operator):
    """Starts the Camera Server"""
    bl_idname = "camserver.start_server"
    bl_label = "Start Camera Server"
    server_addr: bpy.props.StringProperty(name="addr", description="TCP Server Address", default="0.0.0.0")
    server_port: bpy.props.IntProperty(name="port", description="TCP Server Port", default=56789, min=1000, max=2**16-1)


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
        return {"FINISHED"}


class SimpleOperator(bpy.types.Operator):
    """Tooltip"""
    bl_idname = "object.simple_operator"
    bl_label = "Simple Object Operator"

    @classmethod
    def poll(cls, context):
        return context.active_object is not None

    def execute(self, context):
        return {'FINISHED'}


def menu_func(self, context):
    self.layout.operator(SimpleOperator.bl_idname, text=SimpleOperator.bl_label)