extends Control


@onready var livesBar: TextureProgressBar = $MarginContainer/LivesProgressBar


func _process(_delta: float):
	livesBar.value = max(Globals.portal_lives, 0)
	livesBar.tooltip_text = "Lives left: %s" % Globals.portal_lives