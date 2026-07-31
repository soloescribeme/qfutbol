/* ==========================================================================
   CONEXIÓN CON SUPABASE Y UTILIDADES GLOBALES - QFUTBOL
   ========================================================================== */

let supabaseClient = null;

// Inicialización del cliente Supabase
function inicializarSupabase() {
    if (typeof window.supabase === 'undefined' || typeof window.supabase.createClient !== 'function') {
        console.warn("La librería Supabase CDN no ha cargado correctamente.");
        window.supabase = null;
        return false;
    }

    if (SUPABASE_URL === "TU_SUPABASE_URL" || SUPABASE_ANON_KEY === "TU_SUPABASE_ANON_KEY") {
        console.log("Credenciales de Supabase por defecto detectadas. Usando modo MOCK_DATA.");
        window.supabase = null;
        return false;
    }

    try {
        // Usar window.supabase para referirse a la librería CDN y crear la instancia del cliente
        const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        supabaseClient = client;
        window.supabase = client; // Exponer el cliente al ámbito global
        console.log("Supabase inicializado correctamente.");
        return true;
    } catch (error) {
        console.error("Error al inicializar Supabase:", error);
        window.supabase = null;
        return false;
    }
}

// Inicializar al cargar el script
document.addEventListener("DOMContentLoaded", () => {
    inicializarSupabase();
});

// ==========================================================================
// CAPA DE DATOS MOCK (Para pruebas sin conexión a Supabase)
// ==========================================================================
const MOCK_DB = {
    perfiles: [
        { id: "1", nombres: "Juan", apellidos: "Lozano", rol: "admin" },
        { id: "2", nombres: "Pedro", apellidos: "Vargas", rol: "organizador" },
        { id: "3", nombres: "Carlos", apellidos: "Mena", rol: "vocal" }
    ],
    campeonatos: [
        {
            id: "c1",
            nombre: "Torneo Nocturno de Barrio La Floresta",
            organizador_id: "2",
            estado: "registro",
            sistema_juego: "todos_contra_todos",
            limite_pago_inscripcion: "2026-08-30",
            costo_inscripcion: 3.00,
            garantia_disciplina: 10.00,
            multa_amarilla: 1.00,
            multa_roja_doble: 2.50,
            multa_roja_directa: 5.00,
            amarillas_suspension: 5,
            barrio_sector: "La Floresta, Quito",
            pais: "Ecuador",
            provincia: "Pichincha",
            canton: "Quito",
            ciudad: "Quito",
            parroquia: "La Floresta",
            divisa: "USD",
            duracion_estimada_meses: 3,
            canchas_nombres: "Cancha Principal, Coliseo Cerrado",
            banco_nombre: "Banco Pichincha",
            banco_tipo_cuenta: "Ahorros",
            banco_numero_cuenta: "2200456789",
            banco_titular: "QFutbol Liga Barrial",
            banco_titular_identificacion: "1712345678",
            banco_telefono_reporte: "0991234567",
            costo_arbitraje: 10.00,
            costo_vocalia: 5.00,
            pago_plataforma_realizado: false,
            monto_pago_plataforma: 0.00
        }
    ],
    categorias: [],
    equipos: [],
    jugadores: [],
    inscripciones_equipo: [],
    partidos: [],
    sanciones_equipos: [],
    detalles_penales: [],
    detalles_partido: []
};

// Memoria fallback en caso de que localStorage esté bloqueado por restricciones del navegador (ej. file://)
if (!window.qfutbol_mem_db) {
    window.qfutbol_mem_db = MOCK_DB;
}

function getMockDB() {
    try {
        const data = localStorage.getItem("qfutbol_mock_db");
        if (data) return JSON.parse(data);
    } catch (e) {
        console.warn("localStorage no disponible, usando base en memoria:", e);
    }
    return window.qfutbol_mem_db;
}

function saveMockDB(db) {
    window.qfutbol_mem_db = db;
    try {
        localStorage.setItem("qfutbol_mock_db", JSON.stringify(db));
    } catch (e) {
        console.warn("No se pudo guardar en localStorage, guardado en memoria:", e);
    }
}

