extends PregameTab


signal finished()


func _on_generic_button_pressed(tutorial_enabled: bool):
	PregameSettings._tutorial_enabled = tutorial_enabled
	finished.emit()


func _on_yes_button_pressed():
	_on_generic_button_pressed(true)


func _on_no_button_pressed():
	_on_generic_button_pressed(false)
