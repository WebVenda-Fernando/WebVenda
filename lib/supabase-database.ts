import { supabase } from './supabase'

// Operações avançadas de banco de dados
export const databaseService = {
  // Consultas complexas com joins
  async complexQuery(query: string, params?: any[]) {
    const { data, error } = await supabase.rpc('execute_sql', {
      query,
      params: params || []
    })
    return { data, error }
  },

  // Transações (usando stored procedures)
  async transaction(operations: Array<{ table: string; operation: 'insert' | 'update' | 'delete'; data: any; where?: any }>) {
    const { data, error } = await supabase.rpc('execute_transaction', {
      operations
    })
    return { data, error }
  },

  // Busca com full-text search
  async fullTextSearch(table: string, column: string, searchTerm: string) {
    const { data, error } = await supabase
      .from(table)
      .select('*')
      .textSearch(column, searchTerm)
    return { data, error }
  },

  // Agregações
  async aggregate(table: string, aggregations: Record<string, string>) {
    let query = supabase.from(table).select()
    
    Object.entries(aggregations).forEach(([field, func]) => {
      query = query.select(`${func}(${field})`)
    })

    const { data, error } = await query
    return { data, error }
  },

  // Paginação avançada
  async paginate(
    table: string, 
    page: number = 1, 
    pageSize: number = 10,
    filters?: Record<string, any>,
    orderBy?: { column: string; ascending?: boolean }
  ) {
    const from = (page - 1) * pageSize
    const to = from + pageSize - 1

    let query = supabase
      .from(table)
      .select('*', { count: 'exact' })
      .range(from, to)

    // Aplicar filtros
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (Array.isArray(value)) {
          query = query.in(key, value)
        } else if (typeof value === 'string' && value.includes('%')) {
          query = query.like(key, value)
        } else {
          query = query.eq(key, value)
        }
      })
    }

    // Aplicar ordenação
    if (orderBy) {
      query = query.order(orderBy.column, { ascending: orderBy.ascending ?? true })
    }

    const { data, error, count } = await query
    
    return {
      data,
      error,
      pagination: {
        page,
        pageSize,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / pageSize)
      }
    }
  },

  // Upload de arquivos
  async uploadFile(bucket: string, path: string, file: File | Buffer) {
    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(path, file)
    return { data, error }
  },

  // Download de arquivos
  async downloadFile(bucket: string, path: string) {
    const { data, error } = await supabase.storage
      .from(bucket)
      .download(path)
    return { data, error }
  },

  // Obter URL pública de arquivo
  getPublicUrl(bucket: string, path: string) {
    const { data } = supabase.storage
      .from(bucket)
      .getPublicUrl(path)
    return data.publicUrl
  },

  // Listar arquivos
  async listFiles(bucket: string, folder?: string) {
    const { data, error } = await supabase.storage
      .from(bucket)
      .list(folder)
    return { data, error }
  }
}