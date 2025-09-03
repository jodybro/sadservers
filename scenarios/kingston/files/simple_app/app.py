#!/usr/bin/env python3

import time
import os

def main():
    print("Kingston Docker Optimization Demo")
    print("=================================")
    print(f"App started at: {time.ctime()}")
    print("Listening on port 8080...")
    
    # Create some log entries to simulate activity
    log_dir = "/app/logs"
    if os.path.exists(log_dir):
        with open(f"{log_dir}/app.log", "w") as f:
            f.write(f"App started at {time.ctime()}\n")
    
    # Simple server simulation
    while True:
        print(f"[{time.ctime()}] Application running...")
        time.sleep(60)

if __name__ == "__main__":
    main()