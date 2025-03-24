import bpy
import gpu
from mathutils import Matrix
from gpu_extras.presets import draw_circle_2d
from .tcp import broadcast
import numpy as np
import cv2
from PIL import Image

cur_width = 1920
cur_height = 1080

frame = None
img = None

capture_frames = False

def capture_viewport():
    global frame, img

    #buffer = None
    region = bpy.context.region
    width, height = region.width, region.height

    offscreen = gpu.types.GPUOffScreen(width, height)
    context = bpy.context
    scene = context.scene

    view_matrix = scene.camera.matrix_world.inverted()

    projection_matrix = scene.camera.calc_matrix_camera(
        context.evaluated_depsgraph_get(), x=width, y=height)
    
    offscreen.draw_view3d(
        scene,
        context.view_layer,
        context.space_data,
        context.region,
        view_matrix,
        projection_matrix,
        do_color_management=True
    )

    gpu.state.depth_mask_set(False)

    with offscreen.bind():
        fb = gpu.state.active_framebuffer_get()            
        frame = fb.read_color(0, 0, width, height, 4, 0, 'UBYTE')
        img = Image.frombuffer(mode="RGBA", data=frame, size=(width, height)).transpose(Image.FLIP_TOP_BOTTOM)

    offscreen.free()

    global cur_width, cur_height
    cur_width = width,
    cur_height = height

def stream_vp():
    if img is not None:
        f = np.array(img)
        #i = cv2.resize(f, img.width / 2, img.height / 2, interpolation=cv2.INTER_LINEAR)
        im_rgb = cv2.cvtColor(f, cv2.COLOR_BGRA2RGBA)
        success, buffer = cv2.imencode('.png', im_rgb)

        global capture_frames
        if capture_frames:
            with open("frame.png", "wb") as f:
                f.write(buffer.tobytes())

        if success:
            try:
                broadcast(buffer.tobytes(), binary=True)
            except:
                pass
    return 0.01

def opencv_window():
    capture_viewport()
    global img
    img.show()

handle = None
def start_capture():
    global handle
    handle = bpy.types.SpaceView3D.draw_handler_add(capture_viewport, (), 'WINDOW', 'POST_PIXEL')
    print("Starting Viewport Capture")
    bpy.app.timers.register(stream_vp)
    capture_viewport()

def stop_capture():
    print("Stopping Viewport Capture")
    bpy.types.SpaceView3D.draw_handler_remove(handle, 'WINDOW')
    bpy.app.timers.unregister(stream_vp)