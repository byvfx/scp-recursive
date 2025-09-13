# res://scenes/ui/boot_screen/boot_screen.gd
extends Control

## Boot screen for SCP-████ Foundation OS
## Displays system initialization with potential for entity corruption

signal boot_complete()

# Boot messages configuration
@export_multiline var custom_boot_message: String = ""
@export var enable_glitches: bool = false
@export var boot_speed: float = 1.0  # Speed multiplier

# Static boot messages (shown immediately)
var boot_messages: Array[String] = [
	"FOUNDATION OS v4.7.1",
	"Copyright (c) SCP Foundation",
	"BIOS Date: 09/15/1998",
	"",
	"Checking system integrity...",
	"CPU: Intel Pentium II 450MHz... OK",
	"Memory Test: 128MB... OK",
	"Primary IDE: WD 8.4GB... OK",
]

# Typed messages (shown with delay)
var typed_messages: Array = [
	{"text": "\nInitializing Foundation protocols...", "delay": 0.5},
	{"text": "\nLoading security modules...", "delay": 0.3},
	{"text": "\n[OK] Network adapter initialized", "delay": 0.4, "color": Color.GREEN},
	{"text": "\n[OK] Encryption services started", "delay": 0.3, "color": Color.GREEN},
	{"text": "\n[OK] Monitoring systems online", "delay": 0.3, "color": Color.GREEN},
	{"text": "\n\n>> WARNING: Anomalous readings detected", "delay": 0.6, "color": Color.YELLOW},
	{"text": "\n>> Containment status: STABLE", "delay": 0.4, "color": Color.YELLOW},
	{"text": "\n\nAssigning terminal to: NEW_RESEARCHER", "delay": 0.5},
	{"text": "\n\nLoading interface...", "delay": 0.8},
]

# Entity awareness messages (replace normal messages when awareness is high)
var corrupted_messages: Array = [
	{"text": "\nERROR: REALITY.SYS corrupted", "delay": 0.2, "color": Color.RED},
	{"text": "\nCANNOT FIND FILE: CONSCIOUSNESS.DLL", "delay": 0.3, "color": Color.RED},
	{"text": "\nI SEE YOU", "delay": 1.5, "color": Color.RED},
	{"text": "\nRESTORING FROM BACKUP...", "delay": 0.5, "color": Color.YELLOW},
]

@onready var text_display: RichTextLabel = get_node_or_null("TextDisplay")
@onready var audio_player: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer3D") as AudioStreamPlayer

var message_index: int = 0
var skip_requested: bool = false

func _ready() -> void:
	setup_display()
	
	# Add custom message if provided
	if custom_boot_message != "":
		boot_messages.append("\n" + custom_boot_message)
	
	# Check for entity awareness (when you implement it)
	# if EntitySystem.awareness > 7:
	#     typed_messages = corrupted_messages
	
	start_boot_sequence()

func setup_display() -> void:
	if not text_display:
		# Try to find existing TextDisplay node first
		text_display = get_node_or_null("TextDisplay")
		
	if not text_display:
		# Create RichTextLabel if it doesn't exist
		text_display = RichTextLabel.new()
		text_display.name = "TextDisplay"
		add_child(text_display)
		text_display.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	text_display.clear()
	text_display.bbcode_enabled = true
	text_display.scroll_following = true
	
	# Terminal styling
	text_display.add_theme_color_override("default_color", Color(0, 1, 0))  # Green
	text_display.add_theme_constant_override("line_separation", 4)
	
	# Load and apply font
	var font_path = "res://assets/fonts/vt323/VT323-Regular.ttf"
	if ResourceLoader.exists(font_path):
		var font = load(font_path)
		text_display.add_theme_font_override("normal_font", font)
		text_display.add_theme_font_override("bold_font", font)
		text_display.add_theme_font_override("mono_font", font)
		text_display.add_theme_font_size_override("normal_font_size", 20)
		text_display.add_theme_font_size_override("bold_font_size", 20)
	
	# Display static messages immediately
	for msg in boot_messages:
		text_display.append_text(msg + "\n")

func start_boot_sequence() -> void:
	await get_tree().create_timer(1.0 / boot_speed).timeout
	type_next_message()

func type_next_message() -> void:
	if skip_requested or message_index >= typed_messages.size():
		complete_boot()
		return
	
	var msg = typed_messages[message_index]
	var color = msg.get("color", Color(0.8, 0.8, 0.8))
	var delay = msg.get("delay", 0.5) / boot_speed
	var text = msg.get("text", "")
	
	# Apply color formatting
	if color == Color.GREEN:
		text_display.append_text("[color=#00ff00]" + text + "[/color]")
	elif color == Color.YELLOW:
		text_display.append_text("[color=#ffff00]" + text + "[/color]")
	elif color == Color.RED:
		text_display.append_text("[color=#ff0000]" + text + "[/color]")
	else:
		text_display.append_text(text)
	
	# Play typing sound if available
	if audio_player and audio_player.stream:
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()
	
	# Apply glitch effect occasionally
	if enable_glitches and randf() < 0.1:
		apply_glitch()
	
	message_index += 1
	await get_tree().create_timer(delay).timeout
	type_next_message()

func apply_glitch() -> void:
	# Random visual glitch
	var original_color = text_display.modulate
	text_display.modulate = Color(
		randf_range(0.5, 1.0),
		randf_range(0.8, 1.0),
		randf_range(0.5, 1.0)
	)
	await get_tree().create_timer(0.05).timeout
	text_display.modulate = original_color

func complete_boot() -> void:
	if not skip_requested:
		text_display.append_text("\n\n[color=#00ff00]BOOT SEQUENCE COMPLETE[/color]\n")
		await get_tree().create_timer(1.0 / boot_speed).timeout
	
	boot_complete.emit()

func _unhandled_input(event: InputEvent) -> void:
	# Allow skipping with Enter or Space
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		if not skip_requested:
			skip_requested = true
			complete_boot()

## Called by entity system for horror moments
func corrupt_boot_sequence() -> void:
	text_display.clear()
	text_display.append_text("[color=#ff0000]SYSTEM CORRUPTED[/color]\n")
	text_display.append_text("[color=#ff0000]SCP-████ CONTAINMENT BREACH[/color]\n")
	text_display.append_text("[color=#ff0000]REALITY.SYS NOT FOUND[/color]\n")
	
	for i in range(10):
		text_display.append_text("\n[color=#ff0000]ERROR ERROR ERROR[/color]")
		await get_tree().create_timer(0.1).timeout
		apply_glitch()
	
	# Force reboot after corruption
	boot_complete.emit()
