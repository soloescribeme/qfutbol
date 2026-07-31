-- ==========================================
-- SCRIPT DE CONFIGURACIÓN Y ESTRUCTURA POSTGRESQL (NEON / SUPABASE) - QFUTBOL
-- ==========================================

-- 1. LIMPIEZA DE TABLAS EXISTENTES (Orden por dependencias)
DROP TRIGGER IF EXISTS tr_partido_finalizado ON partidos;
DROP FUNCTION IF EXISTS fn_recalcular_scores_partido();
DROP TABLE IF EXISTS recargas_saldo CASCADE;
DROP TABLE IF EXISTS apuestas_registradas CASCADE;
DROP TABLE IF EXISTS apostadores CASCADE;
DROP TABLE IF EXISTS auspiciantes CASCADE;
DROP TABLE IF EXISTS detalles_penales CASCADE;
DROP TABLE IF EXISTS sanciones_equipos CASCADE;
DROP TABLE IF EXISTS pagos_abonos CASCADE;
DROP TABLE IF EXISTS detalles_partido CASCADE;
DROP TABLE IF EXISTS partidos CASCADE;
DROP TABLE IF EXISTS inscripciones_equipo CASCADE;
DROP TABLE IF EXISTS equipos CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS campeonatos CASCADE;
DROP TABLE IF EXISTS jugadores_globales CASCADE;
DROP TABLE IF EXISTS perfiles CASCADE;

-- 2. CREACIÓN DE TABLAS

-- Tabla de perfiles de usuario
CREATE TABLE perfiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL DEFAULT 'vocal' CHECK (rol IN ('admin', 'organizador', 'vocal')),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla global de jugadores identificados por Cédula única
CREATE TABLE jugadores_globales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cedula VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    foto_url TEXT,
    aceptacion_terminos BOOLEAN DEFAULT FALSE NOT NULL,
    rating_general DECIMAL(5,2) DEFAULT 6.00 NOT NULL,
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de campeonatos administrados por un organizador
CREATE TABLE campeonatos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(150) NOT NULL,
    organizador_id UUID REFERENCES perfiles(id) ON DELETE SET NULL,
    estado VARCHAR(20) DEFAULT 'registro' CHECK (estado IN ('registro', 'fase_grupos', 'eliminatorias', 'finalizado')),
    sistema_juego VARCHAR(20) DEFAULT 'todos_contra_todos' CHECK (sistema_juego IN ('todos_contra_todos', 'grupos')),
    cantidad_grupos INT DEFAULT 1,
    parametros_eliminatorias VARCHAR(20) CHECK (parametros_eliminatorias IN ('16avos', 'octavos', 'cuartos', 'semifinales', 'final')),
    limite_pago_inscripcion DATE,
    costo_inscripcion DECIMAL(10,2) DEFAULT 3.00 NOT NULL,
    garantia_disciplina DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    multa_amarilla DECIMAL(10,2) DEFAULT 1.00 NOT NULL,
    multa_roja_doble DECIMAL(10,2) DEFAULT 2.50 NOT NULL,
    multa_roja_directa DECIMAL(10,2) DEFAULT 5.00 NOT NULL,
    amarillas_suspension INT DEFAULT 5 NOT NULL,
    costo_pase_jugador DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    permite_inscripcion_post_grupos BOOLEAN DEFAULT FALSE NOT NULL,
    barrio_sector VARCHAR(150),
    pais VARCHAR(100) DEFAULT 'Ecuador' NOT NULL,
    provincia VARCHAR(100) DEFAULT 'Pichincha',
    canton VARCHAR(100) DEFAULT 'Quito',
    ciudad VARCHAR(100) DEFAULT 'Quito',
    parroquia VARCHAR(100) DEFAULT 'La Floresta',
    divisa VARCHAR(10) DEFAULT 'USD' NOT NULL,
    duracion_estimada_meses INT DEFAULT 3,
    canchas_nombres TEXT,
    pago_plataforma_realizado BOOLEAN DEFAULT FALSE NOT NULL,
    monto_pago_plataforma DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    banco_nombre VARCHAR(100),
    banco_tipo_cuenta VARCHAR(50),
    banco_numero_cuenta VARCHAR(50),
    banco_titular VARCHAR(150),
    banco_titular_identificacion VARCHAR(50),
    banco_telefono_reporte VARCHAR(50),
    costo_arbitraje DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    costo_vocalia DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de auspiciantes/patrocinadores del campeonato
CREATE TABLE auspiciantes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    logo_url TEXT,
    prioridad VARCHAR(10) DEFAULT 'media' CHECK (prioridad IN ('alta', 'media', 'baja')),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de categorias del campeonato
