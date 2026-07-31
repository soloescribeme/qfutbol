/* ==========================================================================
   CONEXIÓN EN LÍNEA CON NEON POSTGRESQL Y UTILIDADES GLOBALES - QFUTBOL
   ========================================================================== */

// ==========================================================================
// GESTIÓN DE SESIÓN Y AUTENTICACIÓN GLOBAL
// ==========================================================================

function obtenerSesionUsuario() {
    try {
        const stored = sessionStorage.getItem("qfutbol_user_session") || localStorage.getItem("qfutbol_user_session");
        if (stored) return JSON.parse(stored);
    } catch(e){}
    return null;
}

function cerrarSesion() {
    try {
        sessionStorage.removeItem("qfutbol_user_session");
        localStorage.removeItem("qfutbol_user_session");
        sessionStorage.clear();
        localStorage.clear();
    } catch(e){}

    const el1 = document.getElementById("lbl-user-welcome-index");
    if (el1) { el1.innerText = ""; el1.style.display = "none"; }
    const el2 = document.getElementById("lbl-user-welcome-dashboard");
    if (el2) { el2.innerText = ""; el2.style.display = "none"; }
    const el3 = document.getElementById("btn-admin-panel-index");
    if (el3) { el3.style.display = "none"; }
    const el4 = document.getElementById("btn-logout-index");
    if (el4) { el4.style.display = "none"; }

    window.location.href = "index.html#login";
}

// Función principal para ejecutar consultas SQL directamente en Neon PostgreSQL sobre HTTP
async function neonQuery(sql, params = []) {
    if (typeof NEON_HTTP_ENDPOINT === 'undefined' || !NEON_HTTP_ENDPOINT) {
        console.warn("NEON_HTTP_ENDPOINT no está configurado.");
        return null;
    }

    try {
        const response = await fetch(NEON_HTTP_ENDPOINT, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Neon-Connection-String': NEON_DB_URL
            },
            body: JSON.stringify({ query: sql, params })
        });

        const data = await response.json();
        if (data.rows) {
            return data.rows;
        } else if (data.message) {
            console.error("Error en consulta Neon SQL:", data.message, "SQL:", sql);
            return null;
        }
        return [];
    } catch (error) {
        console.error("Error de conexión con Neon PostgreSQL:", error);
        return null;
    }
}

// Mapeo de tablas lógicas a físicas en PostgreSQL
function getRemoteTableName(tableName) {
    if (tableName === "jugadores") {
        return "jugadores_globales";
    }
    return tableName;
}

// ==========================================================================
// CAPA DE ACCESO A DATOS EN LÍNEA (NEON POSTGRESQL) CON FALLBACK MOCK
// ==========================================================================

async function dbGetTable(tableName) {
    if (typeof NEON_HTTP_ENDPOINT !== 'undefined' && NEON_HTTP_ENDPOINT) {
        const remoteTable = getRemoteTableName(tableName);
        const rows = await neonQuery(`SELECT * FROM ${remoteTable}`);
        if (rows !== null) {
            return rows;
        }
    }

    // Fallback Mock en memoria / localStorage si falla la conexión
    const localDb = getMockDB();
    return localDb[tableName] || [];
}

async function dbInsertRow(tableName, rowData) {
    if (typeof NEON_HTTP_ENDPOINT !== 'undefined' && NEON_HTTP_ENDPOINT) {
        const remoteTable = getRemoteTableName(tableName);
        const keys = Object.keys(rowData);
        const values = Object.values(rowData);
        const placeholders = keys.map((_, i) => `$${i + 1}`).join(", ");
        const sql = `INSERT INTO ${remoteTable} (${keys.join(", ")}) VALUES (${placeholders}) RETURNING *`;
        
        const rows = await neonQuery(sql, values);
        if (rows && rows.length > 0) {
            return rows[0];
        }
    }

    // Fallback Mock
    const localDb = getMockDB();
    if (!localDb[tableName]) localDb[tableName] = [];
    
    const newRow = { id: genRandomId(), ...rowData };
    localDb[tableName].push(newRow);
    saveMockDB(localDb);
    return newRow;
}

async function dbUpdateRow(tableName, id, rowData) {
    if (typeof NEON_HTTP_ENDPOINT !== 'undefined' && NEON_HTTP_ENDPOINT) {
        const remoteTable = getRemoteTableName(tableName);
        const keys = Object.keys(rowData);
        const values = Object.values(rowData);
        const setClauses = keys.map((key, i) => `${key} = $${i + 1}`).join(", ");
        values.push(id);
        const sql = `UPDATE ${remoteTable} SET ${setClauses} WHERE id = $${keys.length + 1} RETURNING *`;
        
        const rows = await neonQuery(sql, values);
        if (rows && rows.length > 0) {
            return rows[0];
        }
    }

    // Fallback Mock
    const localDb = getMockDB();
    if (localDb[tableName]) {
        const idx = localDb[tableName].findIndex(r => r.id === id);
        if (idx !== -1) {
            localDb[tableName][idx] = { ...localDb[tableName][idx], ...rowData };
            saveMockDB(localDb);
            return localDb[tableName][idx];
        }
    }
    return null;
}

async function dbDeleteRow(tableName, id) {
    if (typeof NEON_HTTP_ENDPOINT !== 'undefined' && NEON_HTTP_ENDPOINT) {
        const remoteTable = getRemoteTableName(tableName);
        const sql = `DELETE FROM ${remoteTable} WHERE id = $1`;
        await neonQuery(sql, [id]);
    }

    // Fallback Mock
    const localDb = getMockDB();
    if (localDb[tableName]) {
        localDb[tableName] = localDb[tableName].filter(r => r.id !== id);
        saveMockDB(localDb);
    }
}

function genRandomId() {
    return Math.random().toString(36).substring(2, 9);
}

// ==========================================================================
// CAPA DE DATOS MOCK SECUNDARIA (FALLBACK OFFLINE)
// ==========================================================================
const MOCK_DB = {
    perfiles: [],
    campeonatos: [],
    categorias: [],
    equipos: [],
    jugadores: [],
    inscripciones_equipo: [],
    partidos: [],
    sanciones_equipos: [],
    detalles_penales: [],
    detalles_partido: []
};

if (!window.qfutbol_mem_db) {
    window.qfutbol_mem_db = MOCK_DB;
}

function getMockDB() {
    try {
        const data = localStorage.getItem("qfutbol_mock_db");
        if (data) return JSON.parse(data);
    } catch (e) {
        console.warn("localStorage no disponible:", e);
    }
    return window.qfutbol_mem_db;
}

function saveMockDB(db) {
    window.qfutbol_mem_db = db;
    try {
        localStorage.setItem("qfutbol_mock_db", JSON.stringify(db));
    } catch (e) {
        console.warn("No se pudo guardar en localStorage:", e);
    }
}

// ==========================================================================
// CÁLCULO FINANCIERO DINÁMICO DE EQUIPOS (EN LÍNEA)
// ==========================================================================
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
