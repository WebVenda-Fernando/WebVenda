---
inclusion: always
---

# GitHub Integration Guidelines

## Configuração Automática
O Kiro está configurado para integração automática com GitHub. Siga estas diretrizes:

### Comandos Disponíveis
- `.\github-kiro.ps1 setup` - Configurar nova conta GitHub
- `.\github-kiro.ps1 sync` - Sincronizar manualmente
- `.\github-kiro.ps1 status` - Verificar status do repositório
- `.\github-kiro.ps1 config` - Ver configuração atual
- `.\github-kiro.ps1 switch` - Trocar conta GitHub

### Estrutura de Commits
- **feat**: Nova funcionalidade
- **fix**: Correção de bug
- **docs**: Documentação
- **style**: Formatação
- **refactor**: Refatoração
- **test**: Testes
- **chore**: Manutenção

### Automação
- Sincronização automática ao salvar arquivos
- Commits automáticos com timestamps
- Criação automática de repositórios
- Atualização automática do README

### Configuração de Conta
Para configurar uma nova conta GitHub:

1. Gere um Personal Access Token no GitHub
2. Execute o script de configuração
3. Configure as credenciais
4. Ative a sincronização automática

### Arquivos Ignorados
- node_modules/
- .env files
- Logs
- Cache do Kiro
- Arquivos temporários