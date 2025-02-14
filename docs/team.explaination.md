Looking at the team.gd file, I can explain the game's run flow:

# Initial Setup:

    The Team class represents one or more players in either singleplayer or multiplayer

    Each team starts with 100 lives and level 1

    Players are created and added to the team via create_player()

# Wave System:

    func start_first_wave():
        _start_wave()

    func start_next_wave():
        _level += 1
        level_changed.emit()
        _start_wave()

    The game progresses through waves of enemies

    Each wave corresponds to a level

    When a wave starts, all players in the team begin that wave simultaneously

# Wave Completion Flow:

    func _on_player_wave_finished(level: int):
        # Checks if all players finished the current wave
        var all_players_finished: bool = true
        for player in _player_list:
            if !player.current_wave_is_finished():
                all_players_finished = false

    The game tracks when players complete waves

    If all players finish the current wave, the next wave timer starts

    Default time between waves is defined by Constants.TIME_BETWEEN_WAVES

# Auto-spawn System:

    There's an automatic wave spawn system that varies based on difficulty

    For Extreme difficulty, auto-spawn timing is calculated based on level:

    Starts at 25 seconds for level 1

    Increases up to 40 seconds

    Then gradually decreases for higher levels

    Players can also set custom auto-spawn times

# Victory/Defeat Conditions:

    # Victory
    if team_achieved_victory:
        _do_game_win()

    # Defeat
    if out_of_lives && !_finished_the_game:
        _do_game_lose()

    Victory: Team wins by completing the final wave

    Defeat: Team loses if lives reach 0

    Special case: In "neverending" mode, the game continues after victory

# Score & Experience:

    When the game ends (win or lose), scores are converted to experience

    Players can level up and gain wisdom upgrade slots

    Experience is stored persistently between games

    This flow creates a wave-based game structure where players must survive increasingly difficult waves while maintaining their team's lives, with various difficulty options and progression systems in place.