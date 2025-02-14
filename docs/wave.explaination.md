Looking at the provided file wave.gd, this appears to be a wave management system for a game, likely a tower defense game. While this file doesn't contain the main game run loop itself, it manages the state and lifecycle of enemy waves. Here's how the wave flow works:

# Wave States:

enum State {
    PENDING,    # Wave hasn't started yet
    SPAWNING,   # Creeps are currently being spawned
    SPAWNED,    # All creeps have been spawned
    FINISHED,   # Wave is complete
}

# Wave Initialization Flow:

# When a new wave is created, it:

    Determines the creep size (mass/normal/air/boss)

    Generates the creep race (undead/magic/nature/orc/humanoid)

    Determines armor type

    Generates the creep combination (what types and how many creeps will spawn)

    Calculates base HP and armor based on level and difficulty

    Handles special wave modifiers (like "Flock" which doubles the number of creeps)

# Creep Management:

    The wave keeps track of alive creeps in _alive_creep_list

    When creeps are added: add_alive_creep(creep)

    When creeps die/exit: _on_creep_tree_exited(creep)

    The wave is considered finished when all creeps have been spawned AND all creeps have been eliminated

# Wave Completion:

    When the last creep is removed and the wave state is "SPAWNED"

    The state changes to "FINISHED"

    Emits a "finished" signal that other parts of the game can listen for

    The wave system appears to be part of a larger game structure where:

    Waves are initialized with a level and difficulty

    Creeps are spawned according to the wave configuration

    The game tracks living creeps

    The wave completes when all creeps are eliminated

    This system supports various game features like:

    Different creep types and sizes

    Champion creeps that are stronger

    Special wave modifiers

    Difficulty scaling

    Bonus waves and challenge waves

    Different armor types affecting creep stats

    The code is designed to be deterministic using a synchronized random number generator ( Globals.synced_rng), which is important for maintaining consistency in multiplayer games or replays.