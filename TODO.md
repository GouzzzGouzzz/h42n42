## Project

# I.2.1 Creet Movement and Behavior : Done

# VI.2.2 Player Interaction : Done

# VI.2.3 Contamination System Done

# VI.2.4 Hospital Healing : Done

# VI.2.5 Special Creet Types : Done

# VI.2.6 Difficulty Progression

•Speed Increase: All Creets gradually accelerate over time, making the game
progressively harder.

•Balancing: You are free to adjust the rate of acceleration to create a good difficulty
curve. The game should:
  ◦Start easy, giving players time to learn mechanics
  ◦Gradually become more challenging
  ◦Eventually become overwhelming, leading to inevitable defeat

# VI.2.7 Game Over Condition : Done

# VI.2.8 Implementation Guidelines

•Performance: Ensure smooth animation even with multiple Creets on screen.
Each Creet should run in its own Lwt thread.

# To note

The game ends when there are no healthy or living Creets remaining

The game ends when all Creets are either dead or contaminated with no healthy
Creets remaining
