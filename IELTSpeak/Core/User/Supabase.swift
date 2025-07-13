import Supabase
import Foundation

let supabaseURL = URL(string: "https://roovqypkzhynhrzzafre.supabase.co")!
let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvb3ZxeXBremh5bmhyenphZnJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMTI4MzYsImV4cCI6MjA2Nzg4ODgzNn0.oumA-RA16a7wvevLwF3RQB43tqQxnuGgI1NuiAoh5-w"

let supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseAnonKey)

