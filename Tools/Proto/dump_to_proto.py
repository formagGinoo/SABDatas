#!/usr/bin/env python3
"""
Script to convert C# protobuf dump to .proto file format
"""

import re
import sys
from typing import Dict, List, Set, Tuple

def parse_csharp_to_proto(file_path: str) -> str:
    """Convert C# protobuf dump to .proto format"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    proto_content = []
    proto_content.append('syntax = "proto3";')
    proto_content.append('')
    
    # Extract all enums
    enum_pattern = r'public enum (\w+)[^{]*\{([^}]+)\}'
    enum_matches = re.findall(enum_pattern, content, re.DOTALL)
    
    for enum_name, enum_body in enum_matches:
        proto_content.append(f'enum {enum_name} {{')
        
        # Parse enum values
        enum_value_pattern = r'(\w+)\s*=\s*(\d+)'
        enum_values = re.findall(enum_value_pattern, enum_body)
        
        for value_name, value_number in enum_values:
            proto_content.append(f'  {value_name} = {value_number};')
        
        proto_content.append('}')
        proto_content.append('')
    
    # Extract all classes that extend ISdpStruct
    # Split content into lines and process class by class
    lines = content.split('\n')
    current_class = None
    current_fields = []
    in_class_body = False
    brace_count = 0
    
    classes = []
    
    for line in lines:
        line = line.strip()
        
        # Check for class declaration
        class_match = re.match(r'public class (\w+) : ISdpStruct', line)
        if class_match:
            current_class = class_match.group(1)
            current_fields = []
            in_class_body = False
            brace_count = 0
            continue
        
        # Check for opening brace of class
        if current_class and '{' in line:
            in_class_body = True
            brace_count += line.count('{')
            brace_count -= line.count('}')
            continue
        
        # If we're in a class body, look for fields
        if current_class and in_class_body:
            brace_count += line.count('{')
            brace_count -= line.count('}')
            
            # Check if this is a field line
            field_match = re.match(r'public\s+([^;]+?)\s+(\w+);\s*//.*', line)
            if field_match:
                field_type = field_match.group(1).strip()
                field_name = field_match.group(2).strip()
                # Skip if it's inside constructors, methods sections
                if not line.strip().startswith('//') and 'Constructors' not in line and 'Methods' not in line:
                    current_fields.append((field_type, field_name))
            
            # Check if class ended
            if brace_count <= 0:
                if current_fields:
                    classes.append((current_class, current_fields))
                current_class = None
                current_fields = []
                in_class_body = False
    
    # Generate messages for classes
    for class_name, fields in classes:
        proto_content.append(f'message {class_name} {{')
        
        field_number = 1
        for field_type, field_name in fields:
            proto_type = convert_type_to_proto(field_type)
            
            if proto_type:
                proto_content.append(f'  {proto_type} {field_name} = {field_number};')
                field_number += 1
            else:
                # Add comment for unsupported types
                proto_content.append(f'  // Unsupported type: {field_type} {field_name}')
                print(f"Warning: Unsupported type {field_type} for field {field_name} in class {class_name}")
        
        proto_content.append('}')
        proto_content.append('')
    
    return '\n'.join(proto_content)

def convert_type_to_proto(csharp_type: str) -> str:
    """Convert C# type to protobuf type"""
    
    # Basic type mappings
    type_mappings = {
        'uint': 'uint32',
        'int': 'int64',
        'ulong': 'uint64',
        'long': 'int64',
        'bool': 'bool',
        'string': 'string',
        'float': 'float',
        'double': 'double',
        'byte': 'uint32',
        'short': 'int32',
        'ushort': 'uint32',
    }
    
    # Handle basic types
    if csharp_type in type_mappings:
        return type_mappings[csharp_type]
    
    # Handle SDP types - keep as is for now
    if csharp_type.startswith('Sdp'):
        return csharp_type
    
    # Handle XList<T>
    xlist_match = re.match(r'XList<(.+)>', csharp_type)
    if xlist_match:
        inner_type = xlist_match.group(1)
        proto_inner_type = convert_type_to_proto(inner_type)
        if proto_inner_type:
            return f'repeated {proto_inner_type}'
        else:
            return f'repeated {inner_type}'  # Return as-is if we can't convert
    
    # Handle XDictionary<K,V> - convert to repeated message
    xdict_match = re.match(r'XDictionary<(.+),\s*(.+)>', csharp_type)
    if xdict_match:
        key_type = xdict_match.group(1)
        value_type = xdict_match.group(2)
        # For dictionaries, we'll need to create map types or repeated message
        key_proto = convert_type_to_proto(key_type) or key_type
        value_proto = convert_type_to_proto(value_type) or value_type
        return f'map<{key_proto}, {value_proto}>'
    
    # For other types (likely custom classes), return as is
    # This includes PlayerBaseInfo, etc.
    if csharp_type and not csharp_type.isspace():
        return csharp_type
    
    return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python dump_to_proto.py <input_cs_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    try:
        proto_output = parse_csharp_to_proto(input_file)
        
        # Write to output file
        output_file = "SilverAndBlood.proto"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(proto_output)
        
        print(f"Proto file generated: {output_file}")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
