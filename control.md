# 📌 Control de Avance - QFutbol

> **Última actualización:** 4 de Noviembre, 2026  
> **Tecnología:** HTML5 + Vanilla JS + CSS + Neon PostgreSQL / Supabase  
> **Estado General:** 🟢 Prototipo avanzado funcional. Licencia de plataforma ajustada a $1.00 USD por equipo.

---

### 🎯 Siguiente Paso Inmediato (Retomar aquí)
- [ ] Subir cambios al repositorio de GitHub para sincronización y despliegue automático en Vercel.
- [ ] Módulo de Vocalía: Registro de inscripción de jugadores en nómina de partido diferenciando Titulares y Suplentes, carnet digital con foto/cédula para verificación previa a cambios.
- [ ] Restricción de sustituciones: solo jugadores registrados como suplentes en nómina pueden ingresar de cambio por un titular.

---

### ⏳ En Progreso / Revisión
- [x] Cobro de la plataforma ajustado a $1.00 USD por equipo participante y bloqueo absoluto de "Generar Fixture" y de vocalía hasta confirmación del administrador.
- [x] Cálculo de cuotas dinámicas de apuestas en `apuestas.html` basado en la nómina activa registrada por el vocal antes del partido.
- [x] Módulo de Vocalía de partido con soporte offline (`vocal.html`, `js/offline.js`) y sincronización al recuperar conexión.
- [x] Generación automática de afiches compartibles de fixture con logotipos de auspiciantes.
- [ ] Control de tarjetas amarillas (acumulación de 5 tarjetas = 1 partido de suspensión, multa $1.00 USD) y rojas directas/indirectas.

---

### 📋 Pendientes / Backlog
- [ ] Bloqueo de planilla si un equipo tiene deudas pendientes (vocalía, arbitraje, multas de tarjetas o cuota de inscripción).
- [ ] Módulo de registro bancario de la liga (Banco, tipo de cuenta, número, titular) para que los equipos reporten abonos.
- [ ] Sistema de pase de jugadores entre equipos con costo configurable.
- [ ] Historial de campeones por torneo (escudo, foto del campeonato, fechas).
- [ ] Registro de consentimiento legal obligatorio para delegados (autorización de datos por cédula y cesión de imagen).
- [ ] Opciones de suspensión de fecha/partido por fuerza mayor y expulsión por estado etílico.
- [ ] Analizar los horarios de forma que un jugador no tenga la misma hora de partido en diferentes campeonatos o a su vez dar prioridad de cambio de horario a equipos con mayor número de jugadores afectados.
- [ ] No permitir inscribir más jugadores para octavos de final en adelante.
- [ ] Para jugadores extranjeros: incluir foto de pasaporte y fecha de expiración del mismo.

---

### ✅ Completado
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
- Toda identificación de jugadores se maneja estrictamente con número de cédula.
- Un jugador puede participar en diferentes campeonatos, pero nunca en dos equipos del mismo campeonato.
- Las cuotas de apuestas por equipo se ajustan dinámicamente según los jugadores presentes en la nómina oficial del partido.
- Jugadores extranjeros: será necesario incluir foto de pasaporte y fecha de expiración del mismo.
- No se podrá inscribir más jugadores para octavos de final en adelante.
