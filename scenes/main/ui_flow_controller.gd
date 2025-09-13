extends Control
#class_name UIFlowController

const LoginScreen := preload("res://scenes/ui/login_screen/login_screen.tscn")

@onready var boot := $BootScreen

func _ready() -> void:
	boot.set_anchors_preset(Control.PRESET_FULL_RECT)
	boot.boot_complete.connect(_on_boot_complete)

func _on_boot_complete() -> void:
	# Fade out boot
	var t = get_tree().create_tween()
	t.tween_property(boot, "modulate:a", 0.0, 0.4)
	await t.finished

	boot.queue_free()

	# Instance login, full screen, fade in
	var login := LoginScreen.instantiate()
	add_child(login)
	login.modulate.a = 0.0

	var t2 = get_tree().create_tween()
	t2.tween_property(login, "modulate:a", 1.0, 0.4)
	 
