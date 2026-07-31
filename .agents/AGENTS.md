# Reglas de Negocio y Configuración de Campeonatos - QFutbol

Este documento contiene las reglas deportivas y financieras configurables del sistema QFutbol. Sirve como especificación funcional para los desarrolladores y el agente de IA.

---

## 1. Sistema de Tarjetas, Suspensiones y Multas

Las tarjetas recibidas por los jugadores generan multas financieras para el equipo y suspensiones automáticas.

### 1.1 Tarjetas Amarillas
*   **Acumulación:** Un jugador que acumule **5 tarjetas amarillas** (configurable por el organizador) en el transcurso del campeonato será suspendido automáticamente por **1 partido** (el siguiente inmediato).
*   **Multa:** Cada tarjeta amarilla tiene un costo de **$1.00 USD** (configurable por el organizador).
*   **Limpieza de Tarjetas:** Al finalizar la fase de grupos (y pasar a Playoffs/Eliminación Directa), las tarjetas amarillas acumuladas se limpian (quedan en 0), a menos que el jugador reciba la 5.ª amarilla en la última jornada, en cuyo caso debe cumplir la suspensión en el primer partido de Playoffs.
Se deberia dar una advertencia al organizador que x jugador tiene acumulado tarjetas para dar la opcion que lo habilite o no

### 1.2 Tarjetas Rojas
*   **Doble Amarilla (Roja Indirecta):**
    *   **Suspensión:** 1 partido de suspensión automática.
    *   **Multa:** **$2.50 USD** (configurable).
*   **Roja Directa:**
    *   **Suspensión:** Mínimo **1 partido** de suspensión automática. El organizador puede ampliar la suspensión a más partidos según el reporte de la vocal/árbitro (ej. agresión física = expulsión del torneo).
    *   **Multa:** **$5.00 USD** (configurable).

### 1.3 Control Financiero de Sanciones
*   Un equipo **no puede jugar su siguiente partido** si tiene multas pendientes de pago por concepto de tarjetas de la jornada anterior.
*   El sistema bloqueará la planilla del partido si el equipo rival o el propio equipo tiene deudas pendientes en el módulo financiero del campeonato.
Los pagos que se tomaria en cuenta:
Vocalia (configurable)
arbitraje (configurable)
Inscripcion (configurable) manejar abonos por cada partido. Administrador deberia configurar hasta que fecha tendran que tener pagado todo el campeonato
pago de tarjetas

---

## 2. Sistema de Puntuación y Tabla de Posiciones

### 2.1 Puntos por Partido
*   **Victoria:** 3 puntos.
*   **Empate:** 1 punto.
*   **Derrota:** 0 puntos.
*   **No presentación (Walkover / W.O.):** 0 puntos para el infractor, derrota por 0-3 decretada por reglamento. 3 puntos para el rival con marcador a favor de 3-0.

### 2.2 Criterios de Desempate (Orden de Prioridad)
En caso de igualdad de puntos en la tabla de posiciones, el sistema ordenará los equipos según:
1.  **Diferencia de Goles (DG):** Goles a favor menos goles en contra.
2.  **Goles a Favor (GF).**
3.  **Resultado Particular:** Puntos obtenidos en los enfrentamientos directos entre los equipos empatados.
4.  **Tabla de Juego Limpio (Fair Play):** Clasifica mejor el equipo con menos puntos de sanción:
    *   Tarjeta Amarilla: 1 punto de penalización.
    *   Doble Amarilla: 3 puntos de penalización.
    *   Roja Directa: 5 puntos de penalización.

---

## 3. Parámetros del Partido y Plantilla

