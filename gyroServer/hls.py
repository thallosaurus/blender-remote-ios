import os
#import time
import subprocess
from subprocess import PIPE
import threading
import signal
import sys

#from flask import Flask, send_from_directory

# Erstelle den Ordner für HLS-Streaming
#os.makedirs("hls", exist_ok=True)

# Starte Flask
#app = Flask(__name__)

#@app.route('/stream/<path:filename>')
#def stream(filename):
#    """ Flask-Route, um die HLS-Dateien bereitzustellen """
#    return send_from_directory("hls", filename)

fifo_path = "hls_sink"

frame_in = open("frame.png", "r")

closing = False
os.mkfifo(fifo_path)
fifo = os.open(fifo_path, os.O_WRONLY | os.O_NONBLOCK)

def stream_input():
    while not closing:
        os.write(fifo, frame_in)
        



def start_ffmpeg():
    """ Starte FFmpeg, um PNGs als HLS-Video zu streamen """
    cmd = [
        "ffmpeg", 
        "-framerate", "2",  # 2 FPS (anpassen je nach Bedarf)
        "-i", fifo_path,  # PNG-Dateien im Ordner "frames/"
        "-c:v", "libx264", 
        "-pix_fmt", "yuv420p",
        "-preset", "ultrafast",
        "-tune", "zerolatency",
        "-hls_time", "2",  # Länge jedes Segments
        "-hls_list_size", "5",  # Anzahl der Segmente in Playlist
        "-f", "hls",
        "stream.m3u8"
    ]
    proc = subprocess.Popen(cmd, stdin=PIPE, stdout=PIPE)
    proc.wait()


def signal_handler(sig, frame):
    print('You pressed Ctrl+C!')
    os.close(fifo)
    sys.exit(0)

if __name__ == '__main__':
    #os.makedirs("frames", exist_ok=True)  # Speicherort für PNGs
    stream_input_thread = threading.Thread(target=stream_input)
    stream_input_thread.start()

    ffmpeg_thread = threading.Thread(target=start_ffmpeg)
    ffmpeg_thread.start()

    signal.signal(signal.SIGINT, signal_handler)
print('Press Ctrl+C')
signal.pause()
    #start_ffmpeg()  # Starte FFmpeg zum Streamen
    #app.run(host='0.0.0.0', port=5000)