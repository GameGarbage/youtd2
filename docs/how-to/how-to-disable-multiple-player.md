I'll guide you through creating a configurable flag in the Godot project to disable multiplayer mode. Here's a step-by-step approach:

First, create a configuration setting in your Config or Settings system.

Here's how to implement it:

Step 1: Add a configuration flag
Create or modify your project settings (likely in a Config.gd or Settings.gd file):

# Config.gd or Settings.gd
class_name Config

# Add this with your other configuration settings
static func multiplayer_enabled() -> bool:
    # You can store this in project settings or a config file
    # For testing, you can return false directly
    return ProjectSettings.get_setting("game/multiplayer_enabled", false)

Copy

Insert at cursor
gdscript
Step 2: Modify the game_scene.gd to use this flag

# In game_scene.gd

func _ready():
    # Add this near the start of _ready()
    if !Config.multiplayer_enabled():
        # Force singleplayer mode
        Globals.set_player_mode(PlayerMode.enm.SINGLEPLAYER)
        Globals.set_team_mode(TeamMode.enm.ONE_PLAYER_PER_TEAM)

    # Rest of your _ready() code...

Copy

Insert at cursor
gdscript
Step 3: Modify the map selection logic

# In game_scene.gd, modify the map selection part:

func _ready():
    # ... other code ...

    # Modify the map selection logic
    var use_small_map: bool = !Config.multiplayer_enabled() || Globals.get_player_mode() == PlayerMode.enm.SINGLEPLAYER
    
    if use_small_map:
        _map = _map_small
    else:
        var map_big_scene: PackedScene = load("res://src/map/map_big.tscn")
        var map_big: Map = map_big_scene.instantiate()
        _map_small.add_sibling(map_big)
        _map = map_big
        _map_small.get_parent().remove_child(_map_small)
        _map_small.queue_free()

Copy

Insert at cursor
gdscript
Step 4: Modify the player setup

# In game_scene.gd

func _setup_players():
    var peer_id_list: Array[int] = []
    var local_peer_id: int = multiplayer.get_unique_id()
    peer_id_list.append(local_peer_id)

    # Only add remote peers if multiplayer is enabled
    if Config.multiplayer_enabled():
        var remote_peer_id_list: PackedInt32Array = multiplayer.get_peers()
        for peer_id in remote_peer_id_list:
            peer_id_list.append(peer_id)

    # Create teams
    var team_mode: TeamMode.enm = Globals.get_team_mode()
    var player_count_per_team: int = TeamMode.get_player_count_per_team(team_mode)
    var player_count: int = peer_id_list.size()
    var team_count: int = ceili(player_count * 1.0 / player_count_per_team)

    # Rest of your team setup code...

Copy

Insert at cursor
gdscript
Step 5: Add UI handling for the multiplayer flag

# In your menu or title screen script

func _ready():
    # Disable multiplayer buttons/options if multiplayer is disabled
    if !Config.multiplayer_enabled():
        # Assuming you have multiplayer buttons or options
        $MultiplayerButton.hide()  # or disable
        $TeamSelectOption.hide()   # or disable

Copy

Insert at cursor
gdscript
Step 6: Add configuration to Project Settings

Open Project Settings in Godot

Go to the "General" tab

Add a custom property:

Property: game/multiplayer_enabled

Type: bool

Default value: false

You can do this in code as well:

# In your game initialization
func _init():
    if !ProjectSettings.has_setting("game/multiplayer_enabled"):
        ProjectSettings.set_setting("game/multiplayer_enabled", false)
    ProjectSettings.set_initial_value("game/multiplayer_enabled", false)

Copy

Insert at cursor
gdscript
Step 7: Optional - Add runtime configuration

# If you want to allow runtime configuration:
class_name Config

static var _multiplayer_enabled: bool = false

static func set_multiplayer_enabled(enabled: bool):
    _multiplayer_enabled = enabled
    # Save to config file or ProjectSettings if needed
    ProjectSettings.set_setting("game/multiplayer_enabled", enabled)
    ProjectSettings.save()

static func multiplayer_enabled() -> bool:
    return _multiplayer_enabled

Copy

Insert at cursor
gdscript
Usage:

# To disable multiplayer:
Config.set_multiplayer_enabled(false)

# To check if multiplayer is enabled:
if Config.multiplayer_enabled():
    # Do multiplayer stuff
else:
    # Do singleplayer stuff

Copy

Insert at cursor
gdscript
This implementation:

Makes multiplayer a configurable option

Defaults to singleplayer when disabled

Can be easily toggled for testing

Persists the setting in ProjectSettings

Affects all relevant parts of the game

Maintains the existing code structure while adding the toggle functionality

Remember to:

Test thoroughly after implementing these changes

Update any networking code to respect this setting

Update UI elements to reflect the available game modes

Handle any multiplayer-specific features appropriately when disabled

Consider adding appropriate error messages if players try to access multiplayer features when disabled