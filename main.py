import sys
import platform

def check_system():
    print(f"[Kiberxavfliy] Operating System: {platform.system()} {platform.release()}")
    if platform.system() != 'Darwin':
        print("[Warning] This tool is optimized for macOS (MacBook).")

def main():
    print("========================================")
    print("   KIBERXAVFLIY - Liquid Glass Edition   ")
    print("========================================")
    check_system()
    print("[Info] Initializing Liquid Glass UI Engine...")
    print("[Ready] Kiberxavfliy security tool is running.")

if __name__ == '__main__':
    main()
