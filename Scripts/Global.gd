extends Node

#Variables
var player : GameEntity = null
var ui = null
var playfield = null

var player_chars = [TestPlayerChar] #List of playerentity classes for the player that they can switch between
var player_char_index : int = 0


var game_state : int = 0 #0 is menu, 1 is playing
var player_health : #used for interacting with player health
	set(value):
		if(player != null):
			player.health = value
		if(ui != null):
			ui._update_health()
	get:
		if(player != null):
			return player.health
		else:
			return 0.0

var score : float = 0 :
	set(value):
		score = value
		if(ui != null):
			ui._update_score()
	get:
		return score


var levels : Array[Level] = [TestLevel.new()] #List of available levels
var level_index : int = 0 #Index of selected level from levels

var spawn_list = [] : #Returns the list of spawn waves
	get:
		if(level_index<levels.size()):
			return levels[level_index].spawn_waves
		else:
			return []
var spawn_delays : Array[float] : #Contains delays between each spawn wave
	get:
		if(level_index<levels.size()):
			return levels[level_index].spawn_wave_delays
		else:
			return []

#Constants
const screen_resolutions = [[720,640],[1152,1024]] #Valid screen resolutions selectable from menu
const screen_bounds : Array[int] = [768, 1024] #This must be changed if you change the size of the play area, unrelated to window size
const player_start_position = Vector2(384,920) #Player position when starting a stage
const initial_player_health : float = 100
const graze_score_increment : float = 1 #How much score the player gains per second grazing an enemy or bullet
const graze_distance : float = 50 #How close the player needs to be to gain graze score


#Functions
func _begin_stage() -> bool:
	if(level_index<levels.size()):
		player_char_index = 0
		game_state = 1
		playfield._begin_stage()
		player_health = initial_player_health
		score = 0
		return true
	else:
		return false
