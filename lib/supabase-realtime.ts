import { supabase } from './supabase'

// Serviços de Real-time
export const realtimeService = {
  // Escutar mudanças em uma tabela específica
  subscribeToTable(
    tableName: string, 
    callback: (payload: any) => void,
    filter?: { column: string; value: any }
  ) {
    let channel = supabase
      .channel(`${tableName}-changes`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: tableName,
          ...(filter && { filter: `${filter.column}=eq.${filter.value}` })
        },
        callback
      )
      .subscribe()

    return channel
  },

  // Escutar apenas inserções
  subscribeToInserts(tableName: string, callback: (payload: any) => void) {
    return supabase
      .channel(`${tableName}-inserts`)
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: tableName },
        callback
      )
      .subscribe()
  },

  // Escutar apenas atualizações
  subscribeToUpdates(tableName: string, callback: (payload: any) => void) {
    return supabase
      .channel(`${tableName}-updates`)
      .on(
        'postgres_changes',
        { event: 'UPDATE', schema: 'public', table: tableName },
        callback
      )
      .subscribe()
  },

  // Escutar apenas exclusões
  subscribeToDeletes(tableName: string, callback: (payload: any) => void) {
    return supabase
      .channel(`${tableName}-deletes`)
      .on(
        'postgres_changes',
        { event: 'DELETE', schema: 'public', table: tableName },
        callback
      )
      .subscribe()
  },

  // Broadcast personalizado (para comunicação entre clientes)
  createBroadcastChannel(channelName: string) {
    return {
      channel: supabase.channel(channelName),
      
      // Enviar mensagem
      send(event: string, payload: any) {
        return supabase.channel(channelName).send({
          type: 'broadcast',
          event,
          payload
        })
      },

      // Escutar mensagens
      listen(event: string, callback: (payload: any) => void) {
        return supabase
          .channel(channelName)
          .on('broadcast', { event }, callback)
          .subscribe()
      }
    }
  },

  // Presence (usuários online)
  createPresenceChannel(channelName: string, userInfo: Record<string, any>) {
    const channel = supabase.channel(channelName)

    return {
      // Entrar no canal
      async join() {
        return channel
          .on('presence', { event: 'sync' }, () => {
            console.log('Synced presence state:', channel.presenceState())
          })
          .on('presence', { event: 'join' }, ({ newPresences }) => {
            console.log('New users joined:', newPresences)
          })
          .on('presence', { event: 'leave' }, ({ leftPresences }) => {
            console.log('Users left:', leftPresences)
          })
          .subscribe(async (status) => {
            if (status === 'SUBSCRIBED') {
              await channel.track(userInfo)
            }
          })
      },

      // Sair do canal
      async leave() {
        return channel.untrack()
      },

      // Obter usuários online
      getOnlineUsers() {
        return channel.presenceState()
      }
    }
  },

  // Cancelar subscription
  unsubscribe(channel: any) {
    return supabase.removeChannel(channel)
  }
}