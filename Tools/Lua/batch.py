#!/usr/bin/env python3
import sys
import shutil
import subprocess
from pathlib import Path

def main():
    if len(sys.argv) < 4:
        print("Usage: batch.py <unluac_path> <input_dir> <output_dir>", file=sys.stderr)
        sys.exit(1)
    
    unluac_path = Path(sys.argv[1])
    in_dir = Path(sys.argv[2])
    out_dir = Path(sys.argv[3])
    
    iter_dir(in_dir, in_dir, out_dir, unluac_path)

def iter_dir(current_dir, base_in_dir, base_out_dir, unluac_path):
    """
    Recursively iterate through directory and process files
    """
    try:
        if not current_dir.is_dir():
            return
            
        for item in current_dir.iterdir():
            if item.name in ['.', '..']:
                continue
            
            if item.is_dir():
                iter_dir(item, base_in_dir, base_out_dir, unluac_path)
            else:
                print(str(item))
                
                # Calculate output directory
                relative_dir = item.parent.relative_to(base_in_dir)
                out_path = base_out_dir / relative_dir
                
                # Create output directory if it doesn't exist
                out_path.mkdir(parents=True, exist_ok=True)
                
                # Process file based on extension
                if item.name.lower().endswith('bytes'):
                    # Process .lua files with unluac
                    output_file = out_path / (item.stem + ".lua")
                    try:
                        with open(output_file, 'w', encoding='utf-8') as f:
                            subprocess.run([
                                'java', '-jar', str(unluac_path),
                                '--rawstring', str(item)
                            ], stdout=f, check=True)
                    except subprocess.CalledProcessError as e:
                        print(f"Error processing {item}: {e}", file=sys.stderr)
                    except Exception as e:
                        print(f"Error writing to {output_file}: {e}", file=sys.stderr)
                elif item.name.lower().endswith('.lua'):
                    # Copy other files as-is
                    output_file = out_path / item.name
                    try:
                        with open(output_file, 'w', encoding='utf-8') as f:
                            subprocess.run([
                                'java', '-jar', str(unluac_path),
                                '--rawstring', str(item)
                            ], stdout=f, check=True)
                    except subprocess.CalledProcessError as e:
                        print(f"Error processing {item}: {e}", file=sys.stderr)
                    except Exception as e:
                        print(f"Error writing to {output_file}: {e}", file=sys.stderr)
                        
    except PermissionError as e:
        print(f"Permission denied accessing {current_dir}: {e}", file=sys.stderr)
    except Exception as e:
        print(f"Error processing directory {current_dir}: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
