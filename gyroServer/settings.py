import bpy
from bpy.types import AddonPreferences
from bpy.props import StringProperty, IntProperty, BoolProperty


class WebSocketServerSettings(AddonPreferences):
    bl_idname = __package__
    
    auto_start: BoolProperty(
        name="Start automatically",
        description="Automatically start the server when loading the add-on",
        default=False
    )
    
    host: StringProperty(
        name="Host",
        description="Listen on host:port",
        default="0.0.0.0"
    )
    
    port: IntProperty(
        name="Port",
        description="Listen on host:port",
        default=56789,
        min=0,
        max=65535,
        subtype="UNSIGNED"
    )

    def draw(self, context):
        layout = self.layout
        
        row = layout.row()
        split = row.split(factor=1.0, align=True)
        
        col = split.column()
        col.prop(self, "host")
        col.prop(self, "port")
        col.separator()
        
        col.prop(self, "auto_start")
        
        #if wserver:
        #    col.operator(Stop.bl_idname, icon='QUIT', text="Stop server")
        #else:
        #    col.operator(Start.bl_idname, icon='QUIT', text="Start server")
            
        #col = split.column()
        #col.label(text="Data to send:", icon='RECOVER_LAST')
        #col.prop(self, "data_to_send", expand=True)