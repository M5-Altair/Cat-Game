extends KinematicBody2D
class_name Cat

signal food_changed
signal energy_changed
signal cat_covered


onready var poop_scene = preload("res://Scenes/Elements/Poop.tscn")
onready var sprite = get_node("Body")

export (float) var speed

const max_energy = 100
const max_food = 100
const defecate_food_amount = 40

var energy
var food = 0
var velocity = Vector2()
var anim = "idle"
var can_move = true
var can_poop = true
var on_furniture = false

func _ready():
	energy = max_energy
	food = max_food/2

#update cat properties
func control():
	var is_moving = false
	var energy_dec = 0
	var food_dec = 0.008
	var is_exhausted = false
	velocity = Vector2()
	#set cat velocity and energy
	if can_move:
		is_moving = false
		if Input.is_action_pressed("move_right"):
			velocity += Vector2(speed, 0)
			energy_dec = 0.05
			is_moving = true
		if Input.is_action_pressed("move_left"):
			velocity += Vector2(-speed, 0)
			energy_dec = 0.05
			is_moving = true
		if Input.is_action_pressed("move_forward"):
			velocity += Vector2(0, -speed)
			energy_dec = 0.05
			is_moving = true
		if Input.is_action_pressed("move_backward"):
			velocity += Vector2(0, speed)
			energy_dec = 0.05
			is_moving = true
		if Input.is_action_pressed("running") and (velocity.x != 0 or velocity.y !=0):
			velocity += velocity
			energy_dec = 0.25
			is_moving = true
		if energy <= 100 and not is_moving:
			energy_dec = -0.05
	else:
		energy_dec = -0.05
	energy -= energy_dec
	food -= food_dec
	#set food if cat shitting and instanciate shit
	if can_poop and !on_furniture:
		if Input.is_action_just_pressed("defecating"):
			food -= defecate_food_amount
			instanciatePoop()
	#set movement limitations
	if energy <= 0 or is_exhausted:
		can_move = false
	elif energy < 10:
		is_exhausted = true
	else:
		can_move = true
	#set food limitation (for movement and defecating)
	if food <=0 and (velocity.x != 0 or velocity.y !=0):
		velocity /= 2
	elif food < defecate_food_amount and !on_furniture:
		can_poop = false
	elif food >= defecate_food_amount and !on_furniture:
		can_poop = true
	#set animations
	if velocity.x == 0 && velocity.y == 0:
		anim = "idle"
	else :
		if velocity.x > 0:
			anim = "walking_right"
		elif velocity.x < 0:
			anim = "walking_left"
		elif velocity.y > 0:
			anim = "walking_backward"
		else:
			anim = "walking_forward"


func _physics_process(delta):
	control()
	if can_move:
		move_and_slide(velocity)
	sprite.play(anim)

func instanciatePoop():
	var new_poop = poop_scene.instance()
	#set poop position
	if velocity.x == 0 && velocity.y == 0:
		new_poop.position.x = position.x
		new_poop.position.y = position.y + 40
	else :
		new_poop.position.x = position.x - velocity.x/3.5
		new_poop.position.y = position.y - velocity.y/3.5
	new_poop.connect("poop_touched",get_node("../Human"),"collect_poop")
	get_parent().get_node("Poops").add_child(new_poop)

func game_over():
	set_physics_process(false)
	$CanvasLayer/FadeIn.fade_in()

func _on_furniture_entered(body):
	if body.name == "Cat":
		emit_signal("cat_covered", true)

func _on_furniture_exited(body):
	if body.name == "Cat":
		emit_signal("cat_covered", false)

func _on_FadeIn_fade_finished():
	get_tree().reload_current_scene()
	
#emit signals for energy and food bars
func _on_FoodTween_tween_completed(object, key):
	emit_signal("food_changed",food)

func _on_EnergyTween_tween_completed(object, key):
	emit_signal("energy_changed",energy)

func _on_PoopRestrictedZone_body_entered(body):
	if body.name == "Cat":
		on_furniture = true
		get_tree().get_root().get_node("House/UserInterface/GUI").toggle_poop_restricted_info(on_furniture)

func _on_PoopRestrictedZone_body_exited(body):
	if body.name == "Cat":
		on_furniture = false
		get_tree().get_root().get_node("House/UserInterface/GUI").toggle_poop_restricted_info(on_furniture)
