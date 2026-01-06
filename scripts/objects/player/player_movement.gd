extends CharacterBody2D
class_name Player

enum States {
	# When running on a flat surface
	RUNNING,
	# When sliding on a slope
	SLIDING,
	# When jump is first called, lasts one frame
	JUMPING,
	# After jump is first called
	JUMPED,
	# After an amount of time after JUMPED
	FALLING,
	# When fast dropping, lasts one frame
	DROPPING,
	# When attacking
	ATTACKING,
	# When colliding with an Obstacle
	DAMAGED,
	# When the damaged phase is over, lasts one frame
	RECOVERED
}

var state:States
var prev_state:States

var speed:float = 200.0
var speed_increase:float = 1.0
var speed_mod:float = 0.0
var speed_boost:float = 0.0
const JUMP_VELOCITY:float = -450.0
var jump_mod:float = 0.0

var time_since_left_ground:float = 0.0
const COYOTE_TIME:float = 0.15

var time_since_hit:float = 0.0
var DAMAGE_TIME:float = 0.5
var stagger_velocity:float = -200.0

var time_since_state_switch:float = 0.0
var prev_time_since_state_switch:float = 0.0

var time_since_step_sound:float = 0.0

var attack_length:float = 64.0
var attack_cooldown:float = 0.5
var time_since_attack:float = 0.0
const ATTACK_DURATION:float = 0.15

var damage_base: float = 200.0 
var damage_mult: float = 1.0
var damage_mod: float = 0.0 

#temporary invincibility upgrade
var invul_time: float = 10.0
var time_since_invulstart: float = 0.0
var ignore_damage_calc = false

func _ready() -> void: #these will be from the shop yup
	# upgrade_get("speed")
	upgrade_get("temp_invul")

func _physics_process(delta: float) -> void:
	prev_state = state
	prev_time_since_state_switch = time_since_state_switch
	
	# STATE HANDLING
	if prev_state not in [States.DAMAGED]:
		if prev_state != States.ATTACKING:
			if is_on_floor():
				if $RayCast2D.get_collision_normal() == Vector2(0.0, -1.0):
					state = States.RUNNING
				else:
					state = States.SLIDING
			
			else:
				if prev_state in [States.JUMPING, States.JUMPED]:
					state = States.JUMPED
				else:
					state = States.FALLING
				
				if time_since_left_ground > 1:
					state = States.FALLING
		
		else:
			if time_since_attack > ATTACK_DURATION:
				state = States.RECOVERED
		
		if Input.is_action_just_pressed("jump") and (prev_state in [States.RUNNING, States.SLIDING] or time_since_left_ground < COYOTE_TIME):
			state = States.JUMPING
		
		if Input.is_action_just_pressed("attack") and time_since_attack > attack_cooldown + ATTACK_DURATION:
			state = States.ATTACKING
		
		if Input.is_action_just_pressed("drop") and prev_state in [States.JUMPED, States.FALLING] and $RayCast2D.is_colliding():
			state = States.DROPPING
	
	else:
		if time_since_hit > DAMAGE_TIME:
			state = States.RECOVERED

	# LOGIC
	
	if prev_state != state:
		time_since_state_switch = 0.0
	
	match state:
		States.JUMPING:
			velocity.y = JUMP_VELOCITY + jump_mod
			speed_mod = 0.0
			
			if prev_state == States.SLIDING and prev_time_since_state_switch > 0.4:
				$Sounds/SlideRelease.play()
			else:
				$Sounds/Jump.play()
		
		States.JUMPED:
			pass
		
		States.DROPPING:
			position.y = $RayCast2D.get_collision_point().y
			velocity.y = 0.0
			speed_mod = 0.0
		
		States.SLIDING:
			velocity.y = 0.0
			position.y = $RayCast2D.get_collision_point().y
			if prev_state != States.SLIDING:
				$Sounds/Slide.play()
		
		States.RUNNING:
			if prev_state != States.RUNNING:
				$Sounds/Run.play()
				time_since_step_sound = 0.0
			
			if speed < 1000.0 and $SpriteOffsets2D.animation != "run_slow":
				$SpriteOffsets2D.play("run_slow")
			elif speed >= 1000.0 and $SpriteOffsets2D.animation != "run_fast":
				$SpriteOffsets2D.play("run_fast")
			
			time_since_step_sound += delta
			if time_since_step_sound > 0.3:
				$Sounds/Run.play()
				time_since_step_sound = 0.0
		
		States.FALLING:
			pass
		
		States.DAMAGED:
			pass
		
		States.RECOVERED:
			pass
		
		States.ATTACKING:
			velocity.y = 0.0
			
			if is_on_floor():
				speed_mod = get_speed_mod_of_platform()
			else:
				speed_mod = 0.0
			
			if prev_state != States.ATTACKING:
				time_since_attack = 0.0
				$Attack.attack()
		
		_:
			print("unhandled player state")

	if state != States.SLIDING and prev_state == States.SLIDING:
		$Sounds/Slide.stop()
		
	speed += speed_increase + speed_mod + speed_boost
	
	if is_on_floor():
		speed_mod = get_speed_mod_of_platform()
	else:
		speed_mod = 0.0
		if state != States.ATTACKING:
			velocity += get_gravity() * delta
			
	if time_since_invulstart > invul_time && ignore_damage_calc:
		upgrade_get("temp_invul_over")
	
	velocity.x = speed

	move_and_slide()

func _process(delta: float) -> void:
	if not is_on_floor():
		time_since_left_ground += delta
	else:
		time_since_left_ground = 0.0
	
	time_since_attack += delta
	time_since_hit += delta
	time_since_state_switch += delta
	time_since_invulstart += delta
	
	PlayerVariables.speed = speed
	PlayerVariables.speed_mod = speed_mod
	PlayerVariables.speed_boost = speed_boost
	PlayerVariables.speed_increase = speed_increase
	PlayerVariables.player_pos = position
	PlayerVariables.player_state = States.keys()[state]

func get_speed_mod_of_platform() -> float:
	if ($RayCast2D.is_colliding()):
		if ($RayCast2D.get_collider() is Platform):
			var platform:Platform = $RayCast2D.get_collider()
			return platform.get_speed_modifier()
		else:
			return 0.0
	else:
		return 0.0

func damage(speed_impact:float) -> void:
	print("im damaged")
	state = States.DAMAGED
	if speed >= 1000:
		var _speedo
		_speedo = int(floor(speed)) - int(floor(speed)) % 1000 #every 1000 on speed, sets mult
		damage_mult = _speedo / 1000
	else:
		damage_mult = 1.0
	if ignore_damage_calc == false:
		PlayerVariables.damageTaken = speed_impact * (damage_mult + damage_mod)
		velocity.y = stagger_velocity
	speed -= PlayerVariables.damageTaken
	PlayerVariables.speed = speed
	time_since_hit = 0.0

func upgrade_get(upgrade:String) -> void:
	PlayerVariables.inventory.append(upgrade)
	match upgrade: #upgrades go here bro
		"speed":
			speed_increase += 1.0
		"defense":
			damage_mod -= 0.5
			stagger_velocity -= 100
		"temp_invul":
			time_since_invulstart = 0.0
			speed_boost += 3.0
			ignore_damage_calc = true
			DAMAGE_TIME = 0
			print("invulstart")
		"temp_invul_over":
			PlayerVariables.inventory.erase("temp_invul")
			speed_boost = 0.0
			ignore_damage_calc = false
			DAMAGE_TIME = 0.5
			PlayerVariables.inventory.erase("temp_invul_over")
			print("invulover")
	PlayerVariables.invString = ", ".join(PlayerVariables.inventory)
			
