# 📌 Control de Avance - QFutbol

> **Última actualización:** 4 de Noviembre, 2026  
> **Tecnología:** HTML5 + Vanilla JS + CSS + Neon PostgreSQL / Supabase  
> **Estado General:** 🟢 Nueva portada oficial implementada. Roles jerárquicos y reglas de registro y acceso configuradas.

---

### 🎯 Siguiente Paso Inmediato (Retomar aquí)
- [ ] Módulo de Vocalía: Registro de inscripción de jugadores en nómina de partido diferenciando Titulares y Suplentes, carnet digital con foto/cédula para verificación previa a cambios.
- [ ] Para jugadores extranjeros sera necesario incluir foto de pasaporte y fecha de expiracion del mismo.
- []  Crear la funcionalidad de carnet digital.
- Registrar tarjetas de los jugadores con los valores respectivos a cobrar en el mismo partido o en el siguiente partido.

- [ ] Restricción de sustituciones: solo jugadores registrados como suplentes en nómina pueden ingresar de cambio por un titular.
- [ ] No se podra inscribir mas jugadores para octavos de finales en adelante.
- [ ] Control de tarjetas amarillas (acumulación de 5 tarjetas = 1 partido de suspensión, multa $1.00 USD) y rojas directas/indirectas.

---

### ⏳ En Progreso / Revisión
- [x] Corrección integral del panel del organizador (`dashboard.html`): resolución de error de sintaxis en el renderizado de finanzas y restauración de la interactividad completa de las pestañas (Configuración, Categorías, Equipos, Vocales, Auspiciantes, Fixture y Finanzas) y botón "+ Registrar Nuevo Campeonato".
- [x] Persistencia y sincronización de inicio de sesión con Google / Gmail en `index.html`: registro automático en la tabla `perfiles` de Neon PostgreSQL, soporte para login directo con Google y acceso por formulario con detección de cuentas vinculadas y reseteo/asignación de contraseña.
- [x] Recuperación de contraseña: flujo completo de reseteo de clave por correo o cédula en la portada (`index.html`).
- [x] Pizarra multitorneo para el Organizador: selector rápido de campeonato activo en cabecera con KPIs dinámicos (equipos, jugadores activos, partidos, recaudación y multas por torneo).
- [x] Listado y gestión individual de campeonatos creados por el organizador con botón de activación directa en pizarra y edición de parámetros.
- [x] Filtrado cruzado por campeonato en nóminas de equipos, categorías, jornadas de fixture y finanzas.
- [x] Nueva portada interactiva (`index.html`) con logo oficial en cabecera y accesos directos: "Registrarse o Ingresar", "Buscar mis datos", "Buscar campeonato".
- [x] Mensaje central y hero destacado: "Crea, gestiona y administra tu campeonato tan solo por 1 dolar por equipo".
- [x] Estadísticas en vivo de campeonatos activos, equipos inscritos y jugadores registrados en la portada.
- [x] Tarjetas de características esenciales de la app y contador persistente de visitas en letras pequeñas al pie.
- [x] Regla universal: Obligatoriedad de registro para consultar información de torneos, buscar datos o crear campeonatos.
- [x] Regla del Administrador Único: Solo `soloescribeme@gmail.com` es administrador de la app, con opción exclusiva en su perfil para designar nuevos administradores de forma directa.
- [x] Regla de Organizador: Todo usuario que crea un campeonato adquiere automáticamente el perfil de Organizador.
- [x] Habilitación de perfiles por parte del Organizador: DT y Responsable de Equipo / Delegado con datos de contacto.
- [x] Habilitación de roles en plantilla: Jugador (default), Delegado, DT y Capitán al inscribir la nómina de jugadores.
- [x] Soporte de documentos para jugadores: Cédula de Identidad, DNI/Pasaporte para extranjeros, y "No dispone" para menores de edad en torneos escolares.

---

### 📋 Pendientes / Backlog
- [ ] Bloqueo de planilla si un equipo tiene deudas pendientes (vocalía, arbitraje, multas de tarjetas o cuota de inscripción).
- [ ] Módulo de registro bancario de la liga (Banco, tipo de cuenta, número, titular) para que los equipos reporten abonos.
- [ ] Sistema de pase de jugadores entre equipos con costo configurable.
- [ ] Historial de campeones por torneo (escudo, foto del campeonato, fechas).
- [ ] Registro de consentimiento legal obligatorio para delegados (autorización de datos por cédula y cesión de imagen).
- [ ] Opciones de suspensión de fecha/partido por fuerza mayor y expulsión por estado etílico.
- [ ] Analizar los horarios de forma que un jugador no tenga la misma hora de partido en diferentes campeonatos o a su vez dar prioridad de cambio de horario a equipos con mayor número de jugadores afectados.
- [ ] No permitir inscribir más jugadores para octavos de final en adelante a menos que el organizador habilite esta opcion.
- [ ] Para jugadores extranjeros: incluir foto de pasaporte y fecha de expiración del mismo.

---

### ✅ Completado
- [x] Nueva portada moderna de QFutbol (`index.html`) adaptada a los requerimientos del usuario.
- [x] Tarifa oficial de plataforma QFutbol establecida en $1.00 USD por equipo participante.
- [x] Panel de control del organizador (`dashboard.html`) con gestión de torneos y equipos.
- [x] Modal de reporte de pago de licencia y panel administrativo de verificación y desbloqueo de fixture.
- [x] Interfaz de vocalía digital para registro de goles, cambios y tarjetas en tiempo real (`vocal.html`).
- [x] Cuotas dinámicas de apuestas según nómina oficial en `apuestas.html`.
- [x] Algoritmo para generación de fixture automático (`js/fixture.js`).
- [x] Fichas y portal público de consulta para jugadores (`jugadores.html`, `portal_jugadores.html`).
- [x] Módulo independiente de apuestas deportivas (`apuestas.html`) con margen de ganancia de la casa (Overround 108%-112%).
- [x] Esquemas de base de datos definidos en `supabase/schema.sql` y `supabase/neon_schema.sql`.
- [x] Reglas de negocio detalladas en `.agents/AGENTS.md`.

---

### ⚠️ Notas Técnicas & Reglas del Negocio
- Toda identificación de jugadores se maneja con Cédula, DNI extranjero o registro escolar especial para menores de edad.
- Un jugador puede participar en diferentes campeonatos, pero nunca en dos equipos del mismo campeonato.
- Las cuotas de apuestas por equipo se ajustan dinámicamente según los jugadores presentes en la nómina oficial del partido.
- Jugadores extranjeros: será necesario incluir foto de pasaporte y fecha de expiración del mismo.
- No se podrá inscribir más jugadores para octavos de final en adelante a menos que el organizador habilite esta opcion 

