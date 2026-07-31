/* ==========================================================================
   SISTEMA DE SOPORTE OFFLINE E INDEXEDDB - QFUTBOL
   ========================================================================== */

const OFFLINE_QUEUE_KEY = "qfutbol_offline_partidos_queue";

/**
 * Guarda un acta de partido localmente en la cola offline
 * @param {String} partidoId - ID del partido
 * @param {Object} datosPartido - Datos consolidados del partido y estadísticas
 */
function guardarPartidoOffline(partidoId, datosPartido) {
    let queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY)) || [];
    
    // Si ya existe el partido en la cola, lo actualizamos
    const index = queue.findIndex(item => item.id === partidoId);
    const itemQueue = {
        id: partidoId,
        datos: datosPartido,
        timestamp: Date.now()
    };
    
    if (index !== -1) {
        queue[index] = itemQueue;
    } else {
        queue.push(itemQueue);
    }
    
    localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
    console.log(`Partido ${partidoId} guardado localmente en la cola offline.`);
}

/**
 * Retorna los partidos pendientes de sincronizar en la cola offline
 * @returns {Array} Lista de partidos en la cola
 */
function obtenerColaOffline() {
    return JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY)) || [];
}

/**
 * Elimina un partido de la cola offline tras una sincronización exitosa
 * @param {String} partidoId - ID del partido
 */
function eliminarDeColaOffline(partidoId) {
    let queue = JSON.parse(localStorage.getItem(OFFLINE_QUEUE_KEY)) || [];
    queue = queue.filter(item => item.id !== partidoId);
    localStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
    console.log(`Partido ${partidoId} removido de la cola offline.`);
}

/**
 * Intenta sincronizar todos los partidos pendientes de la cola con Supabase
 * @returns {Promise<Boolean>} True si se sincronizó todo con éxito, False de lo contrario
 */
async function sincronizarColaOffline() {
    const queue = obtenerColaOffline();
    if (queue.length === 0) return true;
    
    if (!supabase) {
        console.log("No hay conexión con Supabase. Permaneciendo en modo offline.");
        return false;
    }
    
    console.log(`Iniciando sincronización de ${queue.length} partidos pendientes...`);
    let exitoSincro = true;
    
    for (const item of queue) {
        try {
            const { id, datos } = item;
            
            // 1. Actualizar cabecera del partido (goles, firmas, estado finalizado)
            const { error: errorPartido } = await supabase
                .from('partidos')
                .update({
                    goles_local: datos.goles_local,
                    goles_visitante: datos.goles_visitante,
                    firma_local: datos.firma_local,
                    firma_visitante: datos.firma_visitante,
                    arbitro_nombre: datos.arbitro_nombre,
                    estado: datos.estado
                })
                .eq('id', id);
                
            if (errorPartido) throw errorPartido;
            
            // 2. Eliminar estadísticas previas y penales de este partido para evitar duplicados
            const { error: errorDeleteStats } = await supabase
                .from('detalles_partido')
                .delete()
                .eq('partido_id', id);
                
            if (errorDeleteStats) throw errorDeleteStats;

            // Eliminar penales previos
            const { error: errorDeletePenales } = await supabase
                .from('detalles_penales')
                .delete()
                .eq('partido_id', id);

            if (errorDeletePenales) throw errorDeletePenales;
            
            // 3. Insertar los nuevos rendimientos de los jugadores
            if (datos.detalles && datos.detalles.length > 0) {
                const { error: errorStats } = await supabase
                    .from('detalles_partido')
                    .insert(datos.detalles);
                    
                if (errorStats) throw errorStats;
            }

            // 4. Insertar cobros de penales
            if (datos.penales && datos.penales.length > 0) {
                const { error: errorPenales } = await supabase
                    .from('detalles_penales')
                    .insert(datos.penales);

                if (errorPenales) throw errorPenales;
            }
            
            // Si todo salió bien con este partido, lo removemos de la cola
            eliminarDeColaOffline(id);
            
        } catch (error) {
            console.error(`Fallo la sincronización del partido ${item.id}:`, error);
            exitoSincro = false;
        }
    }
    
    return exitoSincro;
}

// Escuchar cambios de conectividad de red para sincronizar automáticamente
window.addEventListener('online', async () => {
    console.log("Conectividad a internet restablecida. Iniciando sincronización...");
    const resultado = await sincronizarColaOffline();
    if (resultado) {
        // Disparar evento global por si alguna pantalla necesita refrescar
        window.dispatchEvent(new Event('offline_sync_completed'));
    }
});