*   **Modalidad de Juego:** Configurable por campeonato (Fútbol 7, Fútbol 9, Fútbol 11).
*   **Duración del Partido:** Configurable (ej. 2 tiempos de 25, 30 o 45 minutos).
*   **Cambios de Jugadores:** Ilimitados con reingreso (común en fútbol barrial para dar dinamismo) o limitados (ej. máximo 5 cambios por partido).
*   **Mínimo de Jugadores para iniciar:** 
    *   Fútbol 11: Mínimo 7 jugadores.
    *   Fútbol 7: Mínimo 5 jugadores.
    minimo de jugadores (configurable)
    *   Si no se alcanza el mínimo tras 15 minutos de espera, se decreta W.O. (derrota 0-3).

---

## 4. Gestión del Campeonato y Finanzas

*   **Inscripción por Equipo:** **$3.00 USD** por campeonato (cobro único de la plataforma al organizador).
*   **Garantía de Disciplina (Opcional):** El organizador puede configurar una garantía que el equipo paga al inicio del torneo y de donde se descuentan las multas por tarjetas.
*   **Auspiciantes:** La aplicación permitirá mostrar banners de patrocinadores del campeonato en las pantallas públicas de estadísticas del torneo (fuente de ingresos extra para el organizador).
Debe mostrar los auspiciantes en la imagen de generacion de calendarios, tabla de posiciones y en todas las imagenes que se creen del campeonato.

Debemos tener opcion de suspender una fecha o partidpo por fuerza mayor y ese partido deberia ser recupérable en la siguiente fecha o al final

Opcion de expulcion de un jugador por estado etilico con o sin sancion de acuerdo a las reglas de ese campeonato

preguntar al organizador si se puede inscribir jugadores luego de la fase de grupos o no. De acuerdo a eso, la opcion de incripcion de jugadores debe estar disponible o bloqueada hasta ser habilitado por el organizador

No olvidar el tema publicitario de promocion del campeonato en redes sociales. debemos generar una imagen para que puedan promocionarlo. En ella debe estar el resumen de todas las caracteristicas del campeonato como categorias, premios, costos, etc.

Debemos tener la opcion que los jugadores inscritos en ese campeonato, puedan acceder a revisar informacion de su equipo e informacion del campeonato como calendario, posiciones, etc. Pero no puedan realizar modificaciones en ninguna circunstancia.

Preguntar si se puede configurar el tema de abonos. me refiero a que el organizador pueda configurar hasta que fecha tienen los equipos para realizar el pago de su inscripcion. si no lo han hecho, el sistema debe mostrar una alerta o notificacion.

Debemos tener la opcion de pase de jugadores, con un costo configurable por el organizador

Tambien debemos generar un historial de equipos campeones por campeonato, incluyendo el escudo del equipo si tienen, una imagen de fondo del campeonato, fecha del campeonato, etc.

NO olvidar que un jugador puede participar en diferentes campeonatos pero no en 2 equipos del mismo campeonato.

Toda la informacion se manejara con nro de cedula

---

## 8. Módulo de Apuestas y Pronósticos Deportivos

El módulo de apuestas operará de forma independiente pero alimentado en tiempo real con la información de QFutbol. Se rige bajo las siguientes políticas:

### 8.1 Confianza y Seguridad
*   **Enfoque de Comunicación:** Se enfatizará que la plataforma de apuestas es **100% segura**, garantizando el cobro y pago de las ganancias y resguardando los saldos del usuario en todo momento.

### 8.2 Gestión de Cuentas y Recargas de Saldo
*   **Registro Obligatorio:** Todo apostador debe registrarse e iniciar sesión en el sistema para realizar pronósticos y llevar un control riguroso de su balance histórico de ganancias y pérdidas.
*   **Métodos de Recarga Admitidos:**
    *   *Depósito:* Registro manual del local de la red física.
    *   *Transferencia Bancaria:* Registro y subida del comprobante digital (aprobación manual).
    *   *Pago en Línea con Tarjeta:* Integración directa para recargas instantáneas con pasarelas (ej. Stripe o Payphone).

