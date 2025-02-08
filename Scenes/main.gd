extends Node

const CHARACTER_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SCORE_MODIFIER = 0.1
const SPEED_MODIFIER = 1000
const MAX_DIFFICULTY : int = 2

var speed : float
var score : int
var high_score : int = 0
var difficulty : int
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
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game() -> void:
	score = 0
	game_running = false
	difficulty = 0
	get_tree().paused = false
	
	for obs in obstacles:
		if obs != null:
			obs.queue_free()
	obstacles.clear()
	
	update_score(score)
	
	$RedHood.position = CHARACTER_START_POS
	$RedHood.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	$Hud.get_node("StartLabel").show()
	$GameOver.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + ( score / SPEED_MODIFIER )
		speed = mini(speed, MAX_SPEED)
		
		adjust_difficulty()
		
		generate_obs()
		
		score += speed
		update_score(score)
		
		$RedHood.position.x += speed
		$Camera2D.position.x += speed
		
		if ($Camera2D.position.x - $Ground.position.x) > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x		
			
		for obs in obstacles:
			if obs != null and obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$RedHood.started = true
			$Hud.get_node("StartLabel").hide()

func generate_obs() -> void:
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs = obs_type.instantiate()
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		if difficulty == 0:
			if(randi() % 2) == 0:
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_height[randi() % bird_height.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y) -> void:
	obs.position = Vector2i(x,y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs) -> void:
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body) -> void:
	if body.name == 'RedHood':
		game_over()
	
func adjust_difficulty() -> void:
	difficulty = score / SPEED_MODIFIER
	
func update_score(score : int) -> void:
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(int(score * SCORE_MODIFIER))
	
func update_highscore(score : int) -> void:
	if score > high_score:
		high_score = score
		$Hud.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(int(high_score * SCORE_MODIFIER))

func game_over() -> void:
	get_tree().paused = true
	game_running = false
	$RedHood.started = false
	update_highscore(score)
	$GameOver.show()
