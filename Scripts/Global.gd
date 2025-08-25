extends Node

#Variables
var player : GameEntity = null
var ui = null

var player_chars = [] #List of playerentity classes for the player that they can switch between
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

var score : int = 0 :
	set(value):
		score = value
		if(ui != null):
			ui._update_score()
	get:
		return score


var levels = [] #List of available levels
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
