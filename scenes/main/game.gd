extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play('RESET')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	# this will ensure we can skip the boot screen
func _unhandled_input(event: InputEvent) -> void:
	var sv := $monitor/SubViewport        # <- adjust path to your SubViewport
	if sv:
		sv.push_input(event)   
