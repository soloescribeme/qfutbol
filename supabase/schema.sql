-- ==========================================
-- SCRIPT DE CONFIGURACIÓN Y LIMPIEZA - QFUTBOL
-- Postgres / Supabase Schema
-- ==========================================

-- 1. LIMPIEZA DE TABLAS EXISTENTES (Orden correcto por dependencias)
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

-- Tabla de perfiles de usuario vinculada a la autenticación de Supabase (auth.users)
CREATE TABLE perfiles (
    id UUID PRIMARY KEY, -- Se vincula directamente con auth.users.id
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL DEFAULT 'vocal' CHECK (rol IN ('admin', 'organizador', 'vocal')),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla global de jugadores identificados por su Cédula de Identidad única
CREATE TABLE jugadores_globales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cedula VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    foto_url TEXT,
    aceptacion_terminos BOOLEAN DEFAULT FALSE NOT NULL,
    rating_general DECIMAL(5,2) DEFAULT 6.00 NOT NULL, -- Rating histórico promedio
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
    -- Datos del Entorno del Torneo
    barrio_sector VARCHAR(150), -- Nombre del barrio/sector de juego
    pais VARCHAR(100) DEFAULT 'Ecuador' NOT NULL,
    provincia VARCHAR(100) DEFAULT 'Pichincha',
    canton VARCHAR(100) DEFAULT 'Quito',
    ciudad VARCHAR(100) DEFAULT 'Quito',
    parroquia VARCHAR(100) DEFAULT 'La Floresta',
    divisa VARCHAR(10) DEFAULT 'USD' NOT NULL,
    duracion_estimada_meses INT DEFAULT 3, -- Duración estimada del campeonato
    canchas_nombres TEXT, -- Nombre de las canchas habilitadas (separadas por comas)
    -- Control de Pago de la Plataforma QFutbol (Bloqueo de Fixture)
    pago_plataforma_realizado BOOLEAN DEFAULT FALSE NOT NULL,
    monto_pago_plataforma DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    -- Datos Bancarios de la Liga para recibir pagos
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
    logo_url TEXT, -- Almacenará el link o el string Base64 del logo
    prioridad VARCHAR(10) DEFAULT 'media' CHECK (prioridad IN ('alta', 'media', 'baja')),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de categorias del campeonato (Sub-8, Sub-10, Abierta, Senior, etc.)
CREATE TABLE categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL, -- Ej: 'Sub 10', 'Senior Pos 40'
    genero VARCHAR(20) DEFAULT 'masculino' CHECK (genero IN ('masculino', 'femenino', 'mixto')),
    mixto_minimo_mujeres INT DEFAULT 0, -- Obligatorio en cancha si es mixto
    mixto_minimo_hombres INT DEFAULT 0, -- Obligatorio en cancha si es mixto
    modalidad VARCHAR(20) DEFAULT 'futbol_11' CHECK (modalidad IN ('futbol_11', 'futbol_9', 'futbol_7', 'futsal', 'indoor')),
    costo_inscripcion DECIMAL(10,2) DEFAULT 3.00 NOT NULL,
    premio_primer_lugar TEXT DEFAULT 'Trofeo + Medallas de Oro',
    premio_segundo_lugar TEXT DEFAULT 'Trofeo + Medallas de Plata',
    premio_tercer_lugar TEXT DEFAULT 'Medallas de Bronce',
    tiene_premio_mejor_jugador BOOLEAN DEFAULT TRUE,
    tiene_premio_mejor_dt BOOLEAN DEFAULT TRUE,
    tiene_premio_mejor_arquero BOOLEAN DEFAULT TRUE,
    tiene_premio_mejor_barra BOOLEAN DEFAULT TRUE,
    detalles_premios_especiales TEXT, -- Qué se va a dar
    duracion_tiempo_minutos INT DEFAULT 25, -- Ej. 2 tiempos de 25 min o 45 min
    resolucion_empate_eliminatoria VARCHAR(30) DEFAULT 'penales_directos' CHECK (resolucion_empate_eliminatoria IN ('penales_directos', 'adicionales_y_penales')),
    max_jugadores_inscritos INT DEFAULT 18 NOT NULL,
    min_jugadores_presentarse INT DEFAULT 7 NOT NULL,
    tiempo_espera_wo_minutos INT DEFAULT 15 NOT NULL,
    juega_con_uniforme_completo BOOLEAN DEFAULT TRUE, -- Uniforme completo o solo camiseta
    tipo_llaves_eliminatorias VARCHAR(30) DEFAULT 'clasificacion_directa' CHECK (tipo_llaves_eliminatorias IN ('sorteo', 'clasificacion_directa')),
    limite_cambios VARCHAR(30) DEFAULT 'ilimitados_con_reingreso', -- 'ilimitados_con_reingreso', 'max_5'
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de equipos inscritos en una categoria
CREATE TABLE equipos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    categoria_id UUID REFERENCES categorias(id) ON DELETE CASCADE, -- Asociación a categoría específica
    nombre VARCHAR(100) NOT NULL,
    logo_url TEXT,
    contacto_nombre VARCHAR(100), -- Nombre del delegado/responsable
    contacto_responsable VARCHAR(20), -- Nro de contacto para recibir horarios
    monto_pagado_inscripcion DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    monto_garantia_pagado DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- Restricción crítica: El nombre del equipo no puede repetirse en la misma categoría
    CONSTRAINT equipo_nombre_categoria_unique UNIQUE (categoria_id, nombre)
);

