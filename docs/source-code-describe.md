# Describe game run flow step by step in file game_scene.gd

Sure, here's a step-by-step explanation of the game run flow in the 

# game_scene.gd

 file based on the provided excerpts:

1. **Logging**:
   - `print_verbose("GameScene has loaded.")`: Logs a message indicating that the game scene has loaded.

2. **Global Resets**:
   - `Globals.reset()`: Resets global settings or states.
   - `PlayerManager.reset()`: Resets the player manager.
   - `GroupManager.reset()`: Resets the group manager.

3. **Configuration**:
   - `var default_update_ticks_per_physics_tick: int = Config.update_ticks_per_physics_tick()`: Retrieves the default number of update ticks per physics tick from the configuration.
   - `Globals.set_update_ticks_per_physics_tick(default_update_ticks_per_physics_tick)`: Sets the update ticks per physics tick in the global settings.

4. **Buildable Cells**:
   - `var buildable_cells: Array[Vector2i] = _map.get_buildable_cells()`: Retrieves the buildable cells from the map.
   - `_build_space.set_buildable_cells(buildable_cells)`: Sets the buildable cells in the build space.

5. **HUD Setup**:
   - `_hud.set_game_start_timer(_game_start_timer)`: Sets the game start timer in the HUD.

6. **Event Bus Connections**:
   - Connects various events from the `EventBus` to corresponding handler functions:
     - `EventBus.player_requested_start_game.connect(_on_player_requested_start_game)`
     - `EventBus.player_requested_next_wave.connect(_on_player_requested_next_wave)`
     - `EventBus.player_requested_to_roll_towers.connect(_on_player_requested_to_roll_towers)`
     - `EventBus.player_requested_to_research_element.connect(_on_player_requested_to_research_element)`
     - `EventBus.player_requested_to_build_tower.connect(_on_player_requested_to_build_tower)`
     - `EventBus.player_requested_to_upgrade_tower.connect(_on_player_requested_to_upgrade_tower)`
     - `EventBus.player_requested_to_sell_tower.connect(_on_player_requested_to_sell_tower)`
     - `EventBus.player_clicked_autocast.connect(_on_player_clicked_autocast)`
     - `EventBus.player_requested_transmute.connect(_on_player_requested_transmute)`
     - `EventBus.player_requested_return_from_horadric_cube.connect(_on_player_requested_return_from_horadric_cube)`
     - `EventBus.player_requested_autofill.connect(_on_player_requested_autofill)`
     - `EventBus.player_right_clicked_autocast.connect(_on_player_right_clicked_autocast)`
     - `EventBus.player_right_clicked_item.connect(_on_player_right_clicked_item)`
     - `EventBus.player_shift_right_clicked_item.connect(_on_player_shift_right_clicked_item)`
     - `EventBus.player_clicked_tower_buff_group.connect(_on_player_clicked_tower_buff_group)`

7. **Unit Selection**:
   - `_select_unit.selected_unit_changed.connect(_on_selected_unit_changed)`: Connects the unit selection change event to its handler.

8. **Prerender Tool**:
   - Checks if the prerender tool should run (`Config.run_prerender_tool()`):
     - If running on a non-web platform, it runs the `PrerenderTool` and returns early to allow map pictures to be taken without pausing the game.
     - If running on a web platform, it logs an error message indicating that the prerender tool is enabled by mistake.

9. **Settings Change**:
   - `Settings.changed.connect(_on_settings_changed)`: Connects the settings change event to its handler.

10. **Builder Menu Setup**:
    - If `Config.autostart_builder_id()` is set, it calls `_set_builder_for_local_player(builder_id)` to set the builder for the local player.
    - If not set, it preloads the `BuilderMenu` scene, instantiates it, and connects the `finished` signal to `_on_builder_menu_finished`.
    - The `BuilderMenu` is added to the `_ui_layer` and moved below the `game_menu` in the UI layer to ensure the game menu appears on top.

11. **Messages**:
    - Two messages are added to inform the player about the first wave and how to start it early.

12. **Game Start Timer**:
    - The `_game_start_timer` is started with a delay defined by `Constants.TIME_BEFORE_FIRST_WAVE`.

13. **Multiplayer Setup**:
    - If the game is running on a server (`multiplayer.is_server()`), it sets up the game host with appropriate latency based on the player mode (single or multiplayer).

14. **Camera Position**:
    - The camera position is set to the origin position using `_get_camera_origin_pos()`.

15. **Special Tools**:
    - Several special tools are conditionally run based on configuration settings:
      - `SaveTooltipsTool.run(local_player)`: Runs if `Config.run_save_tooltips_tool()` is true.
      - `SaveTowerRangesTool.run(local_player)`: Runs if `Config.run_save_ranges_tool()` is true.
      - `TestTowersTool.run(self, local_player)`: Runs if `Config.run_test_towers_tool()` is true.
      - `TestItemsTool.run(self, local_player)`: Runs if `Config.run_test_items_tool()` is true.
      - `TestHoradricTool.run(local_player)`: Runs if `Config.run_test_horadric_tool()` is true.
      - `PlaytestBot.run(_build_space)`: Runs if `Config.run_auto_playtest_bot()` is true.

This script sets up the initial state of the game scene, including resetting global states, configuring update ticks, setting buildable cells, initializing the HUD, connecting various events, and optionally running the prerender tool. The normal gameplay starts after these initializations and connections are made.