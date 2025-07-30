import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env['SUPABASE_URL'] || 'https://kokhvaowaasdnyxmqykm.supabase.co'
const supabaseAnonKey = process.env['SUPABASE_ANON_KEY'] || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtva2h2YW93YWFzZG55eG1xeWttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2MjIwMDcsImV4cCI6MjA2OTE5ODAwN30.wiCtdUwxeW5HI6EipkpDpFPHsUnqcfcf8aU4If0NtMo'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Tipos para TypeScript
export type Database = {
  public: {
    Tables: {
      [key: string]: {
        Row: Record<string, any>
        Insert: Record<string, any>
        Update: Record<string, any>
      }
    }
  }
}