-- Tabla de inscripción y relación de un jugador en un equipo para un campeonato
CREATE TABLE inscripciones_equipo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    equipo_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    jugador_global_id UUID REFERENCES jugadores_globales(id) ON DELETE CASCADE,
    dorsal INT NOT NULL,
    posicion VARCHAR(20) NOT NULL CHECK (posicion IN ('ARQ', 'DEF', 'MED', 'DEL')),
    rating_campeonato DECIMAL(5,2) DEFAULT 6.00 NOT NULL, -- Promedio del jugador en el torneo
    es_delegado BOOLEAN DEFAULT FALSE NOT NULL, -- Determina si es DT/Delegado para ver datos financieros
    fecha_inscripcion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT jugador_dorsal_equipo_unique UNIQUE (equipo_id, dorsal),
    -- Restricción crítica: Un jugador no puede participar en 2 equipos del mismo campeonato
    CONSTRAINT jugador_unico_por_campeonato UNIQUE (campeonato_id, jugador_global_id)
);

-- Tabla de partidos de un campeonato
CREATE TABLE partidos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campeonato_id UUID REFERENCES campeonatos(id) ON DELETE CASCADE,
    categoria_id UUID REFERENCES categorias(id) ON DELETE CASCADE, -- Asociación a categoría
    equipo_local_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    equipo_visitante_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    grupo VARCHAR(20), -- ej: 'Grupo A', 'Grupo B'
    fase VARCHAR(20) DEFAULT 'regular' CHECK (fase IN ('regular', '16avos', 'octavos', 'cuartos', 'semifinales', 'final')),
    fecha TIMESTAMP WITH TIME ZONE,
    estado VARCHAR(20) DEFAULT 'programado' CHECK (estado IN ('programado', 'jugando', 'finalizado', 'suspendido')),
    goles_local INT DEFAULT 0,
    goles_visitante INT DEFAULT 0,
    vocal_id UUID REFERENCES perfiles(id) ON DELETE SET NULL,
    arbitro_nombre VARCHAR(100), -- Nombre del árbitro asignado
    clima VARCHAR(50), -- soleado, lluvioso, nublado
    observaciones_acta TEXT, -- anotaciones de incidentes
    firma_local BOOLEAN DEFAULT FALSE NOT NULL,
    firma_visitante BOOLEAN DEFAULT FALSE NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT partidos_equipos_diferentes CHECK (equipo_local_id <> equipo_visitante_id)
);

-- Tabla de estadísticas/desempeño de un jugador en un partido
CREATE TABLE detalles_partido (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partido_id UUID REFERENCES partidos(id) ON DELETE CASCADE,
    inscripcion_jugador_id UUID REFERENCES inscripciones_equipo(id) ON DELETE CASCADE,
    goles INT DEFAULT 0 NOT NULL,
    asistencias INT DEFAULT 0 NOT NULL,
    amarillas INT DEFAULT 0 NOT NULL CHECK (amarillas IN (0, 1, 2)), -- 2 amarillas es expulsión indirecta
    rojas INT DEFAULT 0 NOT NULL CHECK (rojas IN (0, 1)),
    expulsado_etilicidad BOOLEAN DEFAULT FALSE NOT NULL,
    valoracion DECIMAL(4,2) DEFAULT 6.00 NOT NULL CHECK (valoracion >= 1.00 AND valoracion <= 10.00), -- Calificación de la vocal (1 a 10)
    minutos_jugados INT DEFAULT 0 NOT NULL,
    rol_cuerpo_tecnico VARCHAR(30) DEFAULT 'jugador' CHECK (rol_cuerpo_tecnico IN ('jugador', 'dt', 'asistente', 'kinesiolo')), -- Soporte cuerpo técnico
    CONSTRAINT detalle_partido_jugador_unique UNIQUE (partido_id, inscripcion_jugador_id)
);

