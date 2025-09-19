extends Control

@onready var focus = $VBoxContainer/GridContainer/FileExplorer
@onready var file_explorer = $FileExplorer

func _ready() -> void:
	if focus:
		focus.grab_focus()
		
#func _on_start_pressed() -> void:
	#print("START")


func _on_file_explorer_pressed() -> void:
	print("FILE EXPLORER")
	file_explorer.show()

func _on_terminal_pressed() -> void:
	print("TERMINAL") # Replace with function body.


func _on_email_pressed() -> void:
	print("EMAIL") # Replace with function body.


func _on_instant_messenger_pressed() -> void:
	print("IM") # Replace with function body.


func _on_cams_pressed() -> void:
	print("CAMS") # Replace with function body.
