# Kiro IDE Workspace - Full Stack Development

Este workspace está configurado para desenvolvimento full-stack com integração completa do Supabase.

## 🚀 Funcionalidades Principais

### 🗄️ Supabase Integration
- **MCP Server**: Integração via chat/IA para operações rápidas
- **SDK Completo**: `@supabase/supabase-js` para funcionalidades avançadas
- **Auto-detecção**: Sistema inteligente que escolhe a ferramenta certa automaticamente

### 🤖 Comandos de IA Disponíveis
```
✅ "listar tabelas do supabase"
✅ "mostrar usuário atual"  
✅ "buscar dados da tabela products"
✅ "fazer login com email user@example.com"
✅ "escutar mudanças na tabela posts em tempo real"
✅ "inserir novo usuário na tabela users"
✅ "testar conexão com supabase"
✅ "status do supabase"
```

## 📁 Estrutura do Projeto

```
lib/
├── supabase.ts           # Cliente base do Supabase
├── supabase-auth.ts      # Autenticação completa
├── supabase-realtime.ts  # Real-time e subscriptions
├── supabase-database.ts  # Operações avançadas de banco
├── kiro-supabase-auto.ts # Sistema de auto-detecção
└── kiro-integration.ts   # Integração com Kiro IDE

examples/
└── supabase-usage.ts     # Exemplos práticos de uso

.kiro/settings/
└── mcp.json             # Configuração MCP servers
```

## 🔧 Configuração

### Variáveis de Ambiente (.env)
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### MCP Servers Configurados
- **Supabase**: Operações de banco via IA
- **SQLite**: Banco local para desenvolvimento
- **Git**: Controle de versão
- **Fetch**: Requisições HTTP
- **Context7**: Documentação inteligente

## 🎯 Como Usar

### Via Chat/IA (MCP)
Simplesmente fale com o Kiro em linguagem natural:
- "Crie uma tabela de usuários"
- "Busque todos os produtos ativos"
- "Faça login do usuário admin"

### Via Código (SDK)
```typescript
import { authService } from './lib/supabase-auth'
import { realtimeService } from './lib/supabase-realtime'

// Autenticação
await authService.signIn('user@example.com', 'password')

// Real-time
realtimeService.subscribeToTable('posts', (payload) => {
  console.log('Nova mudança:', payload)
})
```

## 📚 Documentação Completa

- **[SUPABASE-SETUP.md](./SUPABASE-SETUP.md)** - Guia completo do Supabase
- **[examples/](./examples/)** - Exemplos práticos
- **[lib/](./lib/)** - Bibliotecas e utilitários

## 🛠️ Tecnologias Configuradas

### Frontend
- **Angular** - Framework principal
- **TailwindCSS** - Estilização
- **TypeScript** - Linguagem

### Backend & Database
- **Supabase** - Backend as a Service
- **PostgreSQL** - Banco de dados
- **Prisma** - ORM alternativo

### Ferramentas de Desenvolvimento
- **Kiro IDE** - IDE com IA integrada
- **Git** - Controle de versão
- **Node.js** - Runtime JavaScript

## 🚀 Início Rápido

1. **Clone o repositório**
2. **Configure as variáveis de ambiente** no `.env`
3. **Instale dependências**: `npm install`
4. **Inicie o desenvolvimento**: `npm start`
5. **Use comandos de IA** para interagir com o Supabase

## 🤝 Integração GitHub

O projeto está configurado com sincronização automática:
- Commits automáticos com timestamps
- Sincronização ao salvar arquivos
- Scripts PowerShell para gerenciamento

## 📞 Suporte

Para dúvidas sobre:
- **Supabase**: Consulte `SUPABASE-SETUP.md`
- **Kiro IDE**: Use os comandos de IA integrados
- **Desenvolvimento**: Veja os exemplos em `examples/`

---

**Sistema 100% operacional e pronto para desenvolvimento full-stack! 🎉**