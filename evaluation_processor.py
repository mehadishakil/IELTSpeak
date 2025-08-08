#!/usr/bin/env python3
"""
IELTS Test Session Evaluation Processor

This script processes queued test sessions and simulates the Azure Speech Assessment API
integration for IELTS Speaking test evaluation.

Requirements:
- Python 3.7+
- supabase-py: pip install supabase
- python-dotenv: pip install python-dotenv

Setup:
1. Create a .env file with:
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_anon_key
   
2. Run: python evaluation_processor.py
"""

import os
import time
import json
import random
from datetime import datetime
from typing import Dict, List, Optional
from supabase import create_client, Client

# Configuration
SUPABASE_URL = "https://roovqypkzhynhrzzafre.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvb3ZxeXBremh5bmhyenphZnJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMTI4MzYsImV4cCI6MjA2Nzg4ODgzNn0.oumA-RA16a7wvevLwF3RQB43tqQxnuGgI1NuiAoh5-w"

def create_supabase_client() -> Client:
    """Create and return Supabase client."""
    return create_client(SUPABASE_URL, SUPABASE_KEY)

def get_queued_sessions(supabase: Client) -> List[Dict]:
    """Get sessions queued for processing."""
    try:
        result = supabase.table("session_processing_queue").select("*").eq("status", "queued").order("queued_at").execute()
        return result.data
    except Exception as e:
        print(f"❌ Error getting queued sessions: {e}")
        return []

def get_session_responses(supabase: Client, session_id: str) -> List[Dict]:
    """Get all responses for a session."""
    try:
        result = supabase.table("responses").select("*").eq("test_session_id", session_id).order("processing_order").execute()
        return result.data
    except Exception as e:
        print(f"❌ Error getting session responses: {e}")
        return []

def simulate_azure_evaluation(response_data: Dict) -> Dict:
    """Simulate Azure Speech Assessment API evaluation."""
    # Simulate processing time
    time.sleep(random.uniform(1, 3))
    
    # Generate realistic IELTS scores (0.5-9.0 scale)
    base_score = random.uniform(5.0, 8.5)
    variation = 0.5
    
    scores = {
        "fluency_score": round(max(0.5, min(9.0, base_score + random.uniform(-variation, variation))), 1),
        "pronunciation_score": round(max(0.5, min(9.0, base_score + random.uniform(-variation, variation))), 1),
        "grammar_score": round(max(0.5, min(9.0, base_score + random.uniform(-variation, variation))), 1),
        "vocabulary_score": round(max(0.5, min(9.0, base_score + random.uniform(-variation, variation))), 1),
        "topic_relevance_score": round(max(0.5, min(9.0, base_score + random.uniform(-variation/2, variation/2))), 1),
    }
    
    # Generate mock transcript
    sample_transcripts = [
        "I think this is a very interesting topic and I would like to share my experience about it.",
        "Well, in my opinion, there are several factors that we need to consider when discussing this subject.",
        "From my perspective, this is something that affects many people in our society today.",
        "I believe that we should look at both the advantages and disadvantages of this situation.",
    ]
    
    return {
        **scores,
        "transcript": random.choice(sample_transcripts),
        "duration_seconds": response_data.get("duration_seconds", random.randint(30, 120)),
        "azure_response": {
            "assessment_result": "completed",
            "confidence_score": random.uniform(0.7, 0.95),
            "words_analyzed": random.randint(20, 80),
            "processing_time_ms": random.randint(500, 2000)
        },
        "is_processed": True,
        "evaluated_at": datetime.now().isoformat(),
        "processing_status": "completed"
    }

def update_response_scores(supabase: Client, response_id: str, scores: Dict) -> bool:
    """Update response with evaluation scores."""
    try:
        result = supabase.table("responses").update(scores).eq("id", response_id).execute()
        return len(result.data) > 0
    except Exception as e:
        print(f"❌ Error updating response {response_id}: {e}")
        return False

def calculate_overall_scores(responses: List[Dict]) -> Dict:
    """Calculate overall session scores from individual responses."""
    if not responses:
        return {}
    
    score_fields = ["fluency_score", "pronunciation_score", "grammar_score", "vocabulary_score", "topic_relevance_score"]
    totals = {field: 0 for field in score_fields}
    counts = {field: 0 for field in score_fields}
    
    for response in responses:
        for field in score_fields:
            if response.get(field) is not None:
                totals[field] += float(response[field])
                counts[field] += 1
    
    averages = {}
    for field in score_fields:
        if counts[field] > 0:
            averages[field] = round(totals[field] / counts[field], 1)
        else:
            averages[field] = 0.0
    
    # Calculate overall band score as average of all criteria
    overall_scores = [score for score in averages.values() if score > 0]
    overall_band_score = round(sum(overall_scores) / len(overall_scores), 1) if overall_scores else 0.0
    
    return {
        **averages,
        "overall_band_score": overall_band_score
    }

