class_name Team

# Represents player's team. Two players per team.

# NOTE: Currently team is barely implemented. Will need to
# work on it for multiplayer.


# NOTE: Team.getLivesPercent() in JASS
func get_lives_percent() -> float:
	return PortalLives.get_current()


func get_lives_string() -> String:
	return PortalLives.get_lives_string()


func modify_lives(amount: float):
	PortalLives.modify_portal_lives(amount)


# NOTE: Team.getLevel() in JASS
func get_level() -> int:
	return WaveLevel.get_current()


func increment_level():
	WaveLevel.increase()
