# Videojuego en Godot (Proyecto Descontinuado)

Este repositorio contiene el proyecto de un videojuego desarrollado como un experimento personal para explorar y aprender a usar el motor de videojuegos [Godot Engine](https://godotengine.org/).
Aunque este proyecto no se encuentra en desarrollo activo, fue una experiencia valiosa que me ayudó a comprender los fundamentos de Godot.

## En que consistia el juego

Basicamente consistia en un juego 2D estilo **Binding of Isac** o **Enter the Gungeon**, en el que empezarias en un piso con salas generadas con tamaño al azar, con una cantidad de enemigos al azar dentro de cada una de ellas, hasta llegar a la sala final y pasar al siguiente piso.

## Codigo Interesante

Lo unico que llegue a tener acabado es la generacion de los pisos, que mediante un manager creas las salas y las entidades/enemigos de un piso dentro de una pool de salas y enemigos predefinidos.
Todo este codigo seria flexible para poder modificar:
- Rango de salas que pueden aparecer en un piso
- Dimensiones del piso (en salas)
- Numero de enemigos que pueden salir en una sala
- Salas especiales para que minimo aparezca una de ellas en un piso (En este caso solo estaria hecha la sala inicial y final)
- Podrias añadir mas salas predefinidas para incluirlas a la generacion...

## Arte del proyecto

En cuanto a los sprites fueron descargados desde [itch.io](https://itch.io/) de este [autor](https://snowhex.itch.io/). 

Pero luego hice unos propios para sustituirlos y que se adaptase al estilo de juego que queria hacer los cuales no llegaron a implementarse correctamente.

## Descripción

El juego es un proyecto pequeño que combina mecánicas simples para probar diferentes aspectos de Godot, como:
- Creación de escenas y nodos.
- Implementación de físicas.
- Programación en GDScript.
- Manejo de inputs.
- Diseño de interfaces básicas.

## Estado del Proyecto

Este proyecto está **descontinuado**. Aunque logré cumplir mis objetivos iniciales con este proyecto, he decidido dejarlo de lado para enfocarme en un nuevo videojuego más ambicioso. Este nuevo proyecto se está desarrollando con un equipo de colaboradores, con el objetivo de crear algo más profesional.

Si quieres ver o utilizar el código de este proyecto como referencia o aprendizaje, siéntete libre de hacerlo.

## Requisitos

Para abrir y ejecutar este proyecto necesitas:
- [Godot Engine](https://godotengine.org/) (versión 4.3 o superior).

## Instrucciones de Uso

1. Clona este repositorio en tu equipo:
   ```bash
   git clone https://github.com/tu-usuario/tu-repositorio.git
   ```
2. Abre el proyecto desde el editor de Godot.
3. Ejecuta el juego presionando el botón de "Play" en el editor.
