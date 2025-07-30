# Supabase SDK - Configuração Completa

## 📦 Instalação Concluída

✅ **SDK Instalado**: `@supabase/supabase-js@2.53.0`
✅ **MCP Configurado**: Servidor Smithery conectado
✅ **Arquivos Criados**: Bibliotecas para auth, real-time e database

## 🗂️ Estrutura dos Arquivos

```
lib/
├── supabase.ts           # Cliente base do Supabase
├── supabase-auth.ts      # Serviços de autenticação
├── supabase-realtime.ts  # Serviços de real-time
└── supabase-database.ts  # Operações avançadas de banco

examples/
└── supabase-usage.ts     # Exemplos de uso completos
```

## 🔐 Funcionalidades de Autenticação

```typescript
import { authService } from './lib/supabase-auth'

// Registrar usuário
await authService.signUp('email@example.com', 'password', { name: 'João' })

// Login
await authService.signIn('email@example.com', 'password')

// Logout
await authService.signOut()

// Usuário atual
const { user } = await authService.getCurrentUser()

// Escutar mudanças de auth
authService.onAuthStateChange((event, session) => {
  console.log('Auth event:', event, session)
})
```

## ⚡ Real-time e Subscriptions

```typescript
import { realtimeService } from './lib/supabase-realtime'

// Escutar mudanças em tabela
const channel = realtimeService.subscribeToTable('posts', (payload) => {
  console.log('Mudança:', payload)
})

// Chat em tempo real
const chat = realtimeService.createBroadcastChannel('chat')
chat.send('message', { text: 'Olá!', user: 'João' })
chat.listen('message', (payload) => console.log('Nova mensagem:', payload))

// Usuários online (Presence)
const presence = realtimeService.createPresenceChannel('room', { 
  user: 'João', status: 'online' 
})
await presence.join()
```

## 🗄️ Operações Avançadas de Banco

```typescript
import { databaseService } from './lib/supabase-database'

// Paginação com filtros
const { data, pagination } = await databaseService.paginate(
  'posts', 
  1, // página
  10, // itens por página
  { status: 'published' }, // filtros
  { column: 'created_at', ascending: false } // ordenação
)

// Busca full-text
const { data } = await databaseService.fullTextSearch(
  'posts', 
  'title', 
  'javascript tutorial'
)

// Upload de arquivos
await databaseService.uploadFile('bucket', 'path/file.jpg', file)
const url = databaseService.getPublicUrl('bucket', 'path/file.jpg')
```

## 🎯 Quando Usar Cada Abordagem

### MCP (via Chat/IA)
- ✅ Consultas rápidas via comandos de voz
- ✅ Operações CRUD simples
- ✅ Exploração de dados
- ✅ Prototipagem rápida

### SDK (no Código)
- ✅ Autenticação completa
- ✅ Real-time/WebSockets
- ✅ Upload de arquivos
- ✅ Transações complexas
- ✅ Aplicações em produção

## 🚀 Exemplo de Uso Completo

```typescript
import { initializeSupabase } from './examples/supabase-usage'

// Inicializar todos os serviços
const { cleanup } = await initializeSupabase()

// Usar em componentes Angular
export class AppComponent {
  constructor() {
    this.setupSupabase()
  }

  async setupSupabase() {
    // Auth
    const { user } = await authService.getCurrentUser()
    if (user) {
      console.log('Usuário logado:', user)
    }

    // Real-time
    realtimeService.subscribeToTable('notifications', (payload) => {
      this.showNotification(payload.new)
    })
  }
}
```

## 🔧 Configuração de Ambiente

As variáveis já estão configuradas no `.env`:
```env
SUPABASE_URL=https://kokhvaowaasdnyxmqykm.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 📝 Próximos Passos

1. **Teste o MCP**: "Liste as tabelas do Supabase"
2. **Use o SDK**: Importe os serviços nos seus componentes
3. **Configure Auth**: Implemente login/registro
4. **Adicione Real-time**: Configure subscriptions
5. **Upload de Arquivos**: Configure buckets no Supabase

## 🆘 Troubleshooting

- **MCP não conecta**: Verifique os logs do Kiro
- **Auth não funciona**: Verifique as configurações de Auth no Supabase Dashboard
- **Real-time não funciona**: Ative Real-time no Supabase Dashboard
- **Upload falha**: Configure buckets e políticas RLS

Agora você tem acesso completo ao Supabase via MCP (para IA) e SDK (para código)! 🎉