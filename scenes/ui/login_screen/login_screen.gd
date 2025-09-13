extends Control

## Login screen for SCP Foundation terminal
## Handles user authentication and transitions to desktop

signal login_successful(username: String)
signal login_failed(reason: String)

@onready var input_name: LineEdit = $ColorRect/HBoxContainer/VBoxContainer2/inputName
@onready var input_pass: LineEdit = $ColorRect/HBoxContainer/VBoxContainer2/inputPass
@onready var login_button: Button = $ColorRect/HBoxContainer/VBoxContainer2/Button

func _ready() -> void:
	# Connect button signal
	if login_button:
		login_button.pressed.connect(_on_login_button_pressed)
	
	# Allow Enter key to submit
	if input_pass:
		input_pass.text_submitted.connect(_on_password_submitted)
	
	# Focus on the name input
	if input_name:
		input_name.grab_focus()

func _on_login_button_pressed() -> void:
	attempt_login()

func _on_password_submitted(_text: String) -> void:
	attempt_login()

func attempt_login() -> void:
	var username = input_name.text.strip_edges() if input_name else ""
	var password = input_pass.text if input_pass else ""
	
	# Simple validation (you can expand this)
	if username.is_empty():
		show_error("Username required")
		return
	
	if password.is_empty():
		show_error("Password required")
		return
	
	# For now, accept any login
	# In a real game, you'd validate credentials here
	print("Login attempt for user: ", username)
	
	# Emit success signal
	login_successful.emit(username)

func show_error(message: String) -> void:
	print("Login error: ", message)
	login_failed.emit(message)
	
	# Flash the input fields red briefly
	if input_name:
		var original_color = input_name.modulate
		input_name.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.3).timeout
		input_name.modulate = original_color
