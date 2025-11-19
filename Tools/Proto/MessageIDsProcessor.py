import os
import re
import json

def scan_lua_files(directory):
    """Trova tutti i file .lua nella directory"""
    lua_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.lua'):
                lua_files.append(os.path.join(root, file))
    return lua_files

def extract_cmd_ids(filepath):
    """Estrae tutti i CmdId da un file"""
    cmd_ids = {}
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as file:
            content = file.read()
            
            # Pattern per CmdId_Nome = numero
            pattern1 = r'(CmdId_\w+)\s*=\s*([-]?\d+)'
            matches1 = re.findall(pattern1, content)
            
            for cmd_name, value in matches1:
                cmd_ids[cmd_name] = int(value)
            
            # Pattern per trovare solo nomi CmdId_ senza valore
            pattern2 = r'(CmdId_\w+)'
            matches2 = re.findall(pattern2, content)
            
            for cmd_name in matches2:
                if cmd_name not in cmd_ids:
                    cmd_ids[cmd_name] = "UNDEFINED"
                    
    except Exception as e:
        print(f"Errore leggendo {filepath}: {e}")
    
    return cmd_ids

def divide_command_ids(data):
    """
    Divide i command IDs in base al suffisso CS o SC.
    
    Args:
        data (dict): Dizionario con tutti i command IDs
    
    Returns:
        tuple: (cs_commands, sc_commands, other_commands)
    """
    cs_commands = {}
    sc_commands = {}
    other_commands = {}
    
    # Dividi i comandi in base al suffisso
    for key, value in data.items():
        if key.endswith('_CS'):
            cs_commands[key] = value
        elif key.endswith('_SC'):
            sc_commands[key] = value
        else:
            # Aggiungi comandi senza suffisso CS/SC al file other
            other_commands[key] = value
    
    return cs_commands, sc_commands, other_commands

def save_json_file(data, filename):
    """Salva i dati in un file JSON"""
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, sort_keys=True, ensure_ascii=False)
        print(f"File {filename} creato con {len(data)} comandi.")
        return True
    except Exception as e:
        print(f"Errore nella scrittura del file {filename}: {e}")
        return False

def main():
    lua_scripts_path = r"" # path to lua decompiled scripts directory e.g D:\\Games\\~SilverAndBloodReverse\\SABDatas\\LuaScripts
    
    # File di output
    cs_output_file = "CSMessageID.json"
    sc_output_file = "SCMessageID.json"
    other_output_file = "MessageID.json"
    
    print(f"Scansionando directory: {lua_scripts_path}")
    
    lua_files = scan_lua_files(lua_scripts_path)
    all_cmd_ids = {}
    
    # Processa ogni file
    for filepath in lua_files:
        filename = os.path.basename(filepath)
        # Filtra file che potrebbero contenere CmdId
        if any(keyword in filename for keyword in ['Proto', 'Cmd', 'Notify_', 'Req_', 'Rsp_']):
            print(f"Processando: {filename}")
            cmd_ids = extract_cmd_ids(filepath)
            all_cmd_ids.update(cmd_ids)
    
    print(f"\nTrovati {len(all_cmd_ids)} Command IDs totali")
    
    # Dividi i comandi per tipo
    cs_commands, sc_commands, other_commands = divide_command_ids(all_cmd_ids)
    
    # Salva i file divisi
    save_json_file(cs_commands, cs_output_file)
    save_json_file(sc_commands, sc_output_file)
    save_json_file(other_commands, other_output_file)
    
    # Statistiche finali
    print(f"\nStatistiche:")
    print(f"Totale comandi processati: {len(all_cmd_ids)}")
    print(f"Comandi CS: {len(cs_commands)}")
    print(f"Comandi SC: {len(sc_commands)}")
    print(f"Altri comandi: {len(other_commands)}")
    
    # Mostra i primi 10 di ogni categoria
    print("\nPrimi 10 Command IDs CS:")
    sorted_cs = sorted(cs_commands.items())
    for i, (name, value) in enumerate(sorted_cs[:10]):
        print(f"  {name} = {value}")
    
    print("\nPrimi 10 Command IDs SC:")
    sorted_sc = sorted(sc_commands.items())
    for i, (name, value) in enumerate(sorted_sc[:10]):
        print(f"  {name} = {value}")
    
    print("\nPrimi 10 Altri Command IDs:")
    sorted_other = sorted(other_commands.items())
    for i, (name, value) in enumerate(sorted_other[:10]):
        print(f"  {name} = {value}")

if __name__ == "__main__":
    main()