CREATE TABLE categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    genero VARCHAR(20) DEFAULT 'masculino' CHECK (genero IN ('masculino', 'femenino', 'mixto')),
    mixto_minimo_mujeres INT DEFAULT 0,
    mixto_minimo_hombres INT DEFAULT 0,
    modalidad VARCHAR(20) DEFAULT 'futbol_11' CHECK (modalidad IN ('futbol_11', 'futbol_9', 'futbol_7', 'futsal', 'indoor')),
    costo_inscripcion DECIMAL(10,2) DEFAULT 3.00 NOT NULL,
    premio_primer_lugar TEXT DEFAULT 'Trofeo + Medallas de Oro',
    premio_segundo_lugar TEXT DEFAULT 'Trofeo + Medallas de Plata',
    premio_tercer_lugar TEXT DEFAULT 'Medallas de Bronce',
    tiene_premio_mejor_jugador BOOLEAN DEFAULT TRUE,
    tiene_premio_mejor_dt BOOLEAN DEFAULT TRUE,
    tiene_premio_mejor_arquero BOOLEAN DEFAULT TRUE,
    tiene_premio_mejor_barra BOOLEAN DEFAULT TRUE,
    detalles_premios_especiales TEXT,
    duracion_tiempo_minutos INT DEFAULT 25,
    resolucion_empate_eliminatoria VARCHAR(30) DEFAULT 'penales_directos' CHECK (resolucion_empate_eliminatoria IN ('penales_directos', 'adicionales_y_penales')),
    max_jugadores_inscritos INT DEFAULT 18 NOT NULL,
    min_jugadores_presentarse INT DEFAULT 7 NOT NULL,
    tiempo_espera_wo_minutos INT DEFAULT 15 NOT NULL,
    juega_con_uniforme_completo BOOLEAN DEFAULT TRUE,
    tipo_llaves_eliminatorias VARCHAR(30) DEFAULT 'clasificacion_directa' CHECK (tipo_llaves_eliminatorias IN ('sorteo', 'clasificacion_directa')),
    limite_cambios VARCHAR(30) DEFAULT 'ilimitados_con_reingreso',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de equipos inscritos en una categoria
CREATE TABLE equipos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    categoria_id UUID REFERENCES categorias(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    logo_url TEXT,
    contacto_nombre VARCHAR(100),
    contacto_responsable VARCHAR(20),
    monto_pagado_inscripcion DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    monto_garantia_pagado DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT equipo_nombre_categoria_unique UNIQUE (categoria_id, nombre)
);

-- Tabla de inscripción y relación de un jugador en un equipo
CREATE TABLE inscripciones_equipo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    equipo_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    jugador_global_id UUID REFERENCES jugadores_globales(id) ON DELETE CASCADE,
    dorsal INT NOT NULL,
    posicion VARCHAR(20) NOT NULL CHECK (posicion IN ('ARQ', 'DEF', 'MED', 'DEL')),
    rating_campeonato DECIMAL(5,2) DEFAULT 6.00 NOT NULL,
    es_delegado BOOLEAN DEFAULT FALSE NOT NULL,
    fecha_inscripcion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT jugador_dorsal_equipo_unique UNIQUE (equipo_id, dorsal),
    CONSTRAINT jugador_unico_por_campeonato UNIQUE (campeonato_id, jugador_global_id)
);

-- Tabla de partidos
CREATE TABLE partidos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    categoria_id UUID REFERENCES categorias(id) ON DELETE CASCADE,
    equipo_local_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    equipo_visitante_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    grupo VARCHAR(20),
    fase VARCHAR(20) DEFAULT 'regular' CHECK (fase IN ('regular', '16avos', 'octavos', 'cuartos', 'semifinales', 'final')),
    fecha TIMESTAMP WITH TIME ZONE,
    estado VARCHAR(20) DEFAULT 'programado' CHECK (estado IN ('programado', 'jugando', 'finalizado', 'suspendido')),
    goles_local INT DEFAULT 0,
    goles_visitante INT DEFAULT 0,
    vocal_id UUID REFERENCES perfiles(id) ON DELETE SET NULL,
    arbitro_nombre VARCHAR(100),
    clima VARCHAR(50),
    observaciones_acta TEXT,
    firma_local BOOLEAN DEFAULT FALSE NOT NULL,
    firma_visitante BOOLEAN DEFAULT FALSE NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT partidos_equipos_diferentes CHECK (equipo_local_id <> equipo_visitante_id)
);

