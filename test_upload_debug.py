#!/usr/bin/env python3
"""
Debug script to check current state of test sessions and responses.
This helps identify issues with the upload process.
"""

from supabase import create_client

# Configuration
SUPABASE_URL = "https://roovqypkzhynhrzzafre.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvb3ZxeXBremh5bmhyenphZnJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMTI4MzYsImV4cCI6MjA2Nzg4ODgzNn0.oumA-RA16a7wvevLwF3RQB43tqQxnuGgI1NuiAoh5-w"

def main():
    """Debug current database state."""
    print("🔍 IELTS Upload Debug Tool")
    print("=" * 50)
    
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Check test_sessions
    print("\n📋 TEST SESSIONS:")
    print("-" * 30)
    try:
        sessions = supabase.table("test_sessions").select("*").order("started_at", desc=True).limit(10).execute()
        if sessions.data:
            for session in sessions.data:
                print(f"ID: {session['id'][:8]}...")
                print(f"  Status: {session['status']}")
                print(f"  User: {session['user_id'][:8]}...")
                print(f"  Started: {session.get('started_at', 'N/A')}")
                print(f"  Completed: {session.get('completed_at', 'N/A')}")
                print(f"  Response Count: {session.get('completed_responses', 'N/A')}")
                print(f"  All Uploaded: {session.get('all_responses_uploaded', 'N/A')}")
                print()
        else:
            print("  No test sessions found")
    except Exception as e:
        print(f"  ❌ Error: {e}")
    
    # Check responses
    print("\n🎙️ RESPONSES:")
    print("-" * 30)
    try:
        responses = supabase.table("responses").select("*").order("created_at", desc=True).limit(10).execute()
        if responses.data:
            for response in responses.data:
                print(f"ID: {response['id'][:8]}...")
                print(f"  Session: {response['test_session_id'][:8]}...")
                print(f"  Question: {response['question_id'][:8]}...")
                print(f"  Audio Path: {response.get('audio_file_path', 'N/A')}")
                print(f"  Created: {response.get('created_at', 'N/A')}")
                print(f"  Processed: {response.get('is_processed', 'N/A')}")
                print()
        else:
            print("  No responses found")
    except Exception as e:
        print(f"  ❌ Error: {e}")
    
    # Check processing queue
    print("\n⏳ PROCESSING QUEUE:")
    print("-" * 30)
    try:
        queue = supabase.table("session_processing_queue").select("*").order("queued_at", desc=True).limit(5).execute()
        if queue.data:
            for item in queue.data:
                print(f"ID: {item['id'][:8]}...")
                print(f"  Session: {item['session_id'][:8]}...")
                print(f"  Status: {item['status']}")
                print(f"  Queued: {item.get('queued_at', 'N/A')}")
                print()
        else:
            print("  No queued items found")
    except Exception as e:
        print(f"  ❌ Error: {e}")
    
    # Check storage buckets
    print("\n📦 STORAGE BUCKETS:")
    print("-" * 30)
    try:
        buckets = supabase.storage.list_buckets()
        for bucket in buckets:
            print(f"  📁 {bucket.name} ({'Public' if bucket.public else 'Private'})")
    except Exception as e:
        print(f"  ❌ Error: {e}")
    
    # Check audio files in responses bucket
    print("\n🎵 AUDIO FILES (responses bucket):")
    print("-" * 30)
    try:
        files = supabase.storage.from_("audio-responses").list("responses/")
        if files:
            for file in files[:10]:  # Show first 10 files
                print(f"  📄 {file['name']} ({file['metadata'].get('size', 'Unknown size')} bytes)")
        else:
            print("  No audio files found in responses folder")
    except Exception as e:
        print(f"  ❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("Debug complete! Check the data above to identify issues.")

if __name__ == "__main__":
    main()