/* ==========================================================================
   ALGORITMO DE GENERACIÓN DE FIXTURES Y LLAVES - QFUTBOL
   ========================================================================== */

/**
 * Genera el fixture de todos contra todos (Algoritmo Round Robin)
 * @param {Array} equipos - Lista de objetos de equipos {id, nombre}
 * @param {Boolean} idaYVuelta - Si es true, genera partidos de revancha
 * @returns {Array} Listado de partidos agrupados por jornada
 */
function generarRoundRobin(equipos, idaYVuelta = false) {
    let lista = [...equipos];
    
    // Si la cantidad de equipos es impar, agregamos un equipo comodín "DESCANSO"
    const esImpar = lista.length % 2 !== 0;
    if (esImpar) {
        lista.push({ id: "BYE", nombre: "DESCANSO" });
    }
    
    const numEquipos = lista.length;
    const numJornadas = numEquipos - 1;
    const partidosPorJornada = numEquipos / 2;
    let jornadas = [];
    
    for (let j = 0; j < numJornadas; j++) {
        let jornada = {
            numero: j + 1,
            partidos: []
        };
        
        for (let p = 0; p < partidosPorJornada; p++) {
            const localIdx = (j + p) % (numEquipos - 1);
            let visitanteIdx = (numEquipos - 1 - p + j) % (numEquipos - 1);
            
            // El primer equipo se queda fijo, el resto rota
            let local = p === 0 ? lista[numEquipos - 1] : lista[localIdx];
            let visitante = lista[visitanteIdx];
            
            // Alternar localía en cada jornada
            if (j % 2 === 1 && p === 0) {
                let temp = local;
                local = visitante;
                visitor = temp; // Corrección de variable temp
                visitante = temp;
            }
            
            // Omitir partidos contra el descanso
            if (local.id !== "BYE" && visitante.id !== "BYE") {
                jornada.partidos.push({
                    equipo_local: local,
                    equipo_visitante: visitante,
                    estado: 'programado',
                    goles_local: 0,
                    goles_visitante: 0
                });
            }
        }
        jornadas.push(jornada);
    }
    
    // Si se requiere ida y vuelta, duplicamos las jornadas invirtiendo la localía
    if (idaYVuelta) {
        const numJornadasIda = jornadas.length;
        for (let j = 0; j < numJornadasIda; j++) {
            let jornadaVuelta = {
                numero: numJornadasIda + j + 1,
                partidos: jornadas[j].partidos.map(p => ({
                    equipo_local: p.equipo_visitante,
                    equipo_visitante: p.equipo_local,
                    estado: 'programado',
                    goles_local: 0,
                    goles_visitante: 0
                }))
            };
            jornadas.push(jornadaVuelta);
        }
    }
    
    return jornadas;
}

/**
 * Divide la lista de equipos en grupos de forma equitativa
 * @param {Array} equipos - Lista de equipos
 * @param {Number} numGrupos - Cantidad de grupos a crear
 * @returns {Object} Grupos con sus equipos asignados
 */
function distribuirEnGrupos(equipos, numGrupos) {
    let grupos = {};
    for (let i = 0; i < numGrupos; i++) {
        const letraGrupo = String.fromCharCode(65 + i); // A, B, C, D...
        grupos[letraGrupo] = [];
    }
    
    // Distribuir de forma alternada (serpiente) o secuencial
    equipos.forEach((eq, index) => {
        const grupoIdx = index % numGrupos;
        const letraGrupo = String.fromCharCode(65 + grupoIdx);
        grupos[letraGrupo].push(eq);
    });
    
    return grupos;
}

/**
 * Genera las llaves de PlayOffs iniciales (Eliminación directa) por clasificación
 * (1º del Grupo A vs 4º del Grupo B, etc., o por tabla general)
 * @param {Array} clasificados - Lista ordenada de equipos clasificados [{id, nombre, rating_posicion}]
 * @param {String} fase - '16avos', 'octavos', 'cuartos', 'semifinales'
 * @returns {Array} Lista de emparejamientos
 */
function generarLlavesEliminacion(clasificados, fase) {
    let partidos = [];
    const n = clasificados.length;
    
    // Cruces clásicos: 1º vs Nº, 2º vs (N-1)º...
    for (let i = 0; i < n / 2; i++) {
        partidos.push({
            equipo_local: clasificados[i],
            equipo_visitante: clasificados[n - 1 - i],
            fase: fase,
            estado: 'programado',
            goles_local: 0,
            goles_visitante: 0
        });
    }
    
    return partidos;
}
