# 📌 Control de Avance - QFutbol

> **Última actualización:** 8 de Noviembre, 2026 (Sesión Vespertina)  
> **Tecnología:** HTML5 + Vanilla JS + CSS + Neon PostgreSQL / Supabase  
> **Estado General:** 🟢 Pizarra del Delegado implementada, Base Universal de Jugadores con autollenado por Cédula/DNI, actualización automática de abonos en tiempo real, ficha de equipo con bloqueo pre/post inicio de torneo, formulario de campeonato oculto por defecto y sincronización en Neon PostgreSQL. Desplegado en Vercel.

---

### 🚀 Resumen del Trabajo Realizado Recientemente (8 de Noviembre, 2026 - Sesión Vespertina)

#### 1. Formulario de Campeonato Oculto por Defecto (`dashboard.html`)
- Se corrigió la inicialización del contenedor `#container-form-campeonato`: ahora permanece oculto (`display: none`) de manera predeterminada incluso cuando no hay torneos registrados.
- Se despliega únicamente cuando el usuario hace clic expresamente en los botones **`+ Registrar Nuevo Campeonato`** o **`+ Registrar Mi Primer Campeonato`**, con desplazamiento suave y enfoque automático al campo del nombre.

#### 2. Actualización Instantánea de Abonos sin Recargar la Página (`dashboard.html` y `js/app.js`)
- **Corrección en `calcularFinanzasEquipo` (`js/app.js`):** Se resolvió un error de *Temporal Dead Zone* (TDZ) en el que `eq` se referenciaba antes de su inicialización (`const eq = ...`), lo que interrumpía el recálculo dinámico de las finanzas.
- **Persistencia en Neon DB y Sincronización en Vivo:** Al registrar un abono (`abono-form`), el sistema inserta el registro en `pagos_abonos`, actualiza las columnas `monto_pagado_inscripcion` o `monto_garantia_pagado` en la tabla `equipos` de Neon DB y refresca instantáneamente las tablas de equipos, desglose de finanzas y métricas KPI sin necesidad de refrescar el navegador.

#### 3. Ficha de Equipo, Delegado Autorizado y Pregunta de Mismo Responsable (`dashboard.html`)
- **Pregunta Automatizada en Registro y Edición:** Se incorporó el selector:  
  `¿El responsable del equipo es la misma persona que inscribirá a los jugadores?` (marcado por defecto).  
  - Al estar marcado, sincroniza automáticamente el nombre, cédula, teléfono y correo del responsable de contacto para el rol de delegado.
  - Al desmarcarlo, despliega campos independientes para registrar al **Delegado Autorizado de Inscripción**.
- **Ficha del Equipo (`#modal-actualizar-equipo`):** Nuevo modal accesible desde el botón **`Ficha`** en la lista de equipos.
- **Regla de Negocio Pre / Post Inicio de Campeonato:**
  - **Antes de iniciar el campeonato:** Todos los datos del equipo (Nombre, Categoría, Curso, Logo, DT, Contacto y Delegado) son 100% editables.
  - **Una vez iniciado el campeonato:** Se bloquean los datos estructurales del club (Nombre, Categoría, Logo) con una alerta de normativa oficial, permitiendo actualizar únicamente los datos del **Director Técnico (DT)**, el **Delegado de Inscripciones** y la nómina de **Jugadores**.

#### 4. Pizarra del Delegado: Campeonatos y Equipos Autorizados (`dashboard.html` e `index.html`)
- Se agregó el perfil **`Mis Equipos / Delegado`** en la barra superior y la pestaña `#tab-delegado`.
- Al iniciar sesión con un correo registrado como delegado autorizado o contacto de un equipo, el sistema filtra y presenta exclusivamente los campeonatos y los equipos donde el usuario tiene potestad de inscripción.
- Dentro de cada campeonato, el delegado visualiza el estado del torneo (fase previa o iniciado), el número de jugadores inscritos y accesos directos para:
  - **`⚽ Registrar Jugadores`** (abre la gestión de nómina).
  - **`✏️ Ficha Club`** (abre la ficha del equipo).