def update_session_completion(supabase: Client, session_id: str, scores: Dict) -> bool:
    """Update session with final scores and mark as evaluated."""
    try:
        update_data = {
            **scores,
            "status": "evaluated",
            "completed_at": datetime.now().isoformat()
        }
        
        result = supabase.table("test_sessions").update(update_data).eq("id", session_id).execute()
        return len(result.data) > 0
    except Exception as e:
        print(f"❌ Error updating session {session_id}: {e}")
        return False

def mark_queue_completed(supabase: Client, queue_id: str) -> bool:
    """Mark queue item as completed."""
    try:
        result = supabase.table("session_processing_queue").update({
            "status": "completed",
            "completed_at": datetime.now().isoformat()
        }).eq("id", queue_id).execute()
        return len(result.data) > 0
    except Exception as e:
        print(f"❌ Error updating queue {queue_id}: {e}")
        return False

def mark_queue_failed(supabase: Client, queue_id: str, error_message: str) -> bool:
    """Mark queue item as failed."""
    try:
        result = supabase.table("session_processing_queue").update({
            "status": "failed",
            "error_message": error_message,
            "retry_count": supabase.table("session_processing_queue").select("retry_count").eq("id", queue_id).execute().data[0].get("retry_count", 0) + 1,
            "last_error_at": datetime.now().isoformat()
        }).eq("id", queue_id).execute()
        return len(result.data) > 0
    except Exception as e:
        print(f"❌ Error marking queue failed {queue_id}: {e}")
        return False

def process_session(supabase: Client, queue_item: Dict) -> bool:
    """Process a single test session."""
    session_id = queue_item["session_id"]
    queue_id = queue_item["id"]
    
    print(f"🔄 Processing session: {session_id}")
    
    try:
        # Get all responses for this session
        responses = get_session_responses(supabase, session_id)
        if not responses:
            print(f"⚠️  No responses found for session {session_id}")
            mark_queue_failed(supabase, queue_id, "No responses found")
            return False
        
        print(f"📄 Found {len(responses)} responses to evaluate")
        
        # Update queue status to processing
        supabase.table("session_processing_queue").update({
            "status": "processing",
            "started_processing_at": datetime.now().isoformat()
        }).eq("id", queue_id).execute()
        
        # Process each response
        processed_responses = []
        for i, response in enumerate(responses):
            print(f"  🔍 Evaluating response {i+1}/{len(responses)} (ID: {response['id']})")
            
            # Simulate Azure evaluation
            evaluation_scores = simulate_azure_evaluation(response)
            
            # Update response in database
            if update_response_scores(supabase, response["id"], evaluation_scores):
                processed_responses.append({**response, **evaluation_scores})
                print(f"    ✅ Updated scores for response {response['id']}")
            else:
                print(f"    ❌ Failed to update response {response['id']}")
        
        if len(processed_responses) != len(responses):
            raise Exception(f"Only processed {len(processed_responses)}/{len(responses)} responses")
        
        # Calculate overall session scores
        overall_scores = calculate_overall_scores(processed_responses)
        print(f"📊 Calculated overall scores: Band {overall_scores.get('overall_band_score', 0)}")
        
        # Update session with final scores
        if not update_session_completion(supabase, session_id, overall_scores):
            raise Exception("Failed to update session completion")
        
        # Mark queue item as completed
        if not mark_queue_completed(supabase, queue_id):
            raise Exception("Failed to mark queue as completed")
        
        print(f"✅ Successfully processed session {session_id}")
        return True
        
    except Exception as e:
        print(f"❌ Failed to process session {session_id}: {e}")
        mark_queue_failed(supabase, queue_id, str(e))
        return False

def main():
    """Main evaluation processor loop."""
    print("🚀 IELTS Test Session Evaluation Processor Starting...")
    print(f"📡 Connecting to Supabase: {SUPABASE_URL}")
    
    supabase = create_supabase_client()
    
    # Test connection
    try:
        result = supabase.table("session_processing_queue").select("count", count="exact").execute()
        print(f"✅ Connected to Supabase successfully")
    except Exception as e:
        print(f"❌ Failed to connect to Supabase: {e}")
        return
    
    print("\n⏳ Starting processing loop (Ctrl+C to stop)...")
    
    processed_count = 0
    
    try:
        while True:
            # Get queued sessions
            queued_sessions = get_queued_sessions(supabase)
            
            if not queued_sessions:
                print("📭 No queued sessions found. Waiting 10 seconds...")
                time.sleep(10)
                continue
            
            print(f"\n📨 Found {len(queued_sessions)} queued session(s)")
            
            # Process each session
            for queue_item in queued_sessions:
                success = process_session(supabase, queue_item)
                if success:
                    processed_count += 1
                    print(f"📈 Total sessions processed: {processed_count}")
                
                # Brief pause between sessions
                time.sleep(2)
            
            print(f"\n⏱️  Completed batch. Waiting 30 seconds before checking for more...")
            time.sleep(30)
            
    except KeyboardInterrupt:
        print(f"\n⏹️  Evaluation processor stopped. Total sessions processed: {processed_count}")

if __name__ == "__main__":
    main()