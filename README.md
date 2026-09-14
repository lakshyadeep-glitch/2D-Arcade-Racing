# 2D Arcade Racing - Godot

[svg](https://github.com/YOUR-USERNAME/2D-Arcade-Racing#2d-arcade-racing---godot)

A fast-paced 2D arcade racing game made using Godot 4.7.2. Race along a long vertical track, compete against AI opponents, use boost pads, avoid obstacles, and try to reach the finish line in the best position possible.

---

## How to Play

[svg](https://github.com/YOUR-USERNAME/2D-Arcade-Racing#how-to-play)

Use the keyboard to control your car:

- **W / Up Arrow** - Accelerate
- **S / Down Arrow** - Brake
- **A / Left Arrow** - Steer Left
- **D / Right Arrow** - Steer Right
- **Shift** - Use Boost
- **R** - Restart the race after finishing

The goal is to reach the finish line before the other racers. Use the boost system carefully and avoid obstacles along the track.

---

## Features

[svg](https://github.com/YOUR-USERNAME/2D-Arcade-Racing#features)

- Player-controlled racing car
- Three AI opponents
- Long vertical racing track
- Custom road and grass textures
- Boost system
- Boost pads placed throughout the track
- Roadside barriers
- Track obstacles
- Position tracking
- Speed display
- Boost meter
- Race countdown
- Finish line
- Race timer
- Final race results
- Restart system
- Simple arcade-style gameplay

---

## Game Information

[svg](https://github.com/YOUR-USERNAME/2D-Arcade-Racing#game-information)

The race takes place on a long vertical track. The player starts near the bottom of the track and races upward toward the finish line.

The game includes three computer-controlled opponents that race alongside the player.

During the race, players can find boost pads that help increase their speed. Obstacles and barriers are placed around the track to make the race more challenging.

At the end of the race, the game displays the player's finishing position and race time.

---

## Controls

[svg](https://github.com/YOUR-USERNAME/2D-Arcade-Racing#controls)

| Key | Action |
|---|---|
| W / Up Arrow | Accelerate |
| S / Down Arrow | Brake |
| A / Left Arrow | Move Left |
| D / Right Arrow | Move Right |
| Shift | Boost |
| R | Restart |

---

## Requirements

[svg](https://github.com/YOUR-USERNAME/2D-Arcade-Racing#requirements)

- Godot 4.7.2 or a compatible Godot 4 version
- A computer capable of running a basic 2D Godot game
- Keyboard for controlling the player

---

## Run the Game

[svg](https://github.com/YOUR-USERNAME/2D-Arcade-Racing#run-the-game)

1. Download or clone this repository.
2. Open Godot 4.7.2.
3. Select **Import**.
4. Choose the `project.godot` file.
5. Open the project.
6. Press **F6** or **F5** to run the game.

---

## Project Structure

[svg](https://github.com/YOUR-USERNAME/2D-Arcade-Racing#project-structure)

```text
2D-Arcade-Racing/
│
├── assets/
│   ├── characters/
│   │   └── player_car.png
│   ├── environments/
│   ├── music/
│   ├── sounds/
│   └── texture/
│       ├── road.png
│       └── grass.png
│
├── levels/
│
├── scenes/
│   ├── main.tscn
│   ├── player.tscn
│   └── level_01.tscn
│
├── scripts/
│   ├── game.gd
│   └── player.gd
│
├── project.godot
├── README.md
└── .gitignore
