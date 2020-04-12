extends KinematicBody2D

onready var player = get_parent().get_node("Cat")
onready var sprite = get_node("Body")

var react_time = 400
var velocity = Vector2(0,0)
var direction = Vector2(0,0)
var next_direction = Vector2(0,0)
var next_direction_time = 0
export (float) var speed

var anim = "idle"

func _ready():
	pass
	
#update human properties
func control():
	#set human velocity
	velocity = Vector2()
	var not_move = false

	if !ckeck_poops() :
		print("a")
		move_to(player.position)
		
	if next_direction.x != direction.x or next_direction.y != direction.y:
		not_move = true
			
	if OS.get_ticks_msec() < next_direction_time:
		direction.x = next_direction.x
		direction.y = next_direction.y
	
	velocity = direction * speed

#	set animations
	if velocity.x == 0 && velocity.y == 0 or not_move :
		anim = "idle"
		not_move = false
	else :
		if velocity.x > 0 :
			anim = "walking_right"
		elif velocity.x < 0:
			anim = "walking_left"
		elif velocity.y < 0 :
			anim = "walking_forward"

func move_to(target):
		#	                      X
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
		

func ckeck_poops() :
	var all_poops = get_parent().get_node("Poops");
	
	if all_poops.get_child_count() != 0:
		print(all_poops.get_child(0).position)
		move_to(all_poops.get_child(0).position)
		return true
	else :
		return false
		
	

	
func _physics_process(delta):
	control()
	check_cat_collision(move_and_slide(velocity))
	sprite.play(anim)
	
func check_cat_collision(body):
	if get_slide_count() > 0:
		if get_slide_collision(get_slide_count()-1).get_collider().name == "Cat":
			get_tree().reload_current_scene()
