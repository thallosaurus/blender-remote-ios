import bpy

class ServerPanel(bpy.types.Panel):
    """Tooltip"""
    bl_label = "Hello World Panel"
    bl_idname = "OBJECT_PT_hello"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"

    #@classmethod
    #def poll(cls, context):
    #    return context.active_object is not None
    
    #def execute(self, context):
    #    main(context)
    #    return {'FINISHED'}

    def draw(self, context):
        layout = self.layout

        obj = context.object

        row = layout.row()
        row.label(text="Camera Server", icon="WORLD_DATA")

        row = layout.row()
        row.operator("object.simple_operator")

        row = layout.row()
        props = row.operator("camserver.start_server")
        props.server_addr = "0.0.0.0"
        props.server_port = 56789

        row = layout.row()
        row.operator("camserver.stop_server")

        #row.operator("tcpserver.stop", text="Stop")
        #row = self.layout.row(align=True)
        #props = row.operator("tcpserver.start", text="Start")
        #self.layout.label(text="Running" if tcpserver else "Stopped")

        #row = layout.row()
        #row.prop(obj, "name")

        #row = layout.row()
        #row.operator("mesh.primitive_cube_add")

    
#def server_menu_func(self, context):
    #self.layout.operator(ServerOperator.bl_idname, text=ServerOperator.bl_label)

