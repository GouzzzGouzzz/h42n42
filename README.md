# H42N42

H42N42 is a browser game written in OCaml with Ocsigen/Eliom.
Protect the Creets from a virus spreading from a toxic river, and keep as many alive as possible.

# Installation

## Requirements

- Docker
- Docker Compose

The Docker setup installs the project dependencies.

Run

```
make
```

or

```
docker-compose up --build
```

Open http://localhost:8080 in your browser to play !

## More commands

Project commands:
```
make        # Build (docker-compose up --build)
make clean  # Down
make fclean # Remove image and container
make re     # Clean and rebuild
```

# Informations

Creets color are :
- Green for `Healthy`
- Yellow for `Sick`
- Magenta for `Mean`
- Blue for `Berserk`

The toxic river is located at the top of the screen, the hospital is at the bottom.

## Game rules

- Creets move around the game area, bounce off its edges and periodically change direction.
- New Creets appear over time.
- Touching the toxic river infects a Creet.
- Sick Creets move 15% slower and have a 2% chance of infecting a healthy Creet on each contact iteration.
- Click and drag a sick Creet into the hospital to heal it. Dragging protects a Creet while it is held.
- Berserk Creets grow over time and die when they reach four times their original diameter.
- Mean Creets shrink, chase the nearest healthy Creet and die after one minute.
- Special Creets cannot be dragged or healed. A Creet cannot be both berserk and mean.
- Difficulty increases as the game progresses. The game ends when no Creets remain alive.

# Informations

The `Game over` part of the subject is not very clear.

```
VI.1.1 Game Objective
[...]
The game ends when all Creets are either dead or contaminated with no healthy
Creets remaining.
```

```
VI.2.7 Game Over Condition

The game ends when there are no healthy or living Creets remaining.
```

A `Sick creet` is still considered *``alive``* and can be *``healed``*  if dragged to the hospital.

Since new healthy creets can only spawn when at least one healthy creet remains, the game is over as soon as there is no healthy creet left.
