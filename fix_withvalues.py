#!/usr/bin/env python3
import os
import re
import glob

def fix_withvalues_to_withopacity(file_path):
    """Replace all withValues(alpha:) calls with withOpacity() in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern to match .withValues(alpha: number)
        pattern = r'\.withValues\(alpha:\s*([\d.]+)\)'
        replacement = r'.withOpacity(\1)'
        
        new_content = re.sub(pattern, replacement, content)
        
        if content != new_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed: {file_path}")
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    # Get all Dart files in the lib folder
    dart_files = glob.glob(r"lib\**\*.dart", recursive=True)
    
    fixed_count = 0
    for file_path in dart_files:
        if fix_withvalues_to_withopacity(file_path):
            fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == "__main__":
    main()
