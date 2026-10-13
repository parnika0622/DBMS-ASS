#!/usr/bin/env python3
"""
Sports Club Membership & Tournament Management System
Application Launcher Script
"""
import os
import sys

# Ensure project root is in sys.path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BASE_DIR)

from app.app import app

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    print("=" * 70)
    print("  SPORTS CLUB MEMBERSHIP & TOURNAMENT MANAGEMENT SYSTEM")
    print("  Relational Database Management System (3NF Normalized)")
    print(f"  Starting web application server on: http://127.0.0.1:{port}")
    print("  Press Ctrl+C to terminate.")
    print("=" * 70)
    app.run(host="127.0.0.1", port=port, debug=True)