// Sobrescribimos el localStorage para que los datos nuevos con inscripciones_equipo y cédulas se apliquen de inmediato
saveMockDB(MOCK_DB);

// Función para mapear nombres de tablas lógicas a las físicas de Supabase
function getRemoteTableName(tableName) {
    if (tableName === "jugadores") {
        return "jugadores_globales";
    }
    return tableName;
}

// Función auxiliar para obtener datos (Supabase o LocalStorage Fallback)
async function dbGetTable(tableName) {
    if (supabaseClient && supabaseClient.auth) {
        const remoteTable = getRemoteTableName(tableName);
        const { data, error } = await supabaseClient.from(remoteTable).select("*");
        if (!error) return data;
        console.error(`Error al leer tabla ${remoteTable}:`, error);
    }
    
    // Fallback Mock seguro
    const localDb = getMockDB();
    return localDb[tableName] || [];
}

// Función auxiliar para insertar datos
async function dbInsertRow(tableName, rowData) {
    if (supabaseClient && supabaseClient.auth) {
        const remoteTable = getRemoteTableName(tableName);
        const { data, error } = await supabaseClient.from(remoteTable).insert([rowData]).select();
        if (!error) return data[0];
        console.error(`Error al insertar en ${remoteTable}:`, error);
    }
    
    // Fallback Mock seguro
    const localDb = getMockDB();
    if (!localDb[tableName]) localDb[tableName] = [];
    
    const newRow = { id: genRandomId(), ...rowData };
    localDb[tableName].push(newRow);
    saveMockDB(localDb);
    return newRow;
}

function genRandomId() {
    return Math.random().toString(36).substring(2, 9);
}

