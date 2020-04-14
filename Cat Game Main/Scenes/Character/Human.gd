extends KinematicBody2D

onready var player = get_tree().get_root().get_node("Level1/GameControl/Cat")
onready var sprite = get_node("Body")

var react_time = 400
var velocity = Vector2(0,0)
var direction = Vector2(0,0)
var next_direction = Vector2(0,0)
var next_direction_time = 0
export (float) var speed
var is_cat_touched = false
var anim = "idle"

func _ready():
	pass
	
#update human properties
func control():
	#set human velocity
	velocity = Vector2()

	if !check_poops() :
		move_to(player.position)
		
	if next_direction.x != direction.x or next_direction.y != direction.y:
		is_cat_touched = true

	if OS.get_ticks_msec() < next_direction_time:
		direction.x = next_direction.x
		direction.y = next_direction.y
	
	velocity = direction * speed

#	set animations
	if (velocity.x == 0 and velocity.y == 0) or is_cat_touched :
		anim = "idle"
		is_cat_touched = false
	else :
		if velocity.x > 0 :
			anim = "walking_right"
		elif velocity.x < 0:
			anim = "walking_left"
		elif velocity.y < 0 :
			anim = "walking_forward"

func move_to(target):
		#	                  X
		if target.x > position.x:
			set_dir(1, 0)
		elif target.x < position.x:
			set_dir(-1, 0)
		elif target.x == position.x:
			set_dir(0, 0)	
	
	#	                      Y
		if target.y > position.y :
			set_dir(1, 1)
	
		elif target.y < position.y:
			set_dir(-1, 1)
		elif target.y == position.y:
			set_dir(0, 1)
			
			
func set_dir(orientation_dir, axis=3):
	if axis == 0:
		if next_direction.x != orientation_dir:
			next_direction.x = orientation_dir
			next_direction_time = 	OS.get_ticks_msec() + react_time
	elif axis == 1:
		if next_direction.y != orientation_dir:
			next_direction.y = orientation_dir
			next_direction_time = 	OS.get_ticks_msec() + react_time
		

#	Check if a poop exist, and if yes, got to it direction and return true. Otherwise return false
func check_poops() :
	var all_poops = get_tree().get_root().get_node("Level1/GameControl/Poops");
	if all_poops.get_child_count() != 0:
		move_to(all_poops.get_child(0).position)
		return true
	else :
		return false
	
func _physics_process(delta):
	control()
	check_collision(move_and_slide(velocity))
	sprite.play(anim)
	
func check_collision(body):
	if get_slide_count() > 0:
		if get_slide_collision(get_slide_count()-1).get_collider().name == "Cat":
			is_cat_touched = true
			set_physics_process(false)
			get_tree().get_root().get_node("Level1/GameControl/Cat").game_over()
