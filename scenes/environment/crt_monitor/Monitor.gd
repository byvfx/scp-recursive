extends MeshInstance3D

@onready var viewport = $"../SubViewport"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# Get the viewport texture
	var viewport_texture = viewport.get_texture()
	
	#var material := load('res://crt_shader.tres') as StandardMaterial3D
	#if material == null:
		#push_error("couldnt load shader")
		#
	#material.albedo_texture = viewport_texture
	#material.emission_texture = viewport_texture
	#material.uv1_scale = Vector3(-1,1,1)
	#set_surface_override_material(0, material) 
	
	#Shader method
	var shader = load('res://shaders/crt/shd_crt_effect.gdshader') as Shader
	var material = ShaderMaterial.new()
	material.shader = shader
	
	 # Set the viewport texture as the main texture
	material.set_shader_parameter("viewport_texture", viewport_texture)
	
	# Optional: Adjust shader parameters
	material.set_shader_parameter("scan_line_count", 200)
	material.set_shader_parameter("warp_amount", 0.03)
	material.set_shader_parameter("noise_amount", 0.02)
	material.set_shader_parameter("chromatic_aberration", 0.003)
	material.set_shader_parameter("emission_strength", 0.8)
	material.set_shader_parameter("flip_h", true)
	material.set_shader_parameter("scan_speed",-1)
	material.set_shader_parameter("scan_intensity",.5)
	material.set_shader_parameter("scan_contrast",1)
	set_surface_override_material(0,material)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
