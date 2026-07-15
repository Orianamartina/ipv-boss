# Pantalla de ingreso de nombre — investigación (en pausa)

Objetivo: pantalla nueva, con joystick, que va **después de MainMenu y antes de PatternMenu**,
para que el jugador escriba su nombre con una grilla de letras navegable.

## Ya existe en el código (aprovechar, no rehacer)

- **`Global.gd`** ya tiene el scaffolding: `var player_name: String`, `set_player_name(new_name)`,
  señal `player_name_changed`. Todavía no se usa en ningún lado — es justo para esto.
- **Flujo actual**: `UI/main_menu.gd:58` hace
  `get_tree().change_scene_to_file("res://UI/PatternMenu.tscn")` al presionar Start/"enter".
  Hay que insertar la nueva escena ahí en el medio.
  (Ojo: `UI/result_scene.gd:143` también apunta a PatternMenu, pero es el flujo de "Nueva prenda"
  al reintentar, no el flujo inicial — no tocar ese.)
- **Input actions disponibles** (`project.godot`): `move_up/move_down/move_left/move_right`
  (WASD + stick izquierdo, deadzone 0.2) y `enter` (Enter + botón 0 del joystick). No hace falta
  crear acciones nuevas: "BORRAR"/"ESPACIO"/"LISTO" pueden ser tiles más en la grilla, seleccionables
  con "enter" como cualquier letra.

## Patrones de navegación ya usados en el proyecto

- `pattern_menu.gd` / `fabric_menu.gd`: navegación 1D con
  `Input.is_action_just_pressed("move_left"/"move_right")` — simple y confiable.
- `result_panel.gd`: navegación 2D (4 botones) leyendo el eje crudo con `get_axis` +
  umbrales engage/release (0.5 / 0.2) y flags `horizontal_locked`/`vertical_locked`.
- **Recomendación para la grilla de letras**: usar `is_action_just_pressed` en las 4 direcciones
  (como pattern/fabric menu) pero con aritmética de fila/columna sobre un array 2D de botones,
  en vez de leer ejes crudos — evita la clase de bug que encontramos en fabric_menu (ver abajo).

## Bugs encontrados y ya arreglados esta sesión (contexto, no relacionado directo pero relevante al patrón a seguir)

- En `fabric_menu.gd` el sonido de selección solo sonaba si el código custom de movimiento
  llamaba `select_sound.play()` — con flechas de teclado, Godot mueve el foco solo con su
  navegación nativa (`ui_left/ui_right`, default del engine) y nunca pasaba por ese código, por
  eso no sonaba. Fix aplicado: conectar `focus_entered` de cada botón a `select_sound.play`, así
  suena sin importar qué disparó el cambio de foco. **Usar el mismo approach en la grilla de
  letras** (conectar `focus_entered` en cada tile, no reproducir sonido manualmente en la función
  de movimiento).
- También en `fabric_menu.gd`, `AXIS_ENGAGE_THRESHOLD` estaba en `1.2`, imposible de alcanzar
  porque `get_axis` nunca pasa de `1.0` (quedó en 0.5/0.2, como en `result_panel.gd`). Motivo más
  para preferir `is_action_just_pressed` en vez de umbrales de eje crudo en código nuevo.

## Componente de botón reutilizable

- `UI/Button.tscn` + `UI/button.gd`: extiende `Button`, agrega hover/press (cambios de `modulate`)
  y `font_size` exportado. Tamaño default 280x108 con textura `button-bg.png` — grande para una
  tecla individual de una grilla de 26+ letras. Para el ejemplo, lo más simple es usar `Button`
  planos de Godot (sin arte) para cada tecla, y restylear después con arte real si se aprueba el
  diseño. Pendiente de confirmar con el usuario.

## Sonidos ya disponibles para reusar (no hace falta crear nada nuevo)

- `Assets/audio/pattern-button-select.mp3` / `fabric-button-select.mp3` — sonido de foco/selección
  en los otros menús.
- `Assets/audio/computer-mouse-click.wav` — sonido de click/confirmar (MainMenu, PatternMenu,
  FabricMenu, ResultPanel).
- `Assets/audio/points-milestone.mp3`, `Assets/audio/level-passed.mp3`, `Assets/audio/shine-4.wav`
  — usados en ResultScene, no aplican directamente acá.

## Entorno

- No hay `godot`/`godot4` en el PATH de esta máquina, solo `/Applications/Godot.app`. No se puede
  correr/verificar la escena headless desde la terminal — probar siempre abriendo el proyecto en
  el editor de Godot.

## Plan de escena (borrador, no implementado todavía)

- Nueva escena `UI/NameInput.tscn` + script `UI/name_input.gd` (Control).
- Título ("Ingresá tu nombre"), label de preview del nombre tipeado (con cursor tipo
  `NOMBRE: ABC_`), `GridContainer` con botones A-Z + "ESPACIO" + "BORRAR" + "LISTO".
- Navegación de grilla con `move_up/down/left/right` (`is_action_just_pressed`) + aritmética de
  fila/columna, clamp a los bordes de la grilla.
- Cada tile conecta `focus_entered` → sonido de selección.
- "enter" sobre el tile con foco: letra → append al string; "ESPACIO" → append " ";
  "BORRAR" → pop del último char; "LISTO" → (guard: nombre no vacío) →
  `Global.set_player_name(...)` → sonido de click → `change_scene_to_file("res://UI/PatternMenu.tscn")`.
- `UI/main_menu.gd:58` pasa a apuntar a `res://UI/NameInput.tscn` en vez de PatternMenu directo.

## Preguntas abiertas para el usuario (retomar acá)

1. ¿Botones planos de Godot para las teclas, o arte custom tipo `Button.tscn`/`fabric_button.gd`?
2. ¿Incluir letras en español (Ñ, acentos) ya que el juego está en español, o solo A-Z?
3. ¿Largo máximo de nombre?
4. ¿Qué sonido específico para tecla vs. confirmar ("LISTO")?
