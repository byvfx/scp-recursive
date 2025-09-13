# res://scenes/main/ui_flow_controller.gd
extends Control
class_name UIFlowController

## Manages transitions between different UI screens in SCP-████
## Handles boot → login → desktop → terminal flow

# Preload all UI screens
const BootScreen := preload("res://scenes/ui/boot_screen/boot_screen.tscn")
const LoginScreen := preload("res://scenes/ui/login_screen/login_screen.tscn")
const Desktop := preload("res://scenes/ui/desktop/desktop.tscn")
# const Terminal := preload("res://scenes/ui/terminal/terminal.tscn")

# Screen references
var boot_screen: Control = null
var current_screen: Control = null
var transitioning: bool = false

# Transition settings
@export var fade_duration: float = 0.4
@export var auto_start_boot: bool = true

# Signals for game state
signal boot_completed()
signal login_successful(username: String)
signal desktop_ready()
signal terminal_opened()
signal screen_changed(screen_name: String)

func _ready() -> void:
	# Ensure we fill available space
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks pass through to children
	
	if auto_start_boot:
		# Check if BootScreen is already a child (from scene)
		boot_screen = get_node_or_null("BootScreen")
		if boot_screen:
			# BootScreen exists as child in scene
			_setup_boot_screen(boot_screen)
		else:
			# Create boot screen dynamically
			show_boot_screen()

## Show the boot screen
func show_boot_screen() -> void:
	if transitioning:
		return
		
	var boot := BootScreen.instantiate()
	add_child(boot)
	boot.set_anchors_preset(Control.PRESET_FULL_RECT)
	_setup_boot_screen(boot)
	boot_screen = boot
	current_screen = boot
	screen_changed.emit("boot")

## Setup boot screen connections
func _setup_boot_screen(boot: Control) -> void:
	if boot.has_signal("boot_complete"):
		if not boot.boot_complete.is_connected(_on_boot_complete):
			boot.boot_complete.connect(_on_boot_complete)

## Handle boot completion
func _on_boot_complete() -> void:
	print("Boot complete, transitioning to login...")
	boot_completed.emit()
	await transition_to_login()

## Transition to login screen
func transition_to_login() -> void:
	if transitioning:
		return
	
	transitioning = true
	
	# Create login screen (invisible initially)
	var login := LoginScreen.instantiate()
	add_child(login)
	login.set_anchors_preset(Control.PRESET_FULL_RECT)
	login.modulate.a = 0.0
	
	# Connect login signals if they exist
	if login.has_signal("login_successful"):
		login.login_successful.connect(_on_login_successful)
	
	# Fade out boot screen
	if boot_screen:
		var fade_out = get_tree().create_tween()
		fade_out.tween_property(boot_screen, "modulate:a", 0.0, fade_duration)
		await fade_out.finished
		boot_screen.queue_free()
		boot_screen = null
	
	# Fade in login screen
	var fade_in = get_tree().create_tween()
	fade_in.tween_property(login, "modulate:a", 1.0, fade_duration)
	await fade_in.finished
	
	current_screen = login
	transitioning = false
	screen_changed.emit("login")

## Handle successful login
func _on_login_successful(username: String = "NEW_RESEARCHER") -> void:
	print("Login successful for: ", username)
	login_successful.emit(username)
	await transition_to_desktop()

## Transition to desktop screen
func transition_to_desktop() -> void:
	if transitioning:
		return
	
	transitioning = true
	
	# Create desktop screen (invisible initially)
	var desktop := Desktop.instantiate()
	add_child(desktop)
	desktop.set_anchors_preset(Control.PRESET_FULL_RECT)
	desktop.modulate.a = 0.0
	
	# Connect desktop signals if they exist
	if desktop.has_signal("terminal_requested"):
		desktop.terminal_requested.connect(_on_terminal_requested)
	
	# Fade out login screen
	if current_screen and is_instance_valid(current_screen):
		var fade_out = get_tree().create_tween()
		fade_out.tween_property(current_screen, "modulate:a", 0.0, fade_duration)
		await fade_out.finished
		current_screen.queue_free()
	
	# Fade in desktop screen
	var fade_in = get_tree().create_tween()
	fade_in.tween_property(desktop, "modulate:a", 1.0, fade_duration)
	await fade_in.finished
	
	current_screen = desktop
	transitioning = false
	desktop_ready.emit()
	screen_changed.emit("desktop")