-- Tabla financiera de pagos de inscripción, garantías, arbitrajes, vocalías o multas
CREATE TABLE pagos_abonos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipo_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    concepto VARCHAR(50) NOT NULL CHECK (concepto IN ('inscripcion', 'garantia', 'arbitraje', 'vocalia', 'multa_tarjeta', 'pase', 'multa')),
    monto DECIMAL(10,2) NOT NULL,
    partido_id UUID REFERENCES partidos(id) ON DELETE SET NULL, -- Referencia opcional si el pago corresponde a un partido
    metodo_pago VARCHAR(20) DEFAULT 'efectivo' CHECK (metodo_pago IN ('efectivo', 'transferencia', 'tarjeta')),
    comprobante_url TEXT, -- Url de la imagen de transferencia o recibo
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobado', 'rechazado')),
    fecha_pago TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de sanciones administrativas y multas/reducción de puntos a equipos
CREATE TABLE sanciones_equipos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipo_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    puntos_restados INT DEFAULT 0 NOT NULL, -- Penalización de puntos en la tabla
    monto_multa DECIMAL(10,2) DEFAULT 0.00 NOT NULL, -- Sanción financiera
    motivo TEXT NOT NULL,
    fecha_sancion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla para el control de la tanda de penales en definiciones empatadas
CREATE TABLE detalles_penales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partido_id UUID REFERENCES partidos(id) ON DELETE CASCADE,
    equipo_id UUID REFERENCES equipos(id) ON DELETE CASCADE,
    inscripcion_jugador_id UUID REFERENCES inscripciones_equipo(id) ON DELETE CASCADE,
    orden INT NOT NULL, -- Orden de cobro (1, 2, 3, etc.)
    convertido BOOLEAN DEFAULT TRUE NOT NULL, -- Gol o fallado/atajado
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 3. LOGICA DE CÁLCULO DE SCORE DE JUGADORES (TRIGGERS / FUNCIONES)
-- ==========================================

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
    -- El recálculo de scores solo se ejecuta si el partido pasa a estado 'finalizado'
    -- y ambos delegados/capitanes han firmado el acta digital
    IF NEW.estado = 'finalizado' AND NEW.firma_local = TRUE AND NEW.firma_visitante = TRUE THEN
        
        -- Recorremos todos los rendimientos de los jugadores en este partido
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

            -- FÓRMULA DE SCORE PONDERADO SEGÚN LA POSICIÓN EN EL CAMPO
            IF p_posicion = 'ARQ' THEN
                score_partido := (p_valoracion * 1.0) + (p_goles * 8.0) + (p_asistencias * 3.0) - (p_amarillas * 1.0) - (p_rojas * 3.0);
            ELSIF p_posicion = 'DEF' THEN
                score_partido := (p_valoracion * 0.8) + (p_goles * 6.0) + (p_asistencias * 3.0) - (p_amarillas * 1.0) - (p_rojas * 3.0);
            ELSIF p_posicion = 'MED' THEN
                score_partido := (p_valoracion * 0.6) + (p_goles * 5.0) + (p_asistencias * 4.0) - (p_amarillas * 1.0) - (p_rojas * 3.0);
            ELSE -- DEL (Delantero)
                score_partido := (p_valoracion * 0.5) + (p_goles * 4.0) + (p_asistencias * 3.0) - (p_amarillas * 1.0) - (p_rojas * 3.0);
            END IF;

            -- Penalización drástica por expulsión por estado etílico
            IF p_etilicidad = TRUE THEN
                score_partido := score_partido - 10.00;
            END IF;

            -- Limitar el score para que se mantenga en un rango razonable (ej. min 0, max 100)
            IF score_partido < 0 THEN
                score_partido := 0.00;
            END IF;

            -- 1. Actualizar el rating acumulado del jugador para el campeonato actual
            -- (Calculado como el promedio de todas las valoraciones obtenidas en partidos de este campeonato)
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

            -- 2. Recalcular el rating general/histórico del jugador (promedio de sus ratings de todos los campeonatos)
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

-- Trigger asociado a la tabla de partidos
CREATE TRIGGER tr_partido_finalizado
AFTER UPDATE OF estado, firma_local, firma_visitante ON partidos
FOR EACH ROW
EXECUTE FUNCTION fn_recalcular_scores_partido();

