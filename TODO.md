## Project

# I.2.1 Creet Movement and Behavior : almost

•Reproduction: As long as at least one healthy Creet exists, new Creets spawn
periodically (e.g., every few seconds). Healthy Creets never die of old age.

# VI.2.2 Player Interaction : Done

# VI.2.3 Contamination System Done

# VI.2.4 Hospital Healing : Done

# VI.2.5 Special Creet Types :

TODO

# VI.2.6 Difficulty Progression

•Speed Increase: All Creets gradually accelerate over time, making the game
progressively harder.

•Balancing: You are free to adjust the rate of acceleration to create a good difficulty
curve. The game should:
  ◦Start easy, giving players time to learn mechanics
  ◦Gradually become more challenging
  ◦Eventually become overwhelming, leading to inevitable defeat

•Probability Adjustments: You may modify the specified probabilities (contami-
nation chance, berserk/mean chance) ONLY if necessary for game balance, without
fundamentally changing the game’s nature.

# VI.2.7 Game Over Condition

•The game ends when there are no healthy or living Creets remaining.

•Display a clear "GAME OVER" message when this condition is met.

•The message should be visible and unambiguous to the player.

# VI.2.8 Implementation Guidelines

•Color Scheme: Use distinct colors for:
  ◦Healthy Creets - X
  ◦Regular sick Creets - X
  ◦Berserk Creets
  ◦Mean Creets

•Performance: Ensure smooth animation even with multiple Creets on screen.
Each Creet should run in its own Lwt thread.

•User Feedback: Make it clear when a Creet is being dragged, when contamination
occurs, and when healing happens.
