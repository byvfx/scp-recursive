extends Control

@onready var start = $Panel/Start
func _ready() -> void:
	if start:
		start.grab_focus()
		
func _on_start_pressed() -> void:
	print("START")


func _on_file_explorer_pressed() -> void:
	print("FILE EXPLORER")# Replace with function body.
