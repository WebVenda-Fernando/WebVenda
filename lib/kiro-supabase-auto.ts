import { supabase } from './supabase'
import { authService } from './supabase-auth'
import { realtimeService } from './supabase-realtime'
import { databaseService } from './supabase-database'

/**
 * Sistema de auto-detecção do Kiro para Supabase
 * Detecta automaticamente qual funcionalidade usar baseado no contexto
 */
export class KiroSupabaseAuto {
  
  // Detectar tipo de operação baseado em palavras-chave
  static detectOperation(input: string): 'auth' | 'realtime' | 'database' | 'storage' | 'unknown' {
    const lowerInput = input.toLowerCase()
    
    // Palavras-chave para autenticação
    const authKeywords = ['login', 'logout', 'registrar', 'auth', 'usuario', 'senha', 'token', 'sessao']
    if (authKeywords.some(keyword => lowerInput.includes(keyword))) {
      return 'auth'
    }
    
    // Palavras-chave para real-time
    const realtimeKeywords = ['tempo real', 'realtime', 'subscription', 'escutar', 'broadcast', 'online', 'presence']
    if (realtimeKeywords.some(keyword => lowerInput.includes(keyword))) {
      return 'realtime'
    }
    
    // Palavras-chave para storage
    const storageKeywords = ['upload', 'arquivo', 'imagem', 'download', 'bucket', 'storage']
    if (storageKeywords.some(keyword => lowerInput.includes(keyword))) {
      return 'storage'
    }
    
    // Palavras-chave para database (padrão)
    const dbKeywords = ['tabela', 'consulta', 'select', 'insert', 'update', 'delete', 'dados', 'buscar']
    if (dbKeywords.some(keyword => lowerInput.includes(keyword))) {
      return 'database'
    }
    
    return 'database' // Padrão para operações de banco
  }
  
  // Executar operação automaticamente
  static async executeAuto(input: string, context?: any) {
    const operation = this.detectOperation(input)
    
    console.log(`🤖 Kiro detectou operação: ${operation}`)
    
    switch (operation) {
      case 'auth':
        return await this.handleAuth(input, context)
      case 'realtime':
        return await this.handleRealtime(input, context)
      case 'database':
        return await this.handleDatabase(input, context)
      case 'storage':
        return await this.handleStorage(input, context)
      default:
        return await this.handleDatabase(input, context) // Fallback
    }
  }
  
  // Handler para autenticação
  static async handleAuth(input: string, context?: any) {
    const lowerInput = input.toLowerCase()
    
    if (lowerInput.includes('login') || lowerInput.includes('entrar')) {
      if (context?.email && context?.password) {
        return await authService.signIn(context.email, context.password)
      } else {
        return { 
          action: 'login_required',
          message: 'Para fazer login, forneça email e senha',
          example: 'login com email: user@example.com e senha: minhasenha'
        }
      }
    }
    
    if (lowerInput.includes('registrar') || lowerInput.includes('cadastrar')) {
      if (context?.email && context?.password) {
        return await authService.signUp(context.email, context.password, context?.metadata)
      } else {
        return {
          action: 'signup_required',
          message: 'Para registrar, forneça email e senha',
          example: 'registrar usuário com email: user@example.com e senha: minhasenha'
        }
      }
    }
    
    if (lowerInput.includes('logout') || lowerInput.includes('sair')) {
      return await authService.signOut()
    }
    
    if (lowerInput.includes('usuario') || lowerInput.includes('perfil')) {
      return await authService.getCurrentUser()
    }
    
    return {
      action: 'auth_help',
      message: 'Operações de auth disponíveis: login, logout, registrar, ver usuário atual'
    }
  }
  
