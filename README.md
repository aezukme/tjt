# TJT Game Project

This is a Godot-based game project named "tjt". It appears to be a strategy or RPG-style game featuring units placed on a grid-based arena, with drag-and-drop mechanics for unit placement and movement.

## Description

The game is built using Godot Engine 4.5 and utilizes a tile-based system for gameplay. Key features include:

- **Arena System**: The main gameplay area is an arena with a tilemap, divided into play areas where units can be placed.
- **Unit Management**: Units are represented as draggable entities with stats, health/mana bars, and visual skins. Units can be moved between grids using drag-and-drop functionality.
- **Grid-Based Movement**: Units are placed on a grid system, with components handling tile occupation, movement validation, and positioning.
- **Interactive Elements**: Includes highlighting, rotation based on velocity during dragging, and outline effects for user feedback.
- **Input Handling**: Supports mouse-based selection and dragging, with cancel options via right-click or escape.

The project includes custom components for various functionalities like drag-and-drop, unit grids, play areas, highlighters, and movers.

## Project Structure

- **scenes/**: Contains scene files.
  - **arena/**: Main arena scene with tilemap and gameplay logic.
  - **unit/**: Unit scene template with stats, visuals, and behaviors.
- **components/**: Reusable GDScript components.
  - `drag_and_drop.gd`: Handles dragging units around the screen.
  - `unit_grid.gd`: Manages a grid of units, tracks occupation.
  - `unit_mover.gd`: Facilitates moving units between play areas.
  - `play_area.gd`: Represents playable areas on the tilemap.
  - `outline_highlighter.gd`: Adds highlight effects to units.
  - `tile_highlighter.gd`: Highlights tiles.
  - `velocity_based_rotation.gd`: Rotates units based on movement velocity.
- **data/**: Game data resources.
  - **units/**: Unit statistics and definitions (e.g., `bjorn.tres`).
- **asset/**: Game assets including sprites, tilesets, fonts, music, sound effects, and shaders.
  - Pixel art assets from 32rogues pack.
  - Tilemaps and autotiles.
  - Audio files for music and SFX.
- **addons/**: Godot plugins for development.
  - **codebot/**: AI-assisted coding plugin for the editor.
  - **sprite_frames_generator/**: Tool for generating sprite frames.
- **reference/**: Additional reference files and possibly older versions.

## Requirements

- Godot Engine (version 4.5.0 or later)
- GL Compatibility rendering mode (configured in project settings)

## How to Run

1. Clone or download the repository.
2. Open Godot Engine.
3. Import the project by selecting the `project.godot` file in the root directory.
4. Run the project from within Godot. The main scene is set to the arena.

## Configuration

- **Window Size**: Viewport 640x360, window override 1300x750.
- **Stretch Mode**: Viewport with integer scaling.
- **Rendering**: GL Compatibility, with pixel-perfect 2D snapping.
- **Inputs**:
  - "select": Left mouse button.
  - "cancel_drag": Right mouse button or Escape key.

## Assets

Assets are located in the `asset/` folder and include:

- **Sprites**: Character sprites, items, monsters, tiles from 32rogues asset pack.
- **Tilesets**: Autotiles, animated tiles, and tilemaps (e.g., water tiles).
- **Fonts**: m5x7.ttf for UI.
- **Audio**: Music and sound effects in respective folders.
- **Shaders**: Custom shaders for visual effects.
- **Themes**: UI themes.

## Plugins

The project uses two editor plugins:

- **CodeBot**: Provides AI assistance directly in the Godot editor for coding suggestions and help.
- **SpriteFrames Generator**: A tool to generate sprite frames from images.

## License

See LICENSE file for details.