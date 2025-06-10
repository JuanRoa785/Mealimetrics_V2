# 🍽️ Mealimetrics

Bienvenido a **Mealimetrics**, una aplicación desarrollada en **Flutter con Dart**, diseñada para **mejorar la eficiencia operativa de un restaurante** ficticio. El sistema facilita la gestión de pedidos, roles del personal, turnos y menú desde dispositivos móviles, digitalizando así las tareas cotidianas de meseros, chefs y gerentes.

## 🎥 Demo en Video

🔗 [Mealimetrics en Ejecución](https://www.youtube.com/watch?v=GM0ybeGToJE)

---

## 📱 Funcionalidades Principales

- 📝 **Toma digital de pedidos** por parte de los meseros desde sus celulares.
- 👨‍🍳 **Visualización y control de pedidos** por parte del chef.
- 🔔 **Notificaciones automáticas** cuando un pedido está listo para ser recogido.
- 💵 **Control de pagos de pedidos** por parte de los meseros.
- 🧑‍💼 **Gestión de turnos** de trabajo para empleados (meseros o cocina) por parte del gerente.
- 📋 **Administración del menú**, incluyendo:
  - Creación y eliminación de platillos.
  - Gestión de los especiales disponibles.
  - CRUD de los componentes del almuerzo (proteína, principio, bebida y sopa opcional).

---

## 🧑‍🤝‍🧑 Roles del Sistema

| Rol     | Descripción                                                                  |
|---------|------------------------------------------------------------------------------|
| **Mesero** | Toma pedidos, revisa notificaciones, gestiona estado del pedido.          |
| **Chef**   | Consulta los pedidos realizados y notifica cuando estén emplatados.       |
| **Gerente**| Asigna turnos, gestiona el menú y los componentes del restaurante.        |

---

## 🧰 Tecnologías Utilizadas

- **Frontend móvil**: Flutter (Dart)
- **Backend como servicio**: [Supabase](https://supabase.com/) – base de datos PostgreSQL, autenticación y almacenamiento en la nube.
- **Base de datos**: PostgreSQL gestionada en Supabase.
- **Notificaciones internas**: Comunicación entre roles en tiempo real.
- **Gestión del menú**: Modular, con componentes reutilizables.

---

## 📦 Estructura del Pedido

Un almuerzo puede componerse de:

- 🥩 **Proteína**
- 🍚 **Principio**
- 🥤 **Bebida**
- 🥣 **Sopa** *(opcional)*

---

## 🚀 Instalación y Uso

1. Instalar Flutter en tu equipo
2. Clonar el Repositorio
   ```bash
   git clone https://github.com/JuanRoa785/mealimetrics.git
3. Instalar las dependencias adecuadas:
   ```bash
    flutter pub get
4. Seleccionar el emulador o el dispositivo fisico en el que se va a ejecutar el software
5. Ejecutar el software con:
   ```bash
   flutter run