- En la portada (`index.html`), se adaptó la barra de bienvenida y la redirección automática para usuarios con rol `delegado`.

#### 5. Base de Datos Universal de Jugadores (`dashboard.html` y Neon PostgreSQL)
- **Modal de Gestión de Jugadores (`#modal-gestionar-jugadores-equipo`):** Permite inscribir jugadores con consulta directa a la Base Universal de QFutbol (`jugadores_globales`).
- **Autollenado y Consulta Universal:** Al ingresar la Cédula o DNI:
  - **Si el jugador ya existe en la base universal:** Carga de inmediato sus nombres, apellidos, foto y score histórico en modo lectura, sin requerir que el delegado vuelva a subirlos o escribirlos.
  - **Si es un jugador nuevo:** Permite registrar sus datos por primera vez y los almacena en la Base Universal para cualquier campeonato presente o futuro.
- **Reglas de Torneo:** Valida que el dorsal no esté duplicado en el club y que el jugador no participe en dos equipos del mismo campeonato.

#### 6. Esquema de Base de Datos Actualizado en Neon PostgreSQL
- Se agregaron las columnas requeridas mediante `ALTER TABLE`:
  - `equipos`: `contacto_cedula`, `contacto_email`, `delegado_inscripcion_nombre`, `delegado_inscripcion_cedula`, `delegado_inscripcion_telefono`, `delegado_inscripcion_email`, `mismo_responsable_inscripcion`, `dt_nombre`, `dt_cedula`, `dt_telefono`, `curso_paralelo`.
  - `inscripciones_equipo`: `rol_en_equipo`.
  - `pagos_abonos`: `campeonato_id`.

---

### 🚀 Resumen del Trabajo Realizado Anteriormente (8 de Noviembre, 2026 - Sesión Matutina)

#### 1. Rediseño Responsivo del Modal de Autenticación y Registro (`index.html` y `css/styles.css`)
- **Diagnóstico:** En pantallas medianas, portátiles o dispositivos móviles, el formulario de registro excedía la altura visible de la ventana (*viewport*), ocultando la cabecera y el botón de cerrar (`✕`), impidiendo cancelar o completar el registro fluidamente.
- **Solución y Mejoras:**
  - **Cabecera Fija (*Sticky Header*):** Se rediseñó el contenedor `#modal-auth` para tener una cabecera anclada en la parte superior que siempre muestra el título y el botón `✕ Cerrar` visible en todo momento.
  - **Scroll Suave y Adaptativo:** Se configuró el cuerpo del modal con `overflow-y: auto`, flexbox responsivo y límites `max-height: calc(100vh - 40px)` y `max-width: 500px`.
  - **Cierre por Entorno y Teclado:** Se habilitó el cierre automático haciendo clic fuera del modal (*backdrop click*) y mediante la tecla `Escape`.
  - **Media Query para Pantallas Compactas:** Ajuste automático de padding y alineación superior (`align-items: flex-start`) en pantallas con altura menor a 780px.

#### 2. Flujo Seguro de Recuperación de Contraseña por Correo (`index.html`)
- **Diagnóstico:** Anteriormente se permitía sobrescribir la contraseña directamente ingresando solo el correo o cédula, exponiendo los perfiles a ataques de suplantación o manipulación no autorizada.
- **Solución y Mejoras (Proceso en 2 Pasos):**
  - **Paso 1 (Solicitud de Código):** El usuario ingresa su correo registrado. El sistema consulta Neon PostgreSQL (`perfiles`); si el usuario existe, genera un **código de seguridad criptográfico de 6 dígitos** con expiración de 15 minutos y lo almacena junto al timestamp en `perfiles.reset_token` y `perfiles.reset_token_expires`.
  - **Paso 2 (Verificación y Cambio):** Muestra el código generado, botón directo **"Abrir Mi Correo"** (`mailto:`) y botón **"Copiar Enlace Seguro"** con el token (`?action=reset_password&email=...&token=...`).
  - **Doble Validación:** Solo tras ingresar el código válido de 6 dígitos (no expirado) se actualiza la contraseña de forma segura en Neon DB y se anula el token utilizado.
  - **Soporte de Enlace Directo:** Si el usuario accede mediante el enlace recibido en su correo, la aplicación detecta automáticamente los parámetros `action=reset_password`, precarga el correo, valida el token y lo lleva directo al paso de cambio de contraseña.