-- ==========================================
-- 4. INSERT DE DATOS SEMILLA (Pruebas iniciales)
-- ==========================================

-- Perfiles semilla
INSERT INTO perfiles (id, nombres, apellidos, rol) VALUES
('22222222-2222-2222-2222-222222222222', 'Pedro', 'Vargas', 'organizador'),
('33333333-3333-3333-3333-333333333333', 'Carlos', 'Mena', 'vocal');

-- Campeonatos semilla (Por defecto, en estado de registro y sin pago realizado)
INSERT INTO campeonatos (id, nombre, organizador_id, estado, sistema_juego, limite_pago_inscripcion, costo_inscripcion, garantia_disciplina, multa_amarilla, multa_roja_doble, multa_roja_directa, amarillas_suspension, barrio_sector, duracion_estimada_meses, canchas_nombres, banco_nombre, banco_tipo_cuenta, banco_numero_cuenta, banco_titular, banco_titular_identificacion, banco_telefono_reporte, costo_arbitraje, costo_vocalia) VALUES
('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Torneo Nocturno de Barrio La Floresta', '22222222-2222-2222-2222-222222222222', 'registro', 'todos_contra_todos', '2026-08-30', 3.00, 10.00, 1.00, 2.50, 5.00, 5, 'La Floresta, Quito', 3, 'Cancha Principal, Coliseo Cerrado', 'Banco Pichincha', 'Ahorros', '2200456789', 'QFutbol Liga Barrial', '1712345678', '0991234567', 10.00, 5.00);

-- ==========================================
-- 5. POLÍTICAS DE SEGURIDAD (ROW LEVEL SECURITY - RLS)
-- ==========================================

-- Habilitar RLS en las tablas del sistema
ALTER TABLE perfiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE jugadores_globales ENABLE ROW LEVEL SECURITY;
ALTER TABLE campeonatos ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE inscripciones_equipo ENABLE ROW LEVEL SECURITY;
ALTER TABLE partidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE detalles_partido ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagos_abonos ENABLE ROW LEVEL SECURITY;

-- Políticas para 'perfiles'
CREATE POLICY "Lectura de perfiles es pública" ON perfiles FOR SELECT USING (true);
CREATE POLICY "Usuarios pueden actualizar su propio perfil" ON perfiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Permitir inserción de perfil propio" ON perfiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Políticas para 'jugadores_globales'
CREATE POLICY "Lectura de jugadores es pública" ON jugadores_globales FOR SELECT USING (true);
CREATE POLICY "Solo staff puede registrar o modificar jugadores" ON jugadores_globales FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Políticas para 'campeonatos'
CREATE POLICY "Lectura de campeonatos es pública" ON campeonatos FOR SELECT USING (true);
CREATE POLICY "Solo administradores y organizadores modifican campeonatos" ON campeonatos FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Políticas para 'equipos'
CREATE POLICY "Lectura de equipos es pública" ON equipos FOR SELECT USING (true);
CREATE POLICY "Solo organizadores modifican equipos" ON equipos FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Políticas para 'inscripciones_equipo'
CREATE POLICY "Lectura de inscripciones es pública" ON inscripciones_equipo FOR SELECT USING (true);
CREATE POLICY "Solo organizadores modifican inscripciones" ON inscripciones_equipo FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Políticas para 'partidos'
CREATE POLICY "Lectura de partidos es pública" ON partidos FOR SELECT USING (true);
CREATE POLICY "Solo organizadores crean o modifican partidos" ON partidos FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);
CREATE POLICY "Vocales asignados pueden actualizar el partido" ON partidos FOR UPDATE USING (
    vocal_id = auth.uid() AND estado IN ('programado', 'jugando')
);

-- Políticas para 'detalles_partido' (Estadísticas)
CREATE POLICY "Lectura de estadísticas es pública" ON detalles_partido FOR SELECT USING (true);
CREATE POLICY "Organizadores pueden modificar estadísticas" ON detalles_partido FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);
CREATE POLICY "Vocales asignados pueden insertar/modificar estadísticas" ON detalles_partido FOR ALL USING (
    EXISTS (
        SELECT 1 FROM partidos 
        WHERE partidos.id = detalles_partido.partido_id 
          AND partidos.vocal_id = auth.uid()
          AND partidos.estado IN ('programado', 'jugando')
    )
);

