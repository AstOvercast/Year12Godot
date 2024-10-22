extends CharacterBody3D

const ACCEL = 10
# This means the acceleration value is 10, so when w is pressed the charecter accelerates at this rate
const DEACCEL = 30
#This meanas that the deacceleration the player stops is 30. It would be weird if the first person player stops suddenly
@onready var door_check = $RayCast3D
# this sets the variable for the raycast 3d. This menas that the player has to be close to the door to open it and therefore the game is logical
const SPEED = 30.0
#Sets the normal walk speed
const SPRINT_MULT = 2
#sets the addition to the walk speed for the sprint speed
const JUMP_VELOCITY = 6.5
#ets the speed of the jump
const MOUSE_SENSITIVITY = 0.06
#ets the mouse sensitivity to 6 

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera
var rotation_helper
var dir = Vector3.ZERO
var flashlight

func _ready():
	camera = $rotation_helper/Camera3D
	rotation_helper = $rotation_helper
	flashlight = $rotation_helper/Camera3D/flashlight_player
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# This section controls player camera.MOUSE_SENSITIVITY can be changed
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation
		camera_rot.x = clampf(camera_rot.x, -1.4, 1.4)
		rotation_helper.rotation = camera_rot
	
	# Release/Grab Mouse for debugging.
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Flashlight toggle. Defaults to F on Keyboard.
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_E:
			print("pushed e")
			#confirms in console if 'E' has been pressed
			if door_check.is_colliding():
				print("ray is colliding")
				#confirms in console if ray is colliding
				var collider = door_check.get_collider()
				collider.owner.get_node("AnimationPlayer").play("open_door")
				#if conditions are met plays animation
		if event.pressed and event.keycode == KEY_F:
			#states if 'F' is pressed then flashlight will work
			if flashlight.is_visible_in_tree() and not event.echo:
				flashlight.hide()
				#will hide flashlight if objects are not in range of flashlight
			elif not event.echo:
				flashlight.show()
				#Shows flashlight if objects are in range of flashlight

func _physics_process(delta):
	var moving = false
	# Add the gravity. Pulls value from project settings.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# This just controls acceleration.
	var accel
	if dir.dot(velocity) > 0:
		accel = ACCEL
		moving = true
	else:
		accel = DEACCEL
		moving = false


	# Get the input direction and handle the movement/deceleration.
	
	var input_dir = Input.get_vector ("ui_left","ui_right","ui_up","ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * accel * delta
	if Input.is_key_pressed(KEY_SHIFT):
		direction = direction * SPRINT_MULT
	else:
		pass

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	#conclude the move and slie function


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		get_tree()
		scene_file_path
