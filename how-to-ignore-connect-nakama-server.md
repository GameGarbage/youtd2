I can help you modify the code to add a configurable flag to ignore Nakama server connection. Here are two approaches:

Using Project Settings (Recommended) :

First, add this near the top of your nakama_connection.gd file:

const SETTINGS_ENABLE_NAKAMA = "game/networking/enable_nakama"

# Add this to _ready() before any connection logic
func _ready():
    # Add setting to Project Settings if it doesn't exist
    if not ProjectSettings.has_setting(SETTINGS_ENABLE_NAKAMA):
        ProjectSettings.set_setting(SETTINGS_ENABLE_NAKAMA, true)
        ProjectSettings.set_initial_value(SETTINGS_ENABLE_NAKAMA, true)

    # Then modify your connection logic
    var server_key: String = Secrets.get_secret(Secrets.Key.SERVER_KEY)
    _client = Nakama.create_client(server_key, Constants.NAKAMA_ADDRESS, Constants.NAKAMA_PORT, Constants.NAKAMA_PROTOCOL, Nakama.DEFAULT_TIMEOUT, NakamaLogger.LOG_LEVEL.INFO)

    if ProjectSettings.get_setting(SETTINGS_ENABLE_NAKAMA):
        connect_to_server()
    else:
        print_verbose("Nakama connection disabled by configuration.")
        _set_state(NakamaConnection.State.FAILED_TO_CONNECT)

Copy

Insert at cursor
gdscript
Using Export Variable :

@export var enable_nakama_connection: bool = true

func _ready():
    var server_key: String = Secrets.get_secret(Secrets.Key.SERVER_KEY)
    _client = Nakama.create_client(server_key, Constants.NAKAMA_ADDRESS, Constants.NAKAMA_PORT, Constants.NAKAMA_PROTOCOL, Nakama.DEFAULT_TIMEOUT, NakamaLogger.LOG_LEVEL.INFO)

    if enable_nakama_connection:
        connect_to_server()
    else:
        print_verbose("Nakama connection disabled by configuration.")
        _set_state(NakamaConnection.State.FAILED_TO_CONNECT)

Copy

Insert at cursor
gdscript
Using Settings Singleton (If you already have a Settings system):

Add to your existing Settings system:

# In your Settings singleton
const ENABLE_NAKAMA = "enable_nakama"

# Add this to your settings initialization
func _init():
    _default_settings[ENABLE_NAKAMA] = true

Copy

Insert at cursor
gdscript
Then modify nakama_connection.gd:

func _ready():
    var server_key: String = Secrets.get_secret(Secrets.Key.SERVER_KEY)
    _client = Nakama.create_client(server_key, Constants.NAKAMA_ADDRESS, Constants.NAKAMA_PORT, Constants.NAKAMA_PROTOCOL, Nakama.DEFAULT_TIMEOUT, NakamaLogger.LOG_LEVEL.INFO)

    if Settings.get_setting(Settings.ENABLE_NAKAMA):
        connect_to_server()
    else:
        print_verbose("Nakama connection disabled by configuration.")
        _set_state(NakamaConnection.State.FAILED_TO_CONNECT)

Copy

Insert at cursor
gdscript
How to use each approach:

Project Settings :

Edit in Project → Project Settings → game/networking/enable_nakama

Can be overridden in export presets

Good for different builds (dev/prod)

Export Variable :

Edit directly in the Inspector when the node is selected

Easy to change in the editor

Good for quick testing

Settings Singleton :

Can be changed at runtime

Can be saved to user preferences

Good for user-configurable options

Choose the approach that best fits your needs:

Use Project Settings if you want to configure it per build

Use Export Variable if you want to configure it in the editor

Use Settings Singleton if you want runtime configuration or user preferences

Remember to handle any cleanup or state management appropriately when Nakama is disabled, and ensure your game's multiplayer features gracefully handle the disabled state