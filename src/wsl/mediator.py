import socket
import sys
import time
import threading

PORT=25642
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
broadcast_address=()

def broadcast_message(message):
    try:
        sock.sendto(message.encode(), broadcast_address)
    except Exception as e:
        print(f"Failed to send broadcast message. Error: {e}")

def listen_for_messages(windowsrouterip):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", PORT))
    print(f"Listening on port {PORT}...")
    while True:
        try:
            data, addr = sock.recvfrom(1024)
            if(addr[0]==windowsrouterip):
                continue
            print(f"Received message from {addr}: {data.decode()}")
            broadcast_message(data.decode())
        except Exception as e:
            print(f"Error receiving message: {e}")
            break
    
    sock.close()

if __name__ == "__main__":

    if len(sys.argv) == 2:
        print("Usage: python broadcast.py <broadcast ip> <windows route ip>")
    else:
        broadcast_address=(sys.argv[1],PORT)
        print(broadcast_address)
        listen_for_messages(sys.argv[2])