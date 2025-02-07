extends Node

const CHARACTER_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SCORE_MODIFIER = 0.1
const SPEED_MODIFIER = 1000

var speed : float
var score : int
var screen_size : Vector2i
var game_running : bool
var ground_height : int
var last_obs

var stump_scene = preload("res://Objects/stump.tscn")
var rock_scene = preload("res://Objects/rock.tscn")
var barrel_scene = preload("res://Objects/barrel.tscn")
var bird_scene = preload("res://Objects/bird.tscn")
var obstacle_types = [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var bird_height := [200, 390]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game() -> void:
	score = 0
	game_running = false
	
	update_score(score)
	
	$RedHood.position = CHARACTER_START_POS
	$RedHood.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	$Hud.get_node("StartLabel").show()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + ( score / SPEED_MODIFIER )
		speed = mini(speed, MAX_SPEED)
		
		generate_obs()
		
		score += speed
		update_score(score)
		
		$RedHood.position.x += speed
		$Camera2D.position.x += speed
		
		if ($Camera2D.position.x - $Ground.position.x) > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x		
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$RedHood.started = true
			$Hud.get_node("StartLabel").hide()

func generate_obs() -> void:
	if obstacles.is_empty():
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs = obs_type.instantiate()
		var obs_height = obs.get_node("Sprite2D").texture.get_height()
		var obs_scale = obs.get_node("Sprite2D").scale
		var obs_x : int = screen_size.x + score + 100
		var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
		last_obs = obs
		add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y) -> void:
	obs.position = Vector2i(x,y)
	add_child(obs)
	obstacles.append(obs)
	
func update_score(score : int) -> void:
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score * SCORE_MODIFIER)