#### 3. Corrección del Motor de Consultas Neon PostgreSQL (`js/app.js`)
- **Diagnóstico:** El endpoint HTTP `/sql` de Neon (`https://ep-falling-band-acw0oe8s.sa-east-1.aws.neon.tech/sql`) no acepta parámetros separados en formato `{ query: "...", params: [...] }` con placeholders `$1, $2`, respondiendo con error HTTP 400 (`syntax error at or near ","`). Esto causaba que los registros nuevos (`dbInsertRow`) o actualizaciones fallaran silenciosamente y recurrieran al mock local.
- **Solución:**
  - Se implementó un formateador seguro en `neonQuery` que interpola y escapa de forma limpia y tipada los parámetros antes de enviarlos a Neon DB.
  - Se crearon las columnas `reset_token` (VARCHAR 255) y `reset_token_expires` (TIMESTAMPTZ) en la tabla `perfiles` de Neon DB.

#### 4. Diagnóstico del Correo `fferrimaster@gmail.com`
- Al verificar la tabla `perfiles` en Neon PostgreSQL, se comprobó que dicho correo no se encontraba registrado aún en la base de datos de producción (la tabla únicamente contenía dos registros previos de prueba con correos nulos). Por esta razón, el sistema informaba correctamente que el correo no existía. Con el nuevo modal accesible y el motor de inserción reparado, la cuenta ya puede registrarse sin ningún obstáculo.

---

### 🚀 Resumen del Trabajo Realizado Previamente (4 de Noviembre, 2026)

#### 1. Corrección Integral de Botones y Pestañas en el Panel de Organizador (`dashboard.html`)
- **Diagnóstico:** Se detectó un error de sintaxis (`SyntaxError: Unexpected token 'class'`) originado por un template literal HTML no cerrado en la fila de desglose de finanzas (`renderizarFinanzas()`). Al fallar el parseo del script en el navegador, todas las funciones globales (`switchTab`, `mostrarFormularioNuevoCampeonato`, etc.) quedaban como `undefined`.
- **Solución y Mejoras:**
  - Se corrigió el cierre del template literal HTML.
  - Se restauró la navegación completa de subpestañas: **Configuración**, **Categorías**, **Equipos**, **Vocales Autorizados**, **Auspiciantes**, **Fixture / Jornadas** y **Finanzas y Abonos**.
  - Se potenció el botón **`+ Registrar Nuevo Campeonato`** (`mostrarFormularioNuevoCampeonato()`): ahora conmuta automáticamente a la pestaña de configuración, despliega el contenedor `#container-form-campeonato`, ejecuta un desplazamiento suave (*smooth scroll*) y enfoca el campo del nombre del torneo.
  - Verificación exitosa mediante pruebas automatizadas con Microsoft Edge headless y Chrome DevTools Protocol (CDP).