-- Tabla de detalles/estadísticas del partido
CREATE TABLE detalles_partido (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partido_id UUID REFERENCES partidos(id) ON DELETE CASCADE,
    inscripcion_jugador_id UUID REFERENCES inscripciones_equipo(id) ON DELETE CASCADE,
    goles INT DEFAULT 0 NOT NULL,
    asistencias INT DEFAULT 0 NOT NULL,
    amarillas INT DEFAULT 0 NOT NULL CHECK (amarillas IN (0, 1, 2)),
    rojas INT DEFAULT 0 NOT NULL CHECK (rojas IN (0, 1)),
    expulsado_etilicidad BOOLEAN DEFAULT FALSE NOT NULL,
    valoracion DECIMAL(4,2) DEFAULT 6.00 NOT NULL CHECK (valoracion >= 1.00 AND valoracion <= 10.00),
    minutos_jugados INT DEFAULT 0 NOT NULL,
    rol_cuerpo_tecnico VARCHAR(30) DEFAULT 'jugador' CHECK (rol_cuerpo_tecnico IN ('jugador', 'dt', 'asistente', 'kinesiolo')),
    CONSTRAINT detalle_partido_jugador_unique UNIQUE (partido_id, inscripcion_jugador_id)
);

-- Tabla de pagos y abonos
CREATE TABLE pagos_abonos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipo_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    concepto VARCHAR(50) NOT NULL CHECK (concepto IN ('inscripcion', 'garantia', 'arbitraje', 'vocalia', 'multa_tarjeta', 'pase', 'multa')),
    monto DECIMAL(10,2) NOT NULL,
    partido_id UUID REFERENCES partidos(id) ON DELETE SET NULL,
    metodo_pago VARCHAR(20) DEFAULT 'efectivo' CHECK (metodo_pago IN ('efectivo', 'transferencia', 'tarjeta')),
    comprobante_url TEXT,
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobado', 'rechazado')),
    fecha_pago TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de sanciones a equipos
CREATE TABLE sanciones_equipos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipo_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    puntos_restados INT DEFAULT 0 NOT NULL,
    monto_multa DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    motivo TEXT NOT NULL,
    fecha_sancion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de penales
CREATE TABLE detalles_penales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partido_id UUID REFERENCES partidos(id) ON DELETE CASCADE,
    equipo_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    inscripcion_jugador_id UUID REFERENCES inscripciones_equipo(id) ON DELETE CASCADE,
    orden INT NOT NULL,
    convertido BOOLEAN DEFAULT TRUE NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Módulo de Apuestas
CREATE TABLE apostadores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    perfil_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    balance_saldo DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    ganancias_totales DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    perdidas_totales DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE apuestas_registradas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apostador_id UUID REFERENCES apostadores(id) ON DELETE CASCADE,
    partido_id UUID REFERENCES partidos(id) ON DELETE CASCADE,
    seleccion_pronostico VARCHAR(20) NOT NULL CHECK (seleccion_pronostico IN ('local', 'empate', 'visitante')),
    monto_apostado DECIMAL(10,2) NOT NULL CHECK (monto_apostado > 0),
    cuota_apostada DECIMAL(5,2) NOT NULL,
    retorno_potencial DECIMAL(10,2) NOT NULL,
    estado_apuesta VARCHAR(20) DEFAULT 'pendiente' CHECK (estado_apuesta IN ('pendiente', 'ganada', 'perdida')),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE recargas_saldo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apostador_id UUID REFERENCES apostadores(id) ON DELETE CASCADE,
    metodo VARCHAR(20) NOT NULL CHECK (metodo IN ('deposito', 'transferencia', 'tarjeta')),
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    comprobante_url TEXT,
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobado', 'rechazado')),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CÁLCULO DE SCORES (FUNCIÓN Y TRIGGER EN PL/PGSQL)

CREATE OR REPLACE FUNCTION fn_recalcular_scores_partido()
RETURNS TRIGGER AS $$
DECLARE
    r_detalle RECORD;
    score_partido DECIMAL(5,2);
    p_posicion VARCHAR(20);
    p_goles INT;
    p_asistencias INT;
    p_amarillas INT;
    p_rojas INT;
    p_etilicidad BOOLEAN;
    p_valoracion DECIMAL(4,2);
    p_jugador_global_id UUID;
    p_inscripcion_id UUID;
    avg_rating_campeonato DECIMAL(5,2);
    avg_rating_general DECIMAL(5,2);
