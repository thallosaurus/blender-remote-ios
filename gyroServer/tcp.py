import socket
import sys
import bpy
import select
import threading
import queue
import math
import json

#from websockets.sync.server import serve
from wsgiref.simple_server import make_server
from ws4py.websocket import WebSocket as _WebSocket
from ws4py.server.wsgirefserver import WSGIServer, WebSocketWSGIRequestHandler
from ws4py.server.wsgiutils import WebSocketWSGIApplication
from bpy.app.handlers import persistent

#sock = None

threads = []
wserver = None
wserver_thread = None

shutdown = False

from zeroconf import Zeroconf, ServiceInfo

zc = Zeroconf()
zc_info = None

fqdn = socket.gethostname()

# TODO Blender Settings
#ip_addr = socket.gethostbyname(fqdn)
#hostname = fqdn.split(".")[0]

def make_zc_desc(ip, port):
    zc_service_name = "Blender Camera"
    zc_base = {'service': zc_service_name, 'version': '1.0.0', "ip": ip, "port": 56789}
    return ServiceInfo('_blender-cam._tcp.local.',
        'server._blender-cam._tcp.local.', 
        addresses=[socket.inet_aton(ip)],
        port=56789,
        properties=zc_base)
        #server=hostname + '.local')


def start_server(host, port):
    global wserver
    if wserver:
        return False
    
    wserver = make_server(host, port,
        server_class=WSGIServer,
        handler_class=WebSocketWSGIRequestHandler,
        app=WebSocketWSGIApplication(handler_cls=WebSocketApp)
    )
    wserver.initialize_websockets_manager()

    global webserver_thread
    wserver_thread = threading.Thread(target=wserver.serve_forever)
    wserver_thread.daemon = True
    wserver_thread.start()
    print("ws listening on ""+:56789")
    #server = serve(echo, "")

    global zc_info
    zc_info = make_zc_desc(ip=host,port=port)
    zc.register_service(zc_info)


    #conn.settimeout(0.0)
    bpy.app.timers.register(queue_handler)

    #bpy.app.handlers.load_post.append(load_post)

    # TODO Add handler for when cameras are added/removed
    #bpy.app.handlers.scene_update_post.append(scene_update_post)
    
    return True

def stop_server():
    global wserver
    if not wserver:
        return False
    
    #bpy.app.timers.unregister(queue_handler)
    
    wserver.shutdown()
    for socket in sockets:
        socket.close()

    wserver = None

    global zc_info
    zc.unregister_service(zc_info)

    #bpy.app.handlers.load_post.remove(load_post)
    #bpy.app.handlers.scene_update_post.remove(scene_update_post)
    
    return True

message_queue = queue.Queue()            
sockets = []
clients = {}

def get_cam_ids():
#    data = []

#    for obj in bpy.data.cameras:
#        data.append({"name": obj.name})

    return list(map(lambda obj: {
        "name": obj.name
    }, bpy.data.cameras))

class WebSocketApp(_WebSocket):
    def opened(self):
        # Connection is open
        #send_state([self])
        
        print("client open")
        sockets.append(self)

        load_post =lambda: self.send_camera_list

        bpy.app.handlers.load_post.append(load_post)

        self.send_camera_list()
        pass

    """
    Gets run when the server gets closed
    """
    def closed(self, code, reason=None):
        #sockets.remove(self)
        print("bye")

    def received_message(self, message):
        data = json.loads(message.data.decode(message.encoding))
        message_queue.put(data)
        pass

    def send_camera_list(self):
                # send initial camera data
        cam_ids = get_cam_ids()
        camera = bpy.context.scene.camera
        data = json.dumps({"utype": "cameras", "data": cam_ids, "current": camera.name})
        print(data)
        self.send(payload=data,binary=False)

@persistent
def queue_handler():
    while not message_queue.empty():
        data = message_queue.get()

        if data["utype"] == "sensor":
            #camera = bpy.data.objects[data["cameraId"]]
            camera = bpy.context.scene.camera

#            if camera is not None:
            camera.rotation_euler = (data["x"] * -1, data["y"], data["z"])
                #camera.location = (data["ax"], data["ay"], data["z"])
                #camera.location[0] += data["ax"]
                #camera.location[1] += data["ay"]
                #camera.location[2] += data["az"]

        elif data["utype"] == "camselect":
            camera = bpy.data.objects[data["cameraId"]]
            if camera is not None:
                bpy.context.scene.camera = camera

        elif data["utype"] == "camcreate":
            print(data)
            camera = bpy.data.cameras.new(name=data["name"])
            camera.lens_unit = "FOV"
            camera.lens = data["FOV"]
            camera_object = bpy.data.objects.new(data["name"], camera)
            camera_object.location = [
                data["x"],
                data["y"],
                data["z"]
            ]
            bpy.context.scene.collection.objects.link(camera_object)

            cam_ids = get_cam_ids()
            data = json.dumps({"utype": "cameras", "data": cam_ids})
            broadcast(data, False)

        #elif data["utype"] == "switchvp":
        #    for area in bpy.context.screen.areas: # iterate through areas in current screen
        #        if area.type == 'VIEW_3D':
        #            for space in area.spaces: # iterate through spaces in current VIEW_3D area
        #                if space.type == 'VIEW_3D': # check if space is a 3D view
        #                    space.viewport_shade = 'RENDERED' # set the viewport shading to rendered

        else:
            print("Unknown utype" + data["utype"])


    if shutdown:
        return None
    else:
        return 0.01

def broadcast(message, binary=True):
    for s in sockets:
        try:
            s.send(payload=message,binary=binary)
        except:
            pass
