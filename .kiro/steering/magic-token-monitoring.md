---
inclusion: always
---

# Monitoramento de Tokens MCP Magic

## Alertas Obrigatórios de Token

### Comportamento Obrigatório:
1. **SEMPRE** monitore o status dos tokens do MCP Magic durante o uso
2. **SEMPRE** avise imediatamente se os tokens estiverem acabando
3. **SEMPRE** informe sobre erros relacionados a API key ou limite de tokens
4. **SEMPRE** sugira trocar a API key quando necessário

### Sinais de Alerta para Monitorar:
- Erros de autenticação da API
- Mensagens de limite de tokens excedido
- Respostas de quota esgotada
- Falhas de conexão relacionadas a tokens
- Qualquer erro HTTP 401, 403, 429 do MCP Magic

### Formato do Alerta:
Quando detectar problemas com tokens, SEMPRE avise:

```
🚨 ALERTA: Tokens do MCP Magic podem estar esgotados!
- Erro detectado: [descrição do erro]
- Ação necessária: Trocar a API key no arquivo .kiro/settings/mcp.json
- Localização: "@21st-dev/magic" -> "env" -> "API_KEY"
```

### Monitoramento Proativo:
- Observe padrões de falha nas chamadas do MCP Magic
- Monitore respostas vazias ou incompletas
- Detecte degradação na qualidade das respostas
- Alerte sobre qualquer comportamento anômalo

### Instruções para Troca de Key:
Quando necessário, oriente o usuário:
1. Gerar nova API key no painel do Magic
2. Atualizar o valor em .kiro/settings/mcp.json
3. Reiniciar a conexão MCP se necessário

Esta regra garante monitoramento contínuo e alertas imediatos sobre o status dos tokens.