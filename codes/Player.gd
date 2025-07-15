extends CharacterBody3D
class_name Player

const MOUSE_SENSITIVITY = 0.2
const WALKING_SPEED = 5.0
const ACCEL_AND_FRICTION = 20.0
const FLASHLIGHT_FOLLOW_SPEED = 10.0
const SPRINTING_SPEED_MULTIPLIER = 2.0

const MAX_STAMINA = 100
const SPRINT_STAMINA_COST = 10  # Quanto de stamina é consumido por segundo ao correr
const REGEN_STAMINA_RATE = 5    # Quanto de stamina é regenerado por segundo

var adjusted_mouse_sensitivity = 0.1
var idle_moving_blend = 0.0
var moving_speed_multiplier = 1.0
var flashlight_on = true
var stamina = MAX_STAMINA
var is_sprinting = false
@onready var camera = $HeadYPivot/HeadXPivot/CameraTilt/Camera3D
@onready var collider = $Collider
@onready var cam_raycast = $HeadYPivot/HeadXPivot/CameraTilt/Camera3D/CamRayCast
@onready var head_y_pivot = $HeadYPivot
@onready var head_x_pivot = $HeadYPivot/HeadXPivot
@onready var flashlight_pivot = $HeadYPivot/HeadXPivot/CameraTilt/FlashlightPivot
@onready var animation_tree = $AnimationTree
@onready var flashlight_light = $HeadYPivot/HeadXPivot/CameraTilt/FlashlightPivot/FlashlightLight
@onready var flashlight_sound = $FlashlightSound
@onready var ui = $UI
@onready var fader = $Fader
@onready var stamina_bar = $UI/StaminaBar  # Referência à barra de stamina
@export var pausescreen: CanvasLayer = null
var env: Environment

var is_dying = false

signal page_collected
signal orb_collected

func die():
	is_dying = true
	fader.set_playback_speed(0.15)
	fader.fade_out()

# Função chamada quando o jogador entra em contato com uma área
func on_area_entered(area): 
	
	if area.is_in_group("Orb"):  # Certifique-se de que os orbs estão no grupo "Orb"
		area.queue_free()  # Remove o orb da cena
		emit_signal("orb_collected")  # Emite o sinal de orb coletado

func on_fade_finished():
	get_tree().change_scene_to_file("res://src/menu_components/MainMenu.tscn")

func _ready():
	# carrega o Environment só depois de camera existir
	env = camera.environment if camera.environment else get_world_3d().environment
	collider.connect("area_entered", Callable(self, "on_area_entered"))
	fader.connect("fade_finished", Callable(self, "on_fade_finished"))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	adjusted_mouse_sensitivity = (1920 * MOUSE_SENSITIVITY) / get_viewport().get_visible_rect().size.x
	stamina_bar.max_value = MAX_STAMINA
	stamina_bar.value = stamina
	stamina_bar.visible = true  # Garante que a barra de stamina esteja visível inicialmente
	
	match GameSettings.difficulty:
		GameSettings.Difficulty.NORMAL:
			env.fog_density = 0.01  # quanto maior, mais denso o fog
		GameSettings.Difficulty.HARD:
			env.fog_density = 0.40  # quanto maior, mais denso o fog
		GameSettings.Difficulty.EXTREME:
			env.fog_density = 1.00  # quanto maior, mais denso o fog

func _input(event):
	if event is InputEventMouseMotion:
		head_y_pivot.rotation_degrees.y += event.relative.x * -adjusted_mouse_sensitivity
		head_x_pivot.rotation_degrees.x += event.relative.y * -adjusted_mouse_sensitivity
		head_x_pivot.rotation_degrees.x = clamp(head_x_pivot.rotation_degrees.x, -80, 80)

func _physics_process(delta):
	movement_step(delta)
	flashlight_step(delta)
	interaction_step()
	update_stamina(delta)

func movement_step(delta):
	var input_vector = Input.get_vector("movement_left", "movement_right", "movement_forward", "movement_backward")
	var head_y_pivot_basis = head_y_pivot.global_basis
	var direction = (head_y_pivot_basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()

	if Input.is_action_pressed("sprint") and input_vector.length() > 0 and stamina > 0:
		is_sprinting = true
		moving_speed_multiplier = SPRINTING_SPEED_MULTIPLIER
	else:
		is_sprinting = false
		moving_speed_multiplier = 1.0

	var target_velocity = direction * WALKING_SPEED * moving_speed_multiplier
	velocity = lerp(velocity, target_velocity, delta * ACCEL_AND_FRICTION)
	move_and_slide()

	idle_moving_blend = lerp(idle_moving_blend, direction.length(), delta * ACCEL_AND_FRICTION)
	animation_tree.set("parameters/IdleMoving/blend_amount", idle_moving_blend)
	animation_tree.set("parameters/MovingSpeed/scale", moving_speed_multiplier)

func update_stamina(delta):
	if is_sprinting:
		stamina -= SPRINT_STAMINA_COST * delta
		stamina = max(stamina, 0)  # Garante que a stamina não fique abaixo de 0
	else:
		stamina += REGEN_STAMINA_RATE * delta
		stamina = min(stamina, MAX_STAMINA)  # Garante que a stamina não ultrapasse o máximo

	# Atualiza o valor da barra de stamina
	stamina_bar.value = stamina

	# Controla a visibilidade da barra de stamina
	if stamina == MAX_STAMINA:
		stamina_bar.visible = false
	else:
		stamina_bar.visible = true

func flashlight_step(delta):
	flashlight_pivot.global_transform.basis = (
		lerp(flashlight_pivot.global_transform.basis, 
		head_x_pivot.global_transform.basis, 
		delta * FLASHLIGHT_FOLLOW_SPEED)
	)
	if Input.is_action_just_pressed("flashlight_toggle"):
		flashlight_on = not flashlight_on
		flashlight_light.visible = flashlight_on
		flashlight_sound.play()

func interaction_step():
	var raycast_collider = cam_raycast.get_collider()
	
	if raycast_collider and raycast_collider is Interactable:
		ui.set_interaction_text_visible(true)
		ui.set_interaction_label_text(raycast_collider.interaction_prompt_text)
		
		if Input.is_action_just_pressed("interact"):
			raycast_collider.interacted_with()
	else:
		ui.set_interaction_text_visible(false)
