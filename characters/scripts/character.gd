extends CharacterBody2D

@export var speed: int = 150
@export var max_speed: int = 300
@onready var axis = Vector2.ZERO
@export var friction: int = 1500
@onready var anim = $AnimatedSprite2D
@onready var progress_bar = %ProgressBar
@onready var moving = false
@export var power:int = 0
@export var max_power:int = 100
var target = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	progress_bar.max_value = max_power
	progress_bar.value = power


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move(delta)
	if Input.is_action_pressed("mouse_click"):
		target = get_global_mouse_position()
	
func get_input_axis():
	axis.x = int(Input.is_action_pressed("rigth")) - int(Input.is_action_pressed("left"))
	axis.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return axis.normalized()

func move(delta):
	axis = get_input_axis()
	if Input.is_action_just_released("fire"):
		fire_snowball()
	elif Input.is_action_pressed("fire"):
		fire_prepare()
	elif axis == Vector2.ZERO:
		apply_friction(friction * delta)
		anim.play("idle_x")
	elif axis != Vector2.ZERO:
		apply_movement(axis * speed * delta)

	move_and_slide()

		
func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(max_speed)
	anim_walk()

func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func anim_walk():
	var angle = velocity.angle()
	if angle >= 0 and angle < 1.5:
		anim.play("walk_east")
	if angle > 1.5:
		anim.play("walk_west")
	if angle < 0 and angle > -1.5:
		anim.play("walk_north_east")
	if angle < -1.5:
		anim.play("walk_north_west")	

func fire_prepare():
	anim.play("gather")
	progress_bar.value += 1

func fire_snowball():
	var SNOWBALL = preload("res://projectile/snowbale.tscn")
	var new_snowball = SNOWBALL.instantiate()
	new_snowball.direction = target_direction()
	new_snowball.global_position = global_position
	new_snowball.distance = progress_bar.value
	progress_bar.value = 0
	if new_snowball.distance > 10:
		add_sibling(new_snowball)

func idle():
	anim.play("idle_x")

func target_direction():
	#get the target to where the snowball go's
	var direction = target - global_position
	return direction.normalized()

