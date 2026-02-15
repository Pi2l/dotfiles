import sys
import os
import toml

def usage():
    print(f"Usage: {sys.argv[0]} <read|write> <file_path> <section> <key> [value]")
    sys.exit(1)

def load_toml(path):
    if not os.path.exists(path):
        return {}
    try:
        with open(path, 'r') as f:
            return toml.load(f)
    except Exception as e:
        print(f"Error reading {path}: {e}", file=sys.stderr)
        sys.exit(1)

def save_toml(path, data):
    try:
        with open(path, 'w') as f:
            toml.dump(data, f)
    except Exception as e:
        print(f"Error writing {path}: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    # Expecting: [script_name, command, filepath, section, key, (value)]
    if len(sys.argv) < 5:
        usage()

    command = sys.argv[1]
    file_path = sys.argv[2]
    section = sys.argv[3]
    key = sys.argv[4]

    if command == "read":
        data = load_toml(file_path)
        val = data.get(section, {}).get(key)
        if val is not None:
            print(val)
    
    elif command == "write":
        if len(sys.argv) < 6:
            print("Error: Missing value for write command", file=sys.stderr)
            usage()
        
        # Join all remaining arguments to handle values with spaces
        value = " ".join(sys.argv[5:])
        
        data = load_toml(file_path)
        
        if section not in data:
            data[section] = {}
        
        data[section][key] = value
        save_toml(file_path, data)
    
    else:
        usage()

if __name__ == "__main__":
    main()