  // Handler para real-time
  static async handleRealtime(input: string, context?: any) {
    const lowerInput = input.toLowerCase()
    
    if (lowerInput.includes('escutar') || lowerInput.includes('subscription')) {
      const tableName = this.extractTableName(input) || context?.table || 'posts'
      
      const channel = realtimeService.subscribeToTable(tableName, (payload) => {
        console.log(`📡 Mudança em ${tableName}:`, payload)
      })
      
      return {
        action: 'subscription_created',
        message: `Escutando mudanças na tabela: ${tableName}`,
        channel
      }
    }
    
    if (lowerInput.includes('broadcast') || lowerInput.includes('enviar')) {
      const channelName = context?.channel || 'general'
      const message = context?.message || 'Mensagem de teste'
      
      const broadcastChannel = realtimeService.createBroadcastChannel(channelName)
      await broadcastChannel.send('message', { text: message, timestamp: new Date() })
      
      return {
        action: 'message_sent',
        message: `Mensagem enviada no canal: ${channelName}`
      }
    }
    
    return {
      action: 'realtime_help',
      message: 'Operações real-time: escutar tabela, enviar broadcast, presence'
    }
  }
  
  // Handler para database
  static async handleDatabase(input: string, context?: any) {
    const lowerInput = input.toLowerCase()
    
    // Listar tabelas
    if (lowerInput.includes('listar tabelas') || lowerInput.includes('mostrar tabelas')) {
      try {
        const { data, error } = await supabase
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public')
        
        return {
          action: 'list_tables',
          data: data || [],
          message: `Encontradas ${data?.length || 0} tabelas`
        }
      } catch (error) {
        return { action: 'error', message: 'Erro ao listar tabelas', error }
      }
    }
    
    // Consulta genérica
    if (lowerInput.includes('select') || lowerInput.includes('buscar') || lowerInput.includes('consultar')) {
      const tableName = this.extractTableName(input) || context?.table
      
      if (!tableName) {
        return {
          action: 'table_required',
          message: 'Especifique a tabela para consultar',
          example: 'buscar dados da tabela users'
        }
      }
      
      try {
        const { data, error } = await supabase
          .from(tableName)
          .select('*')
          .limit(10)
        
        return {
          action: 'query_result',
          data,
          message: `Consultando tabela: ${tableName}`,
          count: data?.length || 0
        }
      } catch (error) {
        return { action: 'error', message: `Erro ao consultar ${tableName}`, error }
      }
    }
    
    // Inserir dados
    if (lowerInput.includes('inserir') || lowerInput.includes('criar') || lowerInput.includes('adicionar')) {
      const tableName = this.extractTableName(input) || context?.table
      const data = context?.data
      
      if (!tableName || !data) {
        return {
          action: 'insert_required',
          message: 'Para inserir, especifique tabela e dados',
          example: 'inserir na tabela users os dados: {name: "João", email: "joao@email.com"}'
        }
      }
      
      try {
        const { data: result, error } = await supabase
          .from(tableName)
          .insert(data)
          .select()
        
        return {
          action: 'insert_success',
          data: result,
          message: `Dados inseridos na tabela: ${tableName}`
        }
      } catch (error) {
        return { action: 'error', message: `Erro ao inserir em ${tableName}`, error }
      }
    }
    
    return {
      action: 'database_help',
      message: 'Operações de banco: listar tabelas, consultar, inserir, atualizar, deletar'
    }
  }
  
  // Handler para storage
  static async handleStorage(input: string, context?: any) {
    const lowerInput = input.toLowerCase()
    
    if (lowerInput.includes('listar') && lowerInput.includes('bucket')) {
      const { data, error } = await supabase.storage.listBuckets()
      return {
        action: 'list_buckets',
        data,
        message: `Encontrados ${data?.length || 0} buckets`
      }
    }
    
    return {
      action: 'storage_help',
      message: 'Operações de storage: upload arquivo, listar buckets, download'
    }
  }
  
  // Extrair nome da tabela do input
  static extractTableName(input: string): string | null {
    const patterns = [
      /tabela\s+(\w+)/i,
      /table\s+(\w+)/i,
      /from\s+(\w+)/i,
      /into\s+(\w+)/i,
      /update\s+(\w+)/i
    ]
    
    for (const pattern of patterns) {
      const match = input.match(pattern)
      if (match) return match[1]
    }
    
    return null
  }
}

// Função principal para o Kiro usar
export async function processSupabaseRequest(input: string, context?: any) {
  console.log(`🤖 Kiro processando: "${input}"`)
  return await KiroSupabaseAuto.executeAuto(input, context)
}

// Exportar para uso global
if (typeof globalThis !== 'undefined') {
  (globalThis as any).processSupabaseRequest = processSupabaseRequest
}