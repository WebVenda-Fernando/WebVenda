import { authService } from '../lib/supabase-auth'
import { realtimeService } from '../lib/supabase-realtime'
import { databaseService } from '../lib/supabase-database'
import { supabase } from '../lib/supabase'

// Exemplos de uso do Supabase SDK

export class SupabaseExamples {
  
  // Exemplo de autenticação completa
  async authExample() {
    try {
      // Registrar usuário
      const { data: signUpData, error: signUpError } = await authService.signUp(
        'user@example.com',
        'password123',
        { name: 'João Silva', role: 'user' }
      )

      if (signUpError) throw signUpError
      console.log('Usuário registrado:', signUpData)

      // Login
      const { data: signInData, error: signInError } = await authService.signIn(
        'user@example.com',
        'password123'
      )

      if (signInError) throw signInError
      console.log('Login realizado:', signInData)

      // Obter usuário atual
      const { user, error: userError } = await authService.getCurrentUser()
      if (userError) throw userError
      console.log('Usuário atual:', user)

    } catch (error) {
      console.error('Erro na autenticação:', error)
    }
  }

  // Exemplo de real-time
  setupRealtime() {
    // Escutar mudanças na tabela 'posts'
    const postsChannel = realtimeService.subscribeToTable(
      'posts',
      (payload) => {
        console.log('Mudança na tabela posts:', payload)
        // Atualizar UI aqui
      }
    )

    // Escutar apenas inserções de comentários
    const commentsChannel = realtimeService.subscribeToInserts(
      'comments',
      (payload) => {
        console.log('Novo comentário:', payload.new)
        // Adicionar comentário na UI
      }
    )

    // Canal de broadcast para chat
    const chatChannel = realtimeService.createBroadcastChannel('chat-room')
    
    // Enviar mensagem
    chatChannel.send('message', {
      user: 'João',
      text: 'Olá pessoal!',
      timestamp: new Date().toISOString()
    })

    // Escutar mensagens
    chatChannel.listen('message', (payload) => {
      console.log('Nova mensagem no chat:', payload)
    })

    // Presence - usuários online
    const presenceChannel = realtimeService.createPresenceChannel('online-users', {
      user_id: '123',
      name: 'João Silva',
      status: 'online'
    })

    presenceChannel.join()

    return {
      cleanup: () => {
        realtimeService.unsubscribe(postsChannel)
        realtimeService.unsubscribe(commentsChannel)
        presenceChannel.leave()
      }
    }
  }

  // Exemplo de operações avançadas de banco
  async databaseExample() {
    try {
      // Paginação com filtros
      const { data: posts, pagination } = await databaseService.paginate(
        'posts',
        1, // página
        10, // itens por página
        { status: 'published', author_id: 123 }, // filtros
        { column: 'created_at', ascending: false } // ordenação
      )

      console.log('Posts paginados:', posts)
      console.log('Info da paginação:', pagination)

      // Busca full-text
      const { data: searchResults } = await databaseService.fullTextSearch(
        'posts',
        'title',
        'javascript tutorial'
      )

      console.log('Resultados da busca:', searchResults)

      // Operações CRUD básicas
      const { data: newPost, error: insertError } = await supabase
        .from('posts')
        .insert({
          title: 'Meu novo post',
          content: 'Conteúdo do post...',
          author_id: 123
        })
        .select()

      if (insertError) throw insertError
      console.log('Post criado:', newPost)

      // Update com condições
      const { data: updatedPost, error: updateError } = await supabase
        .from('posts')
        .update({ status: 'published' })
        .eq('id', newPost[0].id)
        .select()

      if (updateError) throw updateError
      console.log('Post atualizado:', updatedPost)

      // Query complexa com join
      const { data: postsWithAuthors, error: joinError } = await supabase
        .from('posts')
        .select(`
          *,
          author:profiles(name, avatar_url),
          comments(count)
        `)
        .eq('status', 'published')

      if (joinError) throw joinError
      console.log('Posts com autores:', postsWithAuthors)

    } catch (error) {
      console.error('Erro nas operações de banco:', error)
    }
  }

  // Exemplo de upload de arquivos
  async fileUploadExample(file: File) {
    try {
      const fileName = `uploads/${Date.now()}-${file.name}`
      
      // Upload do arquivo
      const { data: uploadData, error: uploadError } = await databaseService.uploadFile(
        'public-files',
        fileName,
        file
      )

      if (uploadError) throw uploadError
      console.log('Arquivo enviado:', uploadData)

      // Obter URL pública
      const publicUrl = databaseService.getPublicUrl('public-files', fileName)
      console.log('URL pública:', publicUrl)

      // Salvar referência no banco
      const { data: fileRecord, error: dbError } = await supabase
        .from('files')
        .insert({
          name: file.name,
          path: fileName,
          url: publicUrl,
          size: file.size,
          type: file.type
        })
        .select()

      if (dbError) throw dbError
      console.log('Registro do arquivo salvo:', fileRecord)

      return { uploadData, publicUrl, fileRecord }

    } catch (error) {
      console.error('Erro no upload:', error)
      throw error
    }
  }

  // Exemplo de escutar mudanças de autenticação
  setupAuthListener() {
    const { data: { subscription } } = authService.onAuthStateChange((event, session) => {
      console.log('Evento de auth:', event)
      
      switch (event) {
        case 'SIGNED_IN':
          console.log('Usuário logado:', session?.user)
          // Redirecionar para dashboard
          break
        case 'SIGNED_OUT':
          console.log('Usuário deslogado')
          // Redirecionar para login
          break
        case 'TOKEN_REFRESHED':
          console.log('Token renovado')
          break
      }
    })

    return subscription
  }
}

// Uso das funcionalidades
export async function initializeSupabase() {
  const examples = new SupabaseExamples()
  
  // Configurar listeners de auth
  const authSubscription = examples.setupAuthListener()
  
  // Configurar real-time
  const { cleanup: cleanupRealtime } = examples.setupRealtime()
  
  // Função de limpeza
  return {
    cleanup: () => {
      authSubscription?.unsubscribe()
      cleanupRealtime()
    }
  }
}