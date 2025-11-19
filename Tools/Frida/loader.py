import frida
import psutil
import subprocess
import time
import os
import json

PROCESS_NAME = "SilverAndBlood.exe"
TYPESCRIPT_SOURCE = "CData_Dumper.ts"  # Source TypeScript file
SCRIPT_PATH = "hook.js"  # Compiled JavaScript output
LOG_FILE = "frida_output.log"
GAME_LAUNCHER_PATH = r"" # Path to the game executable e.g D:\\Games\\Silver And Blood\\SilverAndBlood\\SilverAndBlood.exe
OUTPUT_DIR = "cdata_dump"
MIN_RAM_MB = 150  # MB threshold to help detect dummy vs real

def log_print(message):
    print("[Loader] " + message)  # Print to console

def compile_frida_script():
    """Compila il file TypeScript in JavaScript usando frida-compile"""
    if not os.path.exists(TYPESCRIPT_SOURCE):
        log_print(f"TypeScript source file '{TYPESCRIPT_SOURCE}' not found!")
        return False
    
    log_print(f"Compiling {TYPESCRIPT_SOURCE} to {SCRIPT_PATH}...")
    
    try:
        result = subprocess.run([
            "frida-compile", 
            "-o", SCRIPT_PATH, 
            TYPESCRIPT_SOURCE
        ], 
        capture_output=True, 
        text=True, 
        cwd=os.getcwd()
        )
        
        if result.returncode == 0:
            log_print("✅ Frida script compiled successfully!")
            return True
        else:
            log_print(f"❌ Compilation failed!")
            log_print(f"Error: {result.stderr}")
            return False
    except FileNotFoundError:
        log_print("❌ npx not found! Make sure Node.js is installed and in PATH.")
        return False
    except Exception as e:
        log_print(f"❌ Compilation error: {e}")
        return False

def launch_game():
    if not os.path.exists(GAME_LAUNCHER_PATH):
        log_print(f"Game path not found: {GAME_LAUNCHER_PATH}")
        return
    log_print(f"Launching game: {GAME_LAUNCHER_PATH}")
    try:
        subprocess.Popen(GAME_LAUNCHER_PATH)
    except Exception as e:
        log_print(f"Failed to launch game: {e}")
        return
    log_print("Waiting for real game process to appear...")

def get_all_candidates():
    """Return list of (proc, mem_mb) matching PROCESS_NAME (case-insensitive)."""
    procs = []
    target_name = (PROCESS_NAME or "").lower()
    for proc in psutil.process_iter(["pid", "name", "create_time", "memory_info", "exe"]):
        try:
            name = (proc.info.get("name") or "").lower()
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
        if name == target_name:
            try:
                mem_info = proc.info.get("memory_info")
                mem_mb = (mem_info.rss if mem_info else 0) / (1024 * 1024)
                procs.append((proc, mem_mb))
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
    return procs

def identify_real_and_dummy():
    """Heuristic to pick real game process.

    - If two+ candidates: highest RAM is real, lowest is dummy.
    - If one candidate: treat as real when RAM >= MIN_RAM_MB.
    - Otherwise: keep waiting.
    """
    candidates = get_all_candidates()
    if not candidates:
        return None, None

    # If only one process, accept it when it's big enough
    if len(candidates) == 1:
        proc, mem_mb = candidates[0]
        if mem_mb >= MIN_RAM_MB:
            return proc, None
        return None, None

    # Two or more processes: sort by memory usage (high = real, low = dummy)
    sorted_procs = sorted(candidates, key=lambda x: x[1], reverse=True)
    real_proc, real_mem = sorted_procs[0]
    dummy_proc, dummy_mem = sorted_procs[-1]

    # If even the top candidate is tiny, keep waiting
    if real_mem < MIN_RAM_MB:
        return None, None

    return real_proc, dummy_proc

def kill_process(proc):
    try:
        log_print(f"Killing dummy process (PID={proc.pid})")
        proc.terminate()
        proc.wait(timeout=5)
        log_print("Dummy process terminated.")
    except Exception as e:
        log_print(f"Could not terminate dummy process: {e}")

def save_json_file(class_name, json_data):
    """Salva i dati JSON in un file nella cartella di output"""
    try:
        # Crea la cartella se non esiste
        os.makedirs(OUTPUT_DIR, exist_ok=True)
        
        # Nome del file
        filename = f"{OUTPUT_DIR}/{class_name}.json"
        
        # Salva il file
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(json_data)
        
        log_print(f"Saved {class_name} to {filename}")
        return True
    except Exception as e:
        log_print(f"Error saving {class_name}: {e}")
        return False

def main():
    # Compila automaticamente lo script Frida
    if not compile_frida_script():
        log_print("Cannot proceed without a compiled script.")
        return
    
    if not os.path.exists(SCRIPT_PATH):
        log_print(f"Script '{SCRIPT_PATH}' not found after compilation!")
        return

    # Crea la cartella di output
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    launch_game()

    # Wait for process with timeout and helpful diagnostics
    real_proc = dummy_proc = None
    start_time = time.time()
    timeout_sec = 120
    last_report = 0
    while real_proc is None and (time.time() - start_time) < timeout_sec:
        real_proc, dummy_proc = identify_real_and_dummy()
        now = time.time()
        # Report every 5s what we see
        if now - last_report >= 5 and real_proc is None:
            last_report = now
            candidates = get_all_candidates()
            if candidates:
                snapshot = ", ".join([f"PID={p.pid} RAM={int(mb)}MB" for p, mb in candidates])
                log_print(f"Still waiting... found candidates: {snapshot}")
            else:
                log_print("Still waiting... no matching processes found yet.")
        time.sleep(1)

    if real_proc is None:
        log_print("Timeout while waiting for the game process.\n" \
                  "Tips: ensure the game is launching, PROCESS_NAME matches exactly, and try running this script as Administrator.")
        return

    if dummy_proc:
        kill_process(dummy_proc)

    log_print(f"Attaching to real game process: PID={real_proc.pid}")

    try:
        session = frida.attach(real_proc.pid)
    except frida.ProcessNotFoundError:
        log_print("Failed to attach to the process.")
        return

    with open(SCRIPT_PATH, "r", encoding="utf-8") as f:
        script_code = f.read()

    script = session.create_script(script_code)

    with open(LOG_FILE, "w", encoding="utf-8") as logfile:
        def on_message(msg, data):
            if msg["type"] == "send":
                payload = msg["payload"]
                
                # Gestisce i messaggi JSON da salvare
                if isinstance(payload, dict) and payload.get('type') == 'save_json':
                    class_name = payload.get('className', 'unknown')
                    json_data = payload.get('data', '{}')
                    
                    if save_json_file(class_name, json_data):
                        success_msg = f"Successfully saved {class_name}.json"
                        log_print(success_msg)
                        logfile.write(success_msg + "\n")
                    else:
                        error_msg = f"Failed to save {class_name}.json"
                        log_print(error_msg)
                        logfile.write(error_msg + "\n")
                else:
                    # Messaggi di console normali
                    print(payload)
                    logfile.write(str(payload) + "\n")
                
                logfile.flush()
                
            elif msg["type"] == "error":
                error_msg = f"Script error: {msg['stack']}"
                print(error_msg)
                logfile.write(error_msg + "\n")
                logfile.flush()

        script.on("message", on_message)
        script.load()

        log_print("Script loaded. Output is being saved to frida_output.log.")
        log_print(f"JSON files will be saved to: {os.path.abspath(OUTPUT_DIR)}")
        log_print("Waiting for CData dumps...")
        input("[Loader] Press Enter to quit...\n")

if __name__ == "__main__":
    main()
