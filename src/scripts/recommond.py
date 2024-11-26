import difflib
import argparse
import sys

def load_commands(file_path):
    """
    Load commands from a text file.
    Each command should be on a separate line.
    """
    try:
        with open(file_path, 'r') as file:
            return [line.strip() for line in file.readlines()]
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)

def recommend_command(input_command, command_list):
    """
    Recommends the nearest command from the list based on similarity.
    """
    # Use difflib to find the closest matches
    closest_matches = difflib.get_close_matches(input_command, command_list, n=1, cutoff=0.1)
    
    if closest_matches:
        return closest_matches[0]  # Return the best match
    else:
        return None  # No close match found

# Set up argument parser
parser = argparse.ArgumentParser(description="Command Recommendation System")
parser.add_argument("file", help="Path to the text file containing commands")
parser.add_argument("command", help="Input command to find a match for")

# Parse the arguments
args = parser.parse_args()

# Load commands from file
commands = load_commands(args.file)

# Get the recommendation
suggestion = recommend_command(args.command, commands)

# Output the result
if suggestion:
    print(f"Did you mean: {suggestion}?")
else:
    print("No similar command found.")