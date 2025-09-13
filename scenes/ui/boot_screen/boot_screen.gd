# BootScreen.gd
extends Control

signal boot_complete

@export var boot_messages: Array[String] = [
	"FOUNDATION SECURE SYSTEMS v7.3.1",
	"Copyright (c) 1987-2025 SCP Foundation",
	"All Rights Reserved.",
	"",
	"AMIBIOS (C) 1992 American Megatrends Inc.",
	"BIOS Date: 01/28/25 18:32:41 Ver: 08.00.15",
	"CPU: Intel Core i7-9700K @ 3.60GHz",
	"Memory Test: 16384M OK",
	"",
	"Press DEL to enter SETUP, F8 for Boot Menu",
	"",
	"Initializing USB Controllers ... Done",
	"Loading Foundation OS ..."
]

@export var typed_messages: Array[Dictionary] = [
	{"text": "Checking file system integrity... ", "delay": 0.5},
	{"text": "OK", "delay": 0.8, "color": Color(0, 1, 0)},
	{"text": "\nLoading security protocols... ", "delay": 0.4},
	{"text": "OK", "delay": 0.6, "color": Color(0, 1, 0)},
	{"text": "\nInitializing containment systems... ", "delay": 0.7},
	{"text": "OK", "delay": 0.9, "color": Color(0, 1, 0)},
	{"text": "\nConnecting to Foundation network... ", "delay": 0.6},
	{"text": "OK", "delay": 1.0, "color": Color(0, 1, 0)},
	{"text": "\n\nScanning for anomalies... ", "delay": 0.8},
	{"text": "WARNING", "delay": 0.5, "color": Color(1, 1, 0)},
	{"text": "\nAnomaly detected in D:\\Containment\\SCP-████", "delay": 0.3, "color": Color(1, 0, 0)},
	{"text": "\nAttempting automated containment... ", "delay": 1.0},
	{"text": "FAILED", "delay": 0.5, "color": Color(1, 0, 0)},
	{"text": "\n\nManual intervention required.", "delay": 0.4, "color": Color(1, 1, 0)},
	{"text": "\nAssigning to: NEW_RESEARCHER", "delay": 0.5, "color": Color(1, 1, 0)},
	{"text": "\n\nLoading desktop environment...", "delay": 0.8},
]

@onready var text_display: RichTextLabel = $'../TextDisplay'
#@onready var background: ColorRect = $Background if has_node("Background") else null
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer if has_node("AudioStreamPlayer") else null
@onready var subviewport: SubViewport = $SubViewport if has_node("SubViewport") else null

var current_text: String = ""
var message_index: int = 0

func _ready():
	setup_display()
	start_boot_sequence()

func setup_display():
	if not text_display:
		return
	text_display.clear()
	text_display.bbcode_enabled = true
	text_display.scroll_active = true
	text_display.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	text_display.add_theme_font_size_override("normal_font_size", 18)
	text_display.add_theme_font_size_override("bold_font_size", 18)
	text_display.add_theme_font_size_override("mono_font_size", 18)
	text_display.add_theme_color_override("default_color", Color(0, 1, 0, 1))
	text_display.add_theme_constant_override("line_separation", 4)

	var font_path = "res://assets/fonts/vt323/VT323-Regular.ttf"
	if ResourceLoader.exists(font_path):
		var font = load(font_path)
		text_display.add_theme_font_override("normal_font", font)
		text_display.add_theme_font_override("bold_font", font)
		text_display.add_theme_font_override("mono_font", font)

	# static boot messages
	text_display.append_text("[b]")
	for msg in boot_messages:
		text_display.append_text(msg + "\n")
	text_display.append_text("[/b]\n")

	# (new) ensure we start at the bottom after initial fill
	call_deferred("_scroll_to_bottom")


func _scroll_to_bottom() -> void:
	if not text_display:
		return
	# Wait one frame so sizes/layout are updated
	await get_tree().process_frame
	text_display.scroll_active = false
	text_display.scroll_to_line(max(0, text_display.get_line_count() - 1))


func start_boot_sequence():
	await get_tree().create_timer(1.0).timeout
	type_next_message()

func type_next_message():
	if message_index >= typed_messages.size():
		complete_boot()
		return
	if not text_display:
		return

	var msg = typed_messages[message_index]
	var color = msg.get("color", Color(0.8, 0.8, 0.8))
	var delay = msg.get("delay", 0.5)
	
	  # safer than msg.text

	if color == Color(0, 1, 0):
		text_display.append_text("[color=#00ff00][b]" + msg.text + "[/b][/color]")
	elif color == Color(1, 1, 0):
		text_display.append_text("[color=#ffff00][b]" + msg.text + "[/b][/color]")
	elif color == Color(1, 0, 0):
		text_display.append_text("[color=#ff0000][b]" + msg.text + "[/b][/color]")
	else:
		text_display.append_text(msg.text)

 
	_scroll_to_bottom()

	if audio_player and audio_player.stream:
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()

	message_index += 1
	await get_tree().create_timer(delay).timeout
	type_next_message()


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		complete_boot()

func complete_boot():
	await get_tree().create_timer(1.0).timeout
	boot_complete.emit()
	

	
