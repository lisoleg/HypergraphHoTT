#!/usr/bin/env python3
"""Compile Coq files via stdin pipe to work around Windows lexer bug.
   Usage: python coq_compile_pipe.py [file1.v] [file2.v] ...
   If no files given, compiles all .v files listed in _CoqProject.
"""
import subprocess
import sys
import os

COQ_HOME = r"D:\Coq-Platform~8.19~2024.10"
COQ_BIN = os.path.join(COQ_HOME, "bin")
COQ_LIB = os.path.join(COQ_HOME, "lib", "coq")
COQ_CORE_LIB = os.path.join(COQ_HOME, "lib", "coq-core")

env = os.environ.copy()
env["PATH"] = COQ_BIN + os.pathsep + env.get("PATH", "")
env["COQLIB"] = COQ_LIB
env["COQCORELIB"] = COQ_CORE_LIB

def get_coqproject_files():
    """Parse _CoqProject to get .v files and flags."""
    flags = []
    vfiles = []
    with open("_CoqProject", "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("-"):
                flags.append(line)
            elif line.endswith(".v"):
                vfiles.append(line)
    return flags, vfiles

def compile_via_pipe(vfile, extra_flags):
    """Compile a .v file by piping its content to coqc stdin."""
    with open(vfile, "rb") as f:
        content = f.read()
    
    cmd = [os.path.join(COQ_BIN, "coqc.exe")] + extra_flags
    result = subprocess.run(cmd, input=content, capture_output=True, env=env)
    
    if result.returncode != 0:
        print(f"FAIL: {vfile}")
        if result.stderr:
            print(result.stderr.decode(errors="replace"))
        return False
    else:
        print(f"OK: {vfile}")
        return True

def main():
    extra_flags = ["-indices-matter", "-Q", ".", "HypergraphHoTT"]
    
    if len(sys.argv) > 1:
        vfiles = sys.argv[1:]
    else:
        _, vfiles = get_coqproject_files()
    
    passed = 0
    failed = 0
    for vf in vfiles:
        if compile_via_pipe(vf, extra_flags):
            passed += 1
        else:
            failed += 1
    
    print(f"\n=== Results: {passed} passed, {failed} failed out of {passed+failed} ===")
    return 0 if failed == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
