extends CharacterBody3D

@export var speed = 6
@export var mouse_sensitivity = 0.01
@onready var camera = $Camera3D
@export var jump_speed = 5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _physics_process(delta):
	velocity.y += -gravity * delta
	var input_dir = Input.get_vector ("left","right","up","down")
	var move_dir = transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	if input_dir:
		velocity.x = input_dir.y * speed
		velocity.z = input_dir.y * speed
	else:
		velocity.x = 0
		velocity.z = 0
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_speed
	move_and_slide()
		
		
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		#print(camera.rotation_degrees.x)
		camera.rotation.x = clamp(camera.rotation.x,-1,1)
		
		
   
