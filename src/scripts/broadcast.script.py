import socket
import time
import sys

def process_data(data):
    # Process your data here
    ip_broadcast_pairs = []
    for line in data.split('\n'):
        parts = line.strip().split()
        if len(parts) == 2:
            ip_broadcast_pairs.append((parts[0], parts[1]))
        else:
            print(f"Invalid line in data: {line.strip()}")
    return ip_broadcast_pairs

def broadcast_message(ip_broadcast_pairs, port ,name,servingPort=25642):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

    try:
        while True:
            for ip, broadcast_ip in ip_broadcast_pairs:
                message = f"This is runner command sending msg i am at IP Address: {ip}, Port: {port} Name: {name}"
                broadcast_address = (broadcast_ip, servingPort)
                print(f"Broadcasting message: '{message}' to {broadcast_address}")
                sock.sendto(message.encode('utf-8'), broadcast_address)
            time.sleep(5)
    except KeyboardInterrupt:
        print("Exiting...")
    except Exception as e:
        print(f"Error broadcasting message: {e}")
    finally:
        sock.close()

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <ip_broadcast_data> <port>")
        sys.exit(1)

    data = sys.argv[1]
    port = int(sys.argv[2])
    name = sys.argv[3]

    print("Data received:")
    print(data)

    ip_broadcast_pairs = process_data(data)
    broadcast_message(ip_broadcast_pairs, port,name)
