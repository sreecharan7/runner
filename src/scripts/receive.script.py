import socket
import time
import curses
import threading
import re
import sys
import getopt
from download import downloadfile

# Global variable to hold received messages
msgdatalist = {}

def extract_data(message):
    ip_pattern = r'IP Address: (\d+\.\d+\.\d+\.\d+)'
    port_pattern = r'Port: (\d+)'
    name_pattern = r'Name: (\w+)'

    ip_match = re.search(ip_pattern, message)
    port_match = re.search(port_pattern, message)
    name_match = re.search(name_pattern, message)

    if not ip_match or not port_match or not name_match:
        raise ValueError("Message format is incorrect.")

    ip_address = ip_match.group(1)
    port = port_match.group(1)
    name = name_match.group(1)

    return ip_address, port, name

def receive_broadcast(port=25642):
    global msgdatalist
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_address = ('0.0.0.0', port)
    sock.bind(server_address)
    
    print(f"Listening for broadcast messages on port {port}")

    while True:
        try:
            sock.settimeout(10)
            try:
                data, address = sock.recvfrom(4096)
                message = f"Received message: '{data.decode('utf-8')}' from {address}"
                extractedData = extract_data(message)
                msgdatalist[extractedData[0] + ":" + extractedData[1]] = extractedData[2]
            except socket.timeout:
                pass  
        except KeyboardInterrupt:
            print("Exiting...")
            break
        except Exception as e:
            print(f"Error receiving message: {e}")
            break
    
    sock.close()

def main(stdscr, output_path):
    global selected_option

    try:
        # Initialize curses
        curses.curs_set(0)
        curses.start_color()
        curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_BLUE)  # Define color pair 1 for blue background
        stdscr.keypad(1)
        stdscr.clear()

        basic = ['Exit']
        current_row = 0
        start_row = 0

        thread = threading.Thread(target=receive_broadcast)
        thread.daemon = True
        thread.start()

        stdscr.timeout(100)

        while True:
            stdscr.clear()
            h, w = stdscr.getmaxyx()

            # Heading
            heading = 'Scanning...'
            stdscr.addstr(0, w // 2 - len(heading) // 2, heading)

            # Space between heading and menu
            stdscr.addstr(1, 0, ' ' * w)  # Clear the line below the heading
            stdscr.addstr(2, 0, ' ' * w)  # Add an extra line of space

            menu = [f"{value}  :  {key}" for key, value in msgdatalist.items()] + basic
            
            if not menu or len(menu) <= 1:  # Check if menu is empty or only contains 'Exit'
                stdscr.addstr(2, w // 2 - len("No device detected in the network") // 2, "No device detected in the network")
                stdscr.refresh()

                key = stdscr.getch()
                if key == curses.KEY_ENTER or key in [10, 13]:
                    break
                continue

            display_size = h - 3  # Adjust for the extra line of space

            if current_row < start_row:
                start_row = current_row
            elif current_row >= start_row + display_size:
                start_row = current_row - display_size + 1

            display_menu = menu[start_row:start_row + display_size]

            for idx, row in enumerate(display_menu):
                x = w // 2 - len(row) // 2
                y = 2 + idx  # Adjust for the extra line of space
                if start_row + idx == current_row:
                    stdscr.attron(curses.color_pair(1))  # Use blue color pair
                    stdscr.addstr(y, x, row)
                    stdscr.attroff(curses.color_pair(1))
                else:
                    stdscr.addstr(y, x, row)

            stdscr.refresh()
            
            key = stdscr.getch()
            
            if key == curses.KEY_UP and current_row > 0:
                current_row -= 1
            elif key == curses.KEY_DOWN and current_row < len(menu) - 1:
                current_row += 1
            elif key == curses.KEY_ENTER or key in [10, 13]:
                if menu[current_row] == 'Exit':
                    break
                else:
                    stdscr.addstr(h - 1, 0, f'You selected {menu[current_row]}')
                    stdscr.refresh()
                    time.sleep(1)  # Wait for 1 second
                    stdscr.clear()
                    stdscr.refresh()
                    selected_option = menu[current_row]
                    break

    except Exception as e:
        stdscr.addstr(h - 1, 0, f"Error: {e}")
        stdscr.refresh()
        time.sleep(2)
    finally:
        stdscr.keypad(0)
        curses.endwin()
        words = selected_option.split()
        print(selected_option)
        if len(words) > 2:
            second_word = words[2]
        else:
            return
        downloadfile(second_word, output_path)

def parse_arguments(argv):
    try:
        opts, args = getopt.getopt(argv, "ho:", ["output_path="])
    except getopt.GetoptError:
        print('script.py -o <output_path>')
        sys.exit(2)
    output_path = None
    for opt, arg in opts:
        if opt == '-h':
            print('script.py -o <output_path>')
            sys.exit()
        elif opt in ("-o", "--output_path"):
            output_path = arg
    if not output_path:
        print('Output path must be provided.')
        sys.exit(2)
    return output_path

if __name__ == '__main__':
    output_path = parse_arguments(sys.argv[1:])
    curses.wrapper(main, output_path)