### 8.3 Algoritmo del Score del Equipo
*   **Score Base del Equipo:** El score de un equipo será el **promedio de los scores individuales (rating del campeonato)** de todos los jugadores que lo conforman.
*   **Nómina Activa (Score Dinámico):** Las cuotas de un partido se actualizarán y fijarán definitivamente en base a la **nómina de los jugadores seleccionados que efectivamente jugarán ese partido en particular** (plantilla registrada por el vocal antes de iniciar el partido). Si las estrellas o mejores jugadores de un equipo no constan en la nómina activa para el encuentro, el score del equipo bajará, y su cuota de victoria subirá de forma automática.

### 8.4 Margen de Ganancia de la Casa (Overround)
*   **Garantía de la Casa:** El algoritmo de cálculo de cuotas debe asegurar matemáticamente que la casa de apuestas obtenga un margen de ganancia en cada mercado (Local, Empate, Visitante).
*   **Matemática de Cuotas:** La suma de las probabilidades implícitas en las cuotas publicadas debe ser superior al 100% (usualmente un factor de **108% a 112%**). 
    *   *Fórmula:* $\text{Probabilidad Implícita} = \frac{1}{\text{Cuota}}$
    *   *Margen:* $\sum \frac{1}{\text{Cuota}} = 1.10$ (margen del 10% para la casa). Las cuotas finales se reducen de forma proporcional a la probabilidad real estimada para garantizar el retorno de la casa de apuestas independientemente del resultado del encuentro.


---

## 9. Monetización de la Plataforma, Auspiciantes y Aspectos Legales

### 9.1 Cobro de la Plataforma QFutbol (Bloqueo de Fixture)
*   **Costo de la Plataforma:** El organizador debe pagar a la administración de QFutbol una tarifa calculada como **$3.00 USD por cada equipo participante** inscrito en el campeonato.
*   **Bloqueo de Fixture:** El sistema **bloqueará de manera absoluta la opción de "Generar Fixture Automático"** hasta que el organizador registre el pago de esta tarifa por uso de la plataforma a la administración de QFutbol. Un mensaje claro informará el monto total calculado y los pasos para el depósito.

### 9.2 Registro de Datos Bancarios de la Liga
*   El organizador deberá registrar en la app su información bancaria (Banco, Tipo de Cuenta, Número de Cuenta, Titular). 
*   Esta información se presentará de forma automática a los delegados de los equipos cuando vayan a reportar transferencias de abono por inscripción o multas.

### 9.3 Gestión de Auspiciantes (Patrocinadores)
*   **Subida Móvil y Cámara:** El sistema permitirá subir el logotipo del auspiciante directamente seleccionando una imagen del almacenamiento del dispositivo móvil o tomando una foto en tiempo real con la cámara. No se requiere ingresar URL de página web.
*   **Prioridad del Auspiciante:** El organizador configurará un nivel de prioridad para cada patrocinador (Alto, Medio, Bajo) según el aporte realizado.
*   **Visualización Destacada:** Los auspiciantes con prioridad **Alta** se renderizarán con un diseño de mayor tamaño, bordes neón brillantes y ubicación privilegiada en las pantallas del campeonato, seguidos de los de prioridad Media y Baja.
*   **Eliminación de Banners:** Se elimina el formato de banner publicitario rectangular para simplificar la toma de fotos en la cancha.

### 9.4 Consentimiento Legal y Autorización de Datos
Al momento de inscribir un equipo, el delegado/organizador deberá aceptar obligatoriamente una leyenda legal de consentimiento con las siguientes cláusulas:
1.  **Autorización de Datos de Jugadores:** El equipo y su delegado declaran contar con la expresa autorización de sus jugadores para registrar su número de cédula, nombres, apellidos y fotos en la plataforma QFutbol, aceptando su uso para fines administrativos, estadísticos y de pronósticos dentro de la plataforma.
2.  **Cesión de Derechos de Imagen y Logos:** El equipo autoriza a QFutbol el uso de su nombre, escudo, colores y auspiciantes locales para fines publicitarios, promocionales y estadísticos del campeonato y de la plataforma en redes sociales u otros medios digitales.
