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

#sock = None

threads = []
wserver = None

def start_server(host, port):
    #global sock
    #sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #sock.bind((host, port))
    #sock.listen()

    global wserver
    if wserver:
        return False
    
    wserver = make_server(host, port,
        server_class=WSGIServer,
        handler_class=WebSocketWSGIRequestHandler,
        app=WebSocketWSGIApplication(handler_cls=WebSocketApp)
    )
    wserver.initialize_websockets_manager()

    wserver_thread = threading.Thread(target=wserver.serve_forever)
    wserver_thread.daemon = True
    wserver_thread.start()
    print("ws listening on 0.0.0.0:56789")
    #server = serve(echo, "")


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
    
    wserver.shutdown()
    for socket in sockets:
        socket.close()

    wserver = None

    bpy.app.timers.unregister(queue_handler)
    #bpy.app.handlers.load_post.remove(load_post)
    #bpy.app.handlers.scene_update_post.remove(scene_update_post)
    
    return True

message_queue = queue.Queue()            
sockets = []

def get_cam_ids():
    data = []

    for obj in bpy.data.cameras:
        data.append({"name": obj.name})

    return data

class WebSocketApp(_WebSocket):
    def opened(self):
        # Connection is open
        #send_state([self])
        
        sockets.append(self)

        # send initial camera data
        cam_ids = get_cam_ids()
        data = json.dumps({"utype": "init", "data": cam_ids})
        self.send(payload=data,binary=False)

        pass

    def closed(self, code, reason=None):
        sockets.remove(self)

    def received_message(self, message):
        data = json.loads(message.data.decode(message.encoding))
        message_queue.put(data)

        pass

def queue_handler():
    while not message_queue.empty():
        data = message_queue.get()
        camera = bpy.data.objects[data["cameraId"]]

        if camera is not None:
            camera.rotation_euler = (data["x"] * -1, data["y"], data["z"])
            #camera.location = (data["ax"], data["ay"], data["z"])
            #camera.location[0] += data["ax"]
            #camera.location[1] += data["ay"]
            #camera.location[2] += data["az"]

    return 0.01