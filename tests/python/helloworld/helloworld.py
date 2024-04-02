#!/usr/bin/env python

import sys

def main():
    print("Hello, World!")
    print(f"sys.version={sys.version}")
    print(f"sys.argv[0]={sys.argv[0]}")
    return 0

if __name__ == "__main__":
    rc = main()
    sys.exit(rc)
