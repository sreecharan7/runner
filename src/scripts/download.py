import requests
import re
import tarfile
import os
import sys
import getopt

def get_filename_from_cd(cd):
    """
    Extracts filename from Content-Disposition header.
    """
    if not cd:
        return None
    fname = re.findall('filename=(.+)', cd)
    if len(fname) == 0:
        return None
    return fname[0].strip('"')

def extract_tar_gz(filename, output_path):
    """
    Extracts a .tar.gz file to a directory named after the file (without the .tar.gz extension).
    """
    folder_name = os.path.join(filename.rsplit('.', 2)[0])  # Remove the .tar.gz extension
    print(filename.rsplit('.', 2)[0],output_path);
    try:
        with tarfile.open(filename, "r:gz") as tar:
            tar.extractall(folder_name)
            print(f"Extracted {filename} to {folder_name} successfully.")
            os.remove(filename)
    except tarfile.TarError as e:
        print(f"Error extracting {filename}: {e}")

def download_file_with_progress(url, output_path):
    try:
        # Send GET request to the URL
        with requests.get(url, stream=True) as response:
            # Handle specific status codes
            if response.status_code == 403:
                return "Incorrect password."
            elif response.status_code == 404:
                return "Server down."

            response.raise_for_status()  # Ensure we got a valid response

            # Extract the file name from the Content-Disposition header
            local_filename = get_filename_from_cd(response.headers.get('content-disposition'))
            if not local_filename:
                local_filename = "downloaded_file"
            
            local_filename = os.path.join(output_path, local_filename)
            
            # Get the total file size from the response headers
            total_size = int(response.headers.get('content-length', 0))
            downloaded_size = 0
            
            # Open the local file for writing in binary mode
            with open(local_filename, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    file.write(chunk)
                    downloaded_size += len(chunk)
                    
                    # Calculate and print the download progress
                    progress = (downloaded_size / total_size) * 100
                    print(f"Downloading {local_filename}: {progress:.2f}%", end="\r")
        
        print(f"\nFile downloaded as {local_filename}")

        if local_filename.endswith('.tar.gz'):
            extract_tar_gz(local_filename, output_path)
        return f"File downloaded as {local_filename}"

    except requests.exceptions.RequestException as e:
        return f"Error: {e}"

def downloadfile(adress, output_path):
    password = ""
    result = download_file_with_progress("http://" + adress, output_path)
    if result != "Incorrect password.":
        return result
    print("Enter the password:")
    password = input()
    while True:
        result = download_file_with_progress("http://" + adress + "?password=" + password, output_path)
        if result == "Incorrect password.":
            print("Password was wrong")
            print("Please enter the password again")
            password = input()
        elif result == "Server down.":
            print("Server down. Try again")
            break
        else:
            return result

def main(argv):
    try:
        opts, args = getopt.getopt(argv, "ha:o:", ["address=", "output_path="])
    except getopt.GetoptError:
        print('script.py -a <address> -o <output_path>')
        sys.exit(2)
    address = None
    output_path = None
    for opt, arg in opts:
        if opt == '-h':
            print('script.py -a <address> -o <output_path>')
            sys.exit()
        elif opt in ("-a", "--address"):
            address = arg
        elif opt in ("-o", "--output_path"):
            output_path = arg
    if not address or not output_path:
        print('Both address and output_path must be provided.')
        sys.exit(2)
    
    print(downloadfile(address, output_path))

if __name__ == "__main__":
    main(sys.argv[1:])