## Handle terminal request from desktop
func _on_terminal_requested() -> void:
	print("Terminal requested from desktop")
	terminal_opened.emit()
	# await transition_to_terminal()  # Implement when terminal is ready

## Generic transition between screens
func transition_to_screen(new_screen: Control, screen_name: String) -> void:
	if transitioning:
		return
	
	transitioning = true
	
	# Add new screen
	add_child(new_screen)
	new_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_screen.modulate.a = 0.0
	
	# Fade transition
	if current_screen and is_instance_valid(current_screen):
		var fade_out = get_tree().create_tween()
		fade_out.tween_property(current_screen, "modulate:a", 0.0, fade_duration)
		await fade_out.finished
		current_screen.queue_free()
	
	var fade_in = get_tree().create_tween()
	fade_in.tween_property(new_screen, "modulate:a", 1.0, fade_duration)
	await fade_in.finished
	
	current_screen = new_screen
	transitioning = false
	screen_changed.emit(screen_name)

## Glitch transition for horror moments
func glitch_transition(new_screen: Control, screen_name: String) -> void:
	if transitioning:
		return
	
	transitioning = true
	
	# Quick flicker effect
	if current_screen and is_instance_valid(current_screen):
		for i in range(3):
			current_screen.visible = false
			await get_tree().create_timer(0.05).timeout
			current_screen.visible = true
			await get_tree().create_timer(0.05).timeout
		current_screen.queue_free()
	
	# Add new screen with distortion
	add_child(new_screen)
	new_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Simulate glitch colors
	var original_modulate = new_screen.modulate
	for i in range(5):
		new_screen.modulate = Color(
			randf_range(0.5, 1.0),
			randf_range(0.8, 1.0),
			randf_range(0.5, 1.0)
		)
		await get_tree().create_timer(0.03).timeout
	new_screen.modulate = original_modulate
	
	current_screen = new_screen
	transitioning = false
	screen_changed.emit(screen_name)

## Force restart (for entity intervention)
func force_reboot(message: String = "") -> void:
	print("Forcing reboot...")
	
	# Clear everything
	for child in get_children():
		child.queue_free()
	
	current_screen = null
	transitioning = false
	
	# Wait a frame for cleanup
	await get_tree().process_frame
	
	# Start boot with custom message if provided
	if message != "":
		var boot := BootScreen.instantiate()
		# You could pass the custom message to boot screen here
		# boot.custom_message = message
		add_child(boot)
		boot.set_anchors_preset(Control.PRESET_FULL_RECT)
		_setup_boot_screen(boot)
		boot_screen = boot
		current_screen = boot
	else:
		show_boot_screen()

## Get current screen name for state tracking
func get_current_screen_name() -> String:
	if not current_screen:
		return "none"
	
	# Try to identify screen by node name or class
	if current_screen.has_method("get_screen_name"):
		return current_screen.get_screen_name()
	
	var screen_name = current_screen.name.to_lower()
	if "boot" in screen_name:
		return "boot"
	elif "login" in screen_name:
		return "login"
	elif "desktop" in screen_name:
		return "desktop"
	elif "terminal" in screen_name:
		return "terminal"
	
	return screen_name

## Check if we're in transition (useful for preventing input)
func is_transitioning() -> bool:
	return transitioning

## Debug function to skip to specific screen
func _input(event: InputEvent) -> void:
	# Debug shortcuts (remove in production)
	if OS.is_debug_build():
		if event.is_action_pressed("ui_page_up"):  # PageUp key
			print("Debug: Forcing login screen")
			transition_to_login()
		elif event.is_action_pressed("ui_page_down"):  # PageDown key
			print("Debug: Forcing reboot")
			force_reboot("DEBUG_REBOOT_INITIATED")