#### 2. Sincronización y Persistencia de Cuentas Google / Gmail (`index.html`)
- **Diagnóstico:** Al autenticarse con "Continuar con Google", el sistema solo creaba un objeto temporal en `localStorage`/`sessionStorage` sin registrarlo en la tabla `perfiles` de Neon PostgreSQL. Por ello, al intentar ingresar con correo y clave tradicional, el sistema indicaba que el correo no existía.
- **Solución y Mejoras:**
  - `iniciarAuthSocial`: Ahora consulta la tabla `perfiles` en Neon DB; si el usuario no existe, solicita sus nombres e inserta inmediatamente el nuevo registro con rol `organizador`.
  - `procesarLogin`: Ahora detecta si una cuenta fue creada con Google sin contraseña previa, ofreciendo **acceso directo con un clic** o derivación a la asignación de contraseña manual.
  - Flujo de `¿Olvidaste tu contraseña?` (`procesarResetPassword`): Permite a cualquier usuario con cuenta de Gmail/Google o tradicional asignar o restablecer su clave con persistencia en Neon DB.

#### 3. Pizarra Multitorneo para el Organizador (`dashboard.html` y `js/app.js`)
- Selector dinámico de campeonato en cabecera para organizadores que manejan múltiples torneos activos.
- 5 KPIs en vivo filtrados por el torneo seleccionado: **Equipos Inscritos**, **Jugadores Activos**, **Partidos Totales**, **Inscripciones y Abonos Recaudados** y **Multas/Saldos Pendientes**.
- Filtrado por `campeonato_id` en las finanzas de equipos (`calcularFinanzasEquipo`), nóminas, categorías y calendarios.
- Listado de torneos creados con botón de activación en pizarra y edición de parámetros.

#### 4. Recuperación de Clave en Portada (`index.html`)
- Pestaña `¿Olvidaste tu contraseña?` en el modal de autenticación.
- Validación de identidad por correo electrónico o número de cédula.
- Actualización directa de credenciales en la base de datos Neon PostgreSQL.

---

### 🎯 Siguiente Paso Inmediato (Retomar aquí)
- [ ] **Módulo de Vocalía (`vocal.html`):**
  - [ ] Registro de inscripción de jugadores en nómina de partido diferenciando **Titulares** y **Suplentes**.
  - [ ] Restricción de sustituciones: solo jugadores registrados como suplentes en nómina pueden ingresar de cambio por un titular.
  - [ ] Registro de tarjetas con valores de multa a cobrar en el mismo partido o en el siguiente.
  - [ ] Control de acumulación de tarjetas (5 amarillas = 1 partido de suspensión, multa $1.00 USD) y rojas directas/indirectas.
- [ ] **Carnet Digital de Jugadores:**
  - [ ] Funcionalidad para generar y visualizar carnet digital oficial con foto, cédula/DNI y datos del equipo para verificación previa a los partidos.
- [ ] **Requisitos de Jugadores Extranjeros:**
  - [ ] Formulario de inscripción con campos obligatorios para foto del pasaporte y fecha de expiración del mismo.
- [ ] **Restricción de Fases Finales:**
  - [ ] Bloqueo de inscripción de nuevos jugadores a partir de octavos de final en adelante, a menos que el organizador lo habilite expresamente.

---

### 📋 Pendientes / Backlog
- [ ] Bloqueo de planilla si un equipo tiene deudas pendientes (vocalía, arbitraje, multas de tarjetas o cuota de inscripción).
- [ ] Módulo de registro bancario de la liga (Banco, tipo de cuenta, número, titular) para que los equipos reporten abonos.
- [ ] Sistema de pase de jugadores entre equipos con costo configurable.
- [ ] Historial de campeones por torneo (escudo, foto del campeonato, fechas).
- [ ] Registro de consentimiento legal obligatorio para delegados (autorización de datos por cédula y cesión de imagen).
- [ ] Opciones de suspensión de fecha/partido por fuerza mayor y expulsión por estado etílico.
- [ ] Analizador de cruces de horarios para evitar que un jugador tenga partidos simultáneos en distintos campeonatos o dar prioridad de cambio a equipos más afectados.

---

### ✅ Completado Previamente
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
- No se podrá inscribir más jugadores para octavos de final en adelante a menos que el organizador habilite esta opción.