-- Políticas para 'pagos_abonos'
CREATE POLICY "Organizadores controlan todos los pagos" ON pagos_abonos FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);
CREATE POLICY "Jugadores y delegados pueden ver sus pagos" ON pagos_abonos FOR SELECT USING (true);

-- ==========================================
-- 6. TABLAS Y SEGURIDAD PARA EL PORTAL DE APUESTAS INDEPENDIENTE
-- ==========================================

-- Tabla de apostadores
CREATE TABLE apostadores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    perfil_id UUID REFERENCES perfiles(id) ON DELETE CASCADE, -- Si se registra con cuenta de usuario
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    balance_saldo DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    ganancias_totales DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    perdidas_totales DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de apuestas registradas
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

-- Tabla de recargas de saldo
CREATE TABLE recargas_saldo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apostador_id UUID REFERENCES apostadores(id) ON DELETE CASCADE,
    metodo VARCHAR(20) NOT NULL CHECK (metodo IN ('deposito', 'transferencia', 'tarjeta')),
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    comprobante_url TEXT, -- Imagen del recibo de depósito/transferencia
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobado', 'rechazado')),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS para las nuevas tablas
ALTER TABLE apostadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE apuestas_registradas ENABLE ROW LEVEL SECURITY;
ALTER TABLE recargas_saldo ENABLE ROW LEVEL SECURITY;

-- Políticas para 'apostadores'
CREATE POLICY "Apostadores leen su propia info" ON apostadores FOR SELECT USING (
    email = auth.email() OR perfil_id = auth.uid()
);
CREATE POLICY "Apostadores actualizan su saldo" ON apostadores FOR UPDATE USING (
    email = auth.email() OR perfil_id = auth.uid()
);
CREATE POLICY "Lectura y control de apostadores por organizador/admin" ON apostadores FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Políticas para 'apuestas_registradas'
CREATE POLICY "Apostadores leen sus apuestas" ON apuestas_registradas FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM apostadores 
        WHERE apostadores.id = apuestas_registradas.apostador_id 
          AND (apostadores.email = auth.email() OR apostadores.perfil_id = auth.uid())
    )
);
CREATE POLICY "Apostadores insertan sus apuestas" ON apuestas_registradas FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM apostadores 
        WHERE apostadores.id = apuestas_registradas.apostador_id 
          AND (apostadores.email = auth.email() OR apostadores.perfil_id = auth.uid())
    )
);
CREATE POLICY "Organizadores pueden auditar apuestas" ON apuestas_registradas FOR SELECT USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Políticas para 'recargas_saldo'
CREATE POLICY "Apostadores ven sus recargas" ON recargas_saldo FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM apostadores 
        WHERE apostadores.id = recargas_saldo.apostador_id 
          AND (apostadores.email = auth.email() OR apostadores.perfil_id = auth.uid())
    )
);
CREATE POLICY "Apostadores insertan recargas" ON recargas_saldo FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM apostadores 
        WHERE apostadores.id = recargas_saldo.apostador_id 
          AND (apostadores.email = auth.email() OR apostadores.perfil_id = auth.uid())
    )
);
CREATE POLICY "Organizadores auditan y aprueban recargas" ON recargas_saldo FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Habilitar RLS para auspiciantes
ALTER TABLE auspiciantes ENABLE ROW LEVEL SECURITY;

-- Políticas para 'auspiciantes'
CREATE POLICY "Lectura de auspiciantes es pública" ON auspiciantes FOR SELECT USING (true);
CREATE POLICY "Solo organizadores modifican auspiciantes" ON auspiciantes FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Habilitar RLS para categorias, sanciones_equipos, detalles_penales
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE sanciones_equipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE detalles_penales ENABLE ROW LEVEL SECURITY;

-- Políticas para 'categorias'
CREATE POLICY "Lectura de categorias es pública" ON categorias FOR SELECT USING (true);
CREATE POLICY "Solo organizadores modifican categorias" ON categorias FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Políticas para 'sanciones_equipos'
CREATE POLICY "Lectura de sanciones es pública" ON sanciones_equipos FOR SELECT USING (true);
CREATE POLICY "Solo organizadores modifican sanciones" ON sanciones_equipos FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador'))
);

-- Políticas para 'detalles_penales'
CREATE POLICY "Lectura de penales es pública" ON detalles_penales FOR SELECT USING (true);
CREATE POLICY "Solo vocales y organizadores modifican penales" ON detalles_penales FOR ALL USING (
    EXISTS (SELECT 1 FROM perfiles WHERE id = auth.uid() AND rol IN ('admin', 'organizador', 'vocal'))
);