BEGIN
    IF NEW.estado = 'finalizado' AND NEW.firma_local = TRUE AND NEW.firma_visitante = TRUE THEN
        FOR r_detalle IN 
            SELECT dp.*, ie.posicion, ie.jugador_global_id 
            FROM detalles_partido dp
            JOIN inscripciones_equipo ie ON dp.inscripcion_jugador_id = ie.id
            WHERE dp.partido_id = NEW.id
        LOOP
            p_inscripcion_id := r_detalle.inscripcion_jugador_id;
            p_posicion := r_detalle.posicion;
            p_goles := r_detalle.goles;
            p_asistencias := r_detalle.asistencias;
            p_amarillas := r_detalle.amarillas;
            p_rojas := r_detalle.rojas;
            p_etilicidad := r_detalle.expulsado_etilicidad;
            p_valoracion := r_detalle.valoracion;
            p_jugador_global_id := r_detalle.jugador_global_id;

            IF p_posicion = 'ARQ' THEN
                score_partido := (p_valoracion * 1.0) + (p_goles * 8.0) + (p_asistencias * 3.0) - (p_amarillas * 1.0) - (p_rojas * 3.0);
            ELSIF p_posicion = 'DEF' THEN
                score_partido := (p_valoracion * 0.8) + (p_goles * 6.0) + (p_asistencias * 3.0) - (p_amarillas * 1.0) - (p_rojas * 3.0);
            ELSIF p_posicion = 'MED' THEN
                score_partido := (p_valoracion * 0.6) + (p_goles * 5.0) + (p_asistencias * 4.0) - (p_amarillas * 1.0) - (p_rojas * 3.0);
            ELSE
                score_partido := (p_valoracion * 0.5) + (p_goles * 4.0) + (p_asistencias * 3.0) - (p_amarillas * 1.0) - (p_rojas * 3.0);
            END IF;

            IF p_etilicidad = TRUE THEN
                score_partido := score_partido - 10.00;
            END IF;

            IF score_partido < 0 THEN
                score_partido := 0.00;
            END IF;

            SELECT COALESCE(AVG(
                CASE 
                    WHEN ie.posicion = 'ARQ' THEN (dp.valoracion * 1.0) + (dp.goles * 8.0) + (dp.asistencias * 3.0) - (dp.amarillas * 1.0) - (dp.rojas * 3.0)
                    WHEN ie.posicion = 'DEF' THEN (dp.valoracion * 0.8) + (dp.goles * 6.0) + (dp.asistencias * 3.0) - (dp.amarillas * 1.0) - (dp.rojas * 3.0)
                    WHEN ie.posicion = 'MED' THEN (dp.valoracion * 0.6) + (dp.goles * 5.0) + (dp.asistencias * 4.0) - (dp.amarillas * 1.0) - (dp.rojas * 3.0)
                    ELSE (dp.valoracion * 0.5) + (dp.goles * 4.0) + (dp.asistencias * 3.0) - (dp.amarillas * 1.0) - (dp.rojas * 3.0)
                END - CASE WHEN dp.expulsado_etilicidad = TRUE THEN 10.00 ELSE 0.00 END
            ), 6.00)
            INTO avg_rating_campeonato
            FROM detalles_partido dp
            JOIN partidos p ON dp.partido_id = p.id
            JOIN inscripciones_equipo ie ON dp.inscripcion_jugador_id = ie.id
            WHERE ie.id = p_inscripcion_id AND p.estado = 'finalizado' AND p.firma_local = TRUE AND p.firma_visitante = TRUE;

            IF avg_rating_campeonato < 0 THEN
                avg_rating_campeonato := 0.00;
            END IF;

            UPDATE inscripciones_equipo 
            SET rating_campeonato = avg_rating_campeonato 
            WHERE id = p_inscripcion_id;

            SELECT COALESCE(AVG(rating_campeonato), 6.00)
            INTO avg_rating_general
            FROM inscripciones_equipo
            WHERE jugador_global_id = p_jugador_global_id;

            UPDATE jugadores_globales 
            SET rating_general = avg_rating_general 
            WHERE id = p_jugador_global_id;

        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_partido_finalizado
AFTER UPDATE OF estado, firma_local, firma_visitante ON partidos
FOR EACH ROW
EXECUTE FUNCTION fn_recalcular_scores_partido();

-- 4. DATOS SEMILLA INICIALES DE PRUEBA

INSERT INTO perfiles (id, nombres, apellidos, rol) VALUES
('22222222-2222-2222-2222-222222222222', 'Pedro', 'Vargas', 'organizador'),
('33333333-3333-3333-3333-333333333333', 'Carlos', 'Mena', 'vocal');

INSERT INTO campeonatos (id, nombre, organizador_id, estado, sistema_juego, limite_pago_inscripcion, costo_inscripcion, garantia_disciplina, multa_amarilla, multa_roja_doble, multa_roja_directa, amarillas_suspension, barrio_sector, duracion_estimada_meses, canchas_nombres, banco_nombre, banco_tipo_cuenta, banco_numero_cuenta, banco_titular, banco_titular_identificacion, banco_telefono_reporte, costo_arbitraje, costo_vocalia) VALUES
('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Torneo Nocturno de Barrio La Floresta', '22222222-2222-2222-2222-222222222222', 'registro', 'todos_contra_todos', '2026-08-30', 3.00, 10.00, 1.00, 2.50, 5.00, 5, 'La Floresta, Quito', 3, 'Cancha Principal, Coliseo Cerrado', 'Banco Pichincha', 'Ahorros', '2200456789', 'QFutbol Liga Barrial', '1712345678', '0991234567', 10.00, 5.00);