// Función para calcular dinámicamente el estado financiero de un equipo
async function calcularFinanzasEquipo(equipoId) {
    const cacheEquipos = await dbGetTable("equipos");
    const cachePartidos = await dbGetTable("partidos");
    const cacheInscripciones = await dbGetTable("inscripciones_equipo");
    const cacheDetallesPartidos = await dbGetTable("detalles_partido");
    const cachePagos = await dbGetTable("pagos_abonos");
    const cacheSanciones = await dbGetTable("sanciones_equipos");
    const cacheCategorias = await dbGetTable("categorias");
    const campeonatos = await dbGetTable("campeonatos");
    const configCampeonato = campeonatos.length > 0 ? campeonatos[0] : {};

    const eq = cacheEquipos.find(e => e.id === equipoId);
    if (!eq) return null;

    const cat = cacheCategorias.find(c => c.id === eq.categoria_id) || {};

    // 1. Inscripción
    const costoInscripcion = parseFloat(cat.costo_inscripcion || configCampeonato.costo_inscripcion || 3.00);
    const pagosInscripcion = cachePagos.filter(p => p.equipo_id === equipoId && p.concepto === "inscripcion" && p.estado !== "rechazado")
        .reduce((sum, p) => sum + parseFloat(p.monto), 0);
    const pagadoInscripcionLegacy = parseFloat(eq.monto_pagado_inscripcion || 0);
    const pagadoInscripcion = Math.max(pagosInscripcion, pagadoInscripcionLegacy);
    const saldoInscripcion = Math.max(0, costoInscripcion - pagadoInscripcion);

    // 2. Garantía
    const costoGarantia = parseFloat(configCampeonato.garantia_disciplina || 0.00);
    const pagosGarantia = cachePagos.filter(p => p.equipo_id === equipoId && p.concepto === "garantia" && p.estado !== "rechazado")
        .reduce((sum, p) => sum + parseFloat(p.monto), 0);
    const pagadoGarantiaLegacy = parseFloat(eq.monto_garantia_pagado || 0);
    const pagadoGarantia = Math.max(pagosGarantia, pagadoGarantiaLegacy);
    const saldoGarantia = Math.max(0, costoGarantia - pagadoGarantia);

    // 3. Arbitraje y Vocalía
    const partidosJugados = cachePartidos.filter(p => p.estado === "finalizado" && (p.equipo_local_id === equipoId || p.equipo_visitante_id === equipoId)).length;
    const costoArbitrajeTotal = partidosJugados * parseFloat(configCampeonato.costo_arbitraje || 0.00);
    const costoVocaliaTotal = partidosJugados * parseFloat(configCampeonato.costo_vocalia || 0.00);

    const pagadoArbitraje = cachePagos.filter(p => p.equipo_id === equipoId && p.concepto === "arbitraje" && p.estado !== "rechazado")
        .reduce((sum, p) => sum + parseFloat(p.monto), 0);
    const pagadoVocalia = cachePagos.filter(p => p.equipo_id === equipoId && p.concepto === "vocalia" && p.estado !== "rechazado")
        .reduce((sum, p) => sum + parseFloat(p.monto), 0);

    const saldoArbitraje = Math.max(0, costoArbitrajeTotal - pagadoArbitraje);
    const saldoVocalia = Math.max(0, costoVocaliaTotal - pagadoVocalia);

    // 4. Multas por Tarjetas
    const inscritosIds = cacheInscripciones.filter(ins => ins.equipo_id === equipoId).map(ins => ins.id);
    let costoTarjetasTotal = 0;
    const detallesDeJugadores = cacheDetallesPartidos.filter(d => inscritosIds.includes(d.inscripcion_jugador_id));
    detallesDeJugadores.forEach(d => {
        if (d.amarillas === 2) {
            costoTarjetasTotal += parseFloat(configCampeonato.multa_roja_doble || 2.50);
        } else if (d.amarillas === 1) {
            costoTarjetasTotal += parseFloat(configCampeonato.multa_amarilla || 1.00);
        }
        if (d.rojas > 0) {
            costoTarjetasTotal += parseFloat(configCampeonato.multa_roja_directa || 5.00);
        }
    });

    const pagadoTarjetas = cachePagos.filter(p => p.equipo_id === equipoId && p.concepto === "multa_tarjeta" && p.estado !== "rechazado")
        .reduce((sum, p) => sum + parseFloat(p.monto), 0);
    const saldoTarjetas = Math.max(0, costoTarjetasTotal - pagadoTarjetas);

    // 5. Otras Multas (Administrativas)
    const costoSancionesTotal = cacheSanciones.filter(s => s.equipo_id === equipoId).reduce((sum, s) => sum + parseFloat(s.monto_multa), 0);
    const pagadoOtrasMultas = cachePagos.filter(p => p.equipo_id === equipoId && p.concepto === "multa" && p.estado !== "rechazado")
        .reduce((sum, p) => sum + parseFloat(p.monto), 0);
    const saldoOtrasMultas = Math.max(0, costoSancionesTotal - pagadoOtrasMultas);

    // 6. Totales
    const totalDeuda = saldoInscripcion + saldoGarantia + saldoArbitraje + saldoVocalia + saldoTarjetas + saldoOtrasMultas;
    const totalPagado = pagadoInscripcion + pagadoGarantia + pagadoArbitraje + pagadoVocalia + pagadoTarjetas + pagadoOtrasMultas;
    const totalCargo = costoInscripcion + costoGarantia + costoArbitrajeTotal + costoVocaliaTotal + costoTarjetasTotal + costoSancionesTotal;

    return {
        costoInscripcion, pagadoInscripcion, saldoInscripcion,
        costoGarantia, pagadoGarantia, saldoGarantia,
        costoArbitrajeTotal, pagadoArbitraje, saldoArbitraje,
        costoVocaliaTotal, pagadoVocalia, saldoVocalia,
        costoTarjetasTotal, pagadoTarjetas, saldoTarjetas,
        costoSancionesTotal, pagadoOtrasMultas, saldoOtrasMultas,
        totalCargo, totalPagado, totalDeuda,
        partidosJugados
    };
}
