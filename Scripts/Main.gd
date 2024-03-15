extends Node2D

var rng = RandomNumberGenerator.new()


var controlEscenasField = false
var controlEscenasUpgrades = false
var controlEscenasBoost = false
var controlEscenasMenu = false
var controlEscenasShop = false
var controlEscenasModalJuiceLvl = false

var totalTransportCapacity = 0
var totalJuiceHouseCapacity = 0

var mango = preload("res://Scenes/Fruits/Mango.tscn")
var aguacate = preload("res://Scenes/Fruits/Aguacate.tscn")
var cereza = preload("res://Scenes/Fruits/Cereza.tscn")
var blueberry = preload("res://Scenes/Fruits/Blueberry.tscn")
var coco = preload("res://Scenes/Fruits/Coco.tscn")
var dragonfruit = preload("res://Scenes/Fruits/Dragonfruit.tscn")
var durazno = preload("res://Scenes/Fruits/Durazno.tscn")
var fresa = preload("res://Scenes/Fruits/Fresa.tscn")
var limon = preload("res://Scenes/Fruits/Limon.tscn")
var manzana = preload("res://Scenes/Fruits/Manzana.tscn")
var melon = preload("res://Scenes/Fruits/Melon.tscn")
var naranja = preload("res://Scenes/Fruits/Naranja.tscn")
var papaya = preload("res://Scenes/Fruits/Papaya.tscn")
var pina = preload("res://Scenes/Fruits/Pina.tscn")
var sandia = preload("res://Scenes/Fruits/Sandia.tscn")
var fruits = [ blueberry, cereza, fresa, limon, durazno, manzana, naranja, aguacate, mango, dragonfruit, coco, pina, papaya, melon, sandia ]
var fruitInstance = []
var runTimerNode
var runButton
var runButtonControl = false

var multiplierOn = false
var multiplierLabel
var juiceLevelLabel
var juiceLevelIcon

var farmValue : float = 0.0

@onready var spawn_spots := $NavigationRegion2D/Spawners.get_children()
var spawn_list : Array

@onready var field := $CanvasLayer/Field
@onready var upgrades := $CanvasLayer/Upgrades
@onready var boosts := $CanvasLayer/Boost
@onready var shop := $CanvasLayer/Shop
@onready var garage := $CanvasLayer/Garage
@onready var houses := $CanvasLayer/JuiceHouse

func _ready():
	
	runTimerNode = $CanvasLayer/runButton/RunTimer
	runButton = $CanvasLayer/runButton
	multiplierLabel = $CanvasLayer/Multiplier
	juiceLevelLabel = $CanvasLayer/JuiceLvl/Level
	juiceLevelLabel.text = GlobalVariables.player.JuiceLevel[GlobalVariables.player.juiceLevel].name
	juiceLevelIcon = $CanvasLayer/JuiceLvl/Icon
	
	GlobalVariables.loadResource()
	SignalManager.loadData.connect(loadData)
	
	SignalManager.loadData.emit()
	SignalManager.loadHouses.emit()
	
	spawn_spots.reverse()
	
	load_houses()
	


func _process(_delta):

	# Control del marcador del multiplicador		
#	if GlobalVariables.multiplier <= GlobalVariables.multiplierSteps/10:
#		GlobalVariables.multiplier = 0

	# Actualizacion del marcador del multiplicador
#	if GlobalVariables.multiplier > 0:
#		multiplierLabel.text = "x " + str("%.1f" % GlobalVariables.multiplier)
	
	# Actualizacion del icono de jugo
	juiceLevelIcon.texture = GlobalVariables.player.JuiceLevel[GlobalVariables.player.juiceLevel].skin

func load_houses():
	for i in range( GlobalVariables.player.CurrentJuiceHouse.size() ):
		
		get_node("house" + str(i)).hide()
		
		var house = GlobalVariables.player.CurrentJuiceHouse[i]
		if house.type > 0:
			get_node("house" + str(i)).show()
			get_node("house" + str(i)).show_type( house.type )
			
#obtener la capacidad total de los transportes
func getTotalTransportCapacity():
	totalTransportCapacity = 0
	var trasportIdArray = [GlobalVariables.player.transport0Id, GlobalVariables.player.transport1Id,GlobalVariables.player.transport2Id,GlobalVariables.player.transport3Id,GlobalVariables.player.transport4Id,GlobalVariables.player.transport5Id,GlobalVariables.player.transport6Id,GlobalVariables.player.transport7Id,GlobalVariables.player.transport8Id,GlobalVariables.player.transport9Id,GlobalVariables.player.transport10Id,GlobalVariables.player.transport11Id,GlobalVariables.player.transport12Id,GlobalVariables.player.transport13Id,GlobalVariables.player.transport14Id]
	
	for i in range (0, trasportIdArray.size()):
		if trasportIdArray[i] >= 1:
			var id = trasportIdArray[i]
			totalTransportCapacity += GlobalVariables.player.Transport[id - 1].capacity

#obtener la capacidad total de las casas de jugo
func getJuiceHouseCapacity():
	totalJuiceHouseCapacity = 0
	GlobalVariables.houseCount = 0
	
	for i in range (4):
		if GlobalVariables.player.CurrentJuiceHouse[i].type >= 1:
			GlobalVariables.houseCount += 1
			var id = GlobalVariables.player.CurrentJuiceHouse[i].type
			totalJuiceHouseCapacity += GlobalVariables.player.JuiceHouse[id - 1].capacity
	if GlobalVariables.houseCount >= 3:
		GlobalVariables.houseCount = 3	
				
#func countFruits():
#	for i in range(GlobalVariables.player.Fruits.size()):
#		GlobalVariables.total_fruit_count[i] = 0
#
#	var house_array = range(4)
#	for i in house_array:
#		if house_array[i] >= 1:
#			for j in range(GlobalVariables.player.Fruits.size()):
#				GlobalVariables.total_fruit_count[j] += GlobalVariables.player.CurrentJuiceHouse[i].fruit_count[j]
#				GlobalVariables.totalFruits += GlobalVariables.total_fruit_count[j]

func calculateMoneyFromLiters(litrosPorSegundo : float):

	var currentJuiceLevel = GlobalVariables.player.juiceLevel
	var earningBonus = 1 + (GlobalVariables.player.seeds/100)
	var moneyString : String
	var multGananciasMultiplier = 1
	
	if GlobalVariables.player.multGananciasActive == true:
		multGananciasMultiplier = 2
		
	#print("litros multiplier: ",multGananciasMultiplier)
	if litrosPorSegundo >= totalTransportCapacity:
		litrosPorSegundo = totalTransportCapacity
		GlobalVariables.maxTransportCapacity = true 
	
	
#	GlobalVariables.player.money += ((litrosPorSegundo * GlobalVariables.player.JuiceLevel[currentJuiceLevel].value * (GlobalVariables.multiplier + 1)) * multGananciasMultiplier) * earningBonus
	moneyString = GlobalVariables.getMoneyString(GlobalVariables.player.money)
	$CanvasLayer/JuiceLvl/Money.text = "$ " + moneyString
	moneyString = GlobalVariables.getMoneyString(litrosPorSegundo * multGananciasMultiplier * earningBonus)
	$CanvasLayer/moneyPerSec.text = "MoneyPerSec: " + moneyString


#esta  funcion se manda a ejecturar despues de cargar el recurso en la variabale player
#se usa para evitar utilizar una variable antes de cargar los datos de player
func loadData():
	getTotalTransportCapacity()
	getJuiceHouseCapacity()
#	countFruits()


func _notification(what):
	return
#	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
#		GlobalVariables.player.time = Time.get_datetime_string_from_system()
#		save()
#		get_tree().paused = true
#	if what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_READY:
#		get_tree().paused = false
#		calculateTime()

func calculateTime():
	var maxTime = GlobalVariables.player.WaterTank.time * GlobalVariables.player.WaterTank.count
	var prevTime = Time.get_unix_time_from_datetime_string(GlobalVariables.player.time)
	var currentTime = Time.get_unix_time_from_datetime_string(Time.get_datetime_string_from_system())
	var elapsedTime = currentTime - prevTime
	
	var timeProgressBarNode = $CanvasLayer/WaterTank.get_node("Panel/ProgressBar")
	
	if maxTime <= elapsedTime:
		elapsedTime = maxTime
	
	timeProgressBarNode.max_value = maxTime
	timeProgressBarNode.value = (maxTime - elapsedTime)
	
	calculateMoneyFromTime(elapsedTime)

func calculateMoneyFromTime(elapsedTime):
	var moneyEarned = GlobalVariables.player.litersPerSecond * elapsedTime
	var earningBonus = 1 + (GlobalVariables.player.seeds/100)
	var moneyEarnedString : String
	var moneyEarnedLabel = $CanvasLayer/WaterTank.get_node("Panel/Money")
	
	moneyEarnedString = GlobalVariables.getMoneyString(moneyEarned)
	moneyEarnedLabel.text = "Money Earned: \n" + moneyEarnedString
	$CanvasLayer/WaterTank.show()
	GlobalVariables.player.money += moneyEarned * earningBonus
	calculateFruitsFromTime(elapsedTime)
#	save()
	
func calculateFruitsFromTime(elapsedTime):
	var frutasTotal : float = 0
	var litrosTotal : float = 0
	var fruitsEarnedString : String
	var fruitsEarnedLabel = $CanvasLayer/WaterTank.get_node("Panel/Fruits")
	
	var fruit_count : Array[int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	
	if not elapsedTime == 1:
		for i in range(fruit_count.size()):
			fruit_count[i] = ( elapsedTime / GlobalVariables.player.Fruits[i].speed ) * GlobalVariables.player.Fruits[i].level
			
			frutasTotal += fruit_count[i]
			
			for j in range( 0, GlobalVariables.houseCount ):
				if GlobalVariables.player.CurrentJuiceHouse[j].type >= 1:
					GlobalVariables.player.CurrentJuiceHouse[j].fruit_count[i] += (fruit_count[i] ) / GlobalVariables.houseCount
				else:
					GlobalVariables.player.CurrentJuiceHouse[i].fruit_count = 0
					
		if frutasTotal <= 999:
			fruitsEarnedString = str(frutasTotal)
		else:
			fruitsEarnedString = GlobalVariables.getMoneyString(frutasTotal)
		fruitsEarnedLabel.text = "Fruits Earned: \n" + fruitsEarnedString
		
			
	else:
		for i in range( GlobalVariables.player.Fruits.size() ):
			var fruit = GlobalVariables.player.Fruits[i]
#			fruit_count[i] = (elapsedTime / fruit.speed) * fruit.level *fruit.liters
		
	
#	countFruits()
	
	
func SandiasPorSeg(litros : float):
	var sandias : float
	sandias = litros/5047220699136000.00
	return sandias
	
# Oculta todas las escenas
func hideScene():
	$CanvasLayer/Field.visible = false
	$CanvasLayer/Upgrades.visible = false
	$CanvasLayer/Boost.visible = false
	$CanvasLayer/Menu.visible = false
	$CanvasLayer/Shop.visible = false
	$CanvasLayer/ModalJuiceLvl.visible = false

# Muestra la escena especificada
func showScene(scene, controlEscenas):
	hideScene()
	if !controlEscenas:
		scene.visible = true
	return !controlEscenas

#Abir Field
func _on_field_button_pressed():
	controlEscenasField = showScene($CanvasLayer/Field, controlEscenasField)
	$CanvasLayer/Field.loadAllPanelData()

#Abir Upgrades
func _on_upgrade_button_pressed():
	controlEscenasUpgrades = showScene($CanvasLayer/Upgrades, controlEscenasUpgrades)

#Abir Boosts
func _on_boost_button_pressed():
	controlEscenasBoost = showScene($CanvasLayer/Boost, controlEscenasBoost)

#Abir Menu
func _on_menu_button_pressed():
	controlEscenasMenu = showScene($CanvasLayer/Menu, controlEscenasMenu)

#Abir Shop
func _on_shop_button_pressed():
	controlEscenasShop = showScene($CanvasLayer/Shop, controlEscenasShop)


func juice_house_menu():
	$CanvasLayer/JuiceHouse.show()


func _on_button_2_pressed():
	$CanvasLayer/Garage.show()
	$CanvasLayer/Garage/VehicleList/ScrollContainer.fill_vehicle_list()


func _on_run_button_pressed():
	if runButtonControl == false:
		if instanceFruit():
			runTimerNode.start()
			runButtonControl = true
			runButton.get_node("Sprite2D").play("jump")
	
func instanceFruit():
	
	# Check if there is availbale space in any house
	var free_space = false
	for i in range(3):
		if GlobalVariables.player.CurrentJuiceHouse[i].type > 0 \
		and not GlobalVariables.player.CurrentJuiceHouse[i].is_full():
			free_space = true
	if not free_space : 
		return false
	
	# Pick a purchased target house
	var target_number : int
	var target_picked = false
	while not target_picked:
		target_number = randi_range(0,3)
		if GlobalVariables.player.CurrentJuiceHouse[target_number].type > 0 and \
		not GlobalVariables.player.CurrentJuiceHouse[target_number].is_full():
			target_picked = true

	var rand_i
	var available_fruits := false
	var fruit_picked := false
	
	# Check if any fruits have been acquired and produced
	for fruit in GlobalVariables.player.Fruits:
		if fruit.acquired:
			if fruit.produced_fruits >= 1:
				available_fruits = true

	if not available_fruits: return false

	# Check if any fruits have been produced and pick a type
	while not fruit_picked:
		
		rand_i = randi_range(0, fruits.size()-1)
		if GlobalVariables.player.Fruits[rand_i].acquired:
			if GlobalVariables.player.Fruits[rand_i].produced_fruits >= 1:
				fruit_picked = true
	
	var fruitType = fruits[rand_i]
	var fruit_run = fruitType.instantiate()
	var fruit_data = GlobalVariables.player.Fruits[rand_i]

	
	
	fruit_run.house = target_number
	fruit_run.set_collision_layer_value( target_number+1, true )
	fruit_run.set_collision_mask_value( target_number+1, true )
	print( "Aiming for house: " + str( target_number ) )
	
	
	fruit_run.liters = fruit_data.level + 1
	var res = fruit_data.produced_fruits - fruit_run.liters
	if res < 0:
		res = 0
		fruit_run.liters = fruit_data.produced_fruits
#	var mult = fruit_run.liters
	GlobalVariables.player.Fruits[rand_i].produced_fruits = res
	
	print( str( fruit_run.liters ) + " fruits before calculation" )
	fruit_run.liters *= fruit_data.liters_per_fruit
	
	# Apply juice multipliers
	# Tier multiplier
	fruit_run.liters += fruit_run.liters * fruit_data.tier_multipliers[rand_i]

	fruitInstance.append(fruit_run)
	
	# Scale multiplier
#	var tier = GlobalVariables.player.Fruits[ rand_i ].tier
#	var scales = [ 2.0, 3.0, 4.0, 4.5, 5.0 ]
#	var j = clamp( tier, 0, 4 )
#	fruit_run.scale = Vector2(scales[j], scales[j])
	fruit_run.scale = Vector2(2.5, 2.5)
	spawn_list.append(fruit_run)
	fruit_run.fruit_number = rand_i
	
	# Show fruit multiplier
	$CanvasLayer/JuiceLvl/FruitMultiplier.text = "x " + GlobalVariables.getMoneyString( fruit_run.liters ) + " L"
	$CanvasLayer/JuiceLvl/FruitMultiplier.show()
	$CanvasLayer/JuiceLvl/FruitMultiplier/FruitLabelMultTimer.start()
	
	return true

func fruit_spawner():
	
	if not spawn_list.is_empty():
		for spawner in spawn_spots:
			if not spawner.full:
				add_child(spawn_list[0])
				spawn_list[0].global_position = spawner.global_position
				spawn_list.pop_at(0)
				break
			else:
				continue


func _on_run_timer_timeout():
	runButtonControl = false


#func _on_produce_juice_timer_timeout():
#	var litros : float = 0.0
#	var litrosPorSegundo : float = 0.0
#
#	for i in range( GlobalVariables.player.Fruits.size() ):
#		litros = GlobalVariables.player.Fruits[i].produced_liters
#
#	litrosPorSegundo = litros * 0.1
#
#	GlobalVariables.player.litersPerSecond = litrosPorSegundo
#	calculateMoneyFromLiters(litrosPorSegundo)


func calculateFarmValue():
	getJuiceHouseCapacity()
	calculateFruitsFromTime(1)
	
	var farmValueString : String
	var houseCapacity = totalJuiceHouseCapacity
#	var P = GlobalVariables.total_fruit_count[14]
#	var Pc = P * ((GlobalVariables.player.litersPerSecond/GlobalVariables.player.sandiasPerSecond) * 60)
#	var Pu = (P - Pc)
#	var Pv = (houseCapacity - P)
	var Pp = ((GlobalVariables.player.sandiasPerSecond * 60)/4) * GlobalVariables.player.WaterTank.time
	var L = GlobalVariables.player.juiceLevel + 1
	var juiceValue = GlobalVariables.player.JuiceLevel[L -1].value
	var sandiasPerMin = GlobalVariables.player.sandiasPerSecond * 60
	var earningBonus = 1 + (GlobalVariables.player.seeds/100)
	var maxRunningFruitBonus = 5
	var maxRunningFruitBonusEq = ((maxRunningFruitBonus - 4)**0.25)


#	farmValue = 30000 * juiceValue * sandiasPerMin * earningBonus * maxRunningFruitBonusEq * L * (Pc + (0.2 * Pu) + (-1 * (abs(Pv)**0.6)) + (0.25 * Pp))
	
	GlobalVariables.player.farmValue = farmValue
	if farmValue <= 999:
		farmValueString = str(farmValue)
	else:
		farmValueString = GlobalVariables.getMoneyString(farmValue)
	$CanvasLayer/FarmValue.text = "FarmValue: " + farmValueString
	

func _on_timer_timeout():
	calculateFarmValue()


func _on_juice_lvl_pressed():
	controlEscenasModalJuiceLvl = showScene($CanvasLayer/ModalJuiceLvl, controlEscenasModalJuiceLvl)
	$CanvasLayer/ModalJuiceLvl.updateJuiceInfo()

func _on_spawn_timer_timeout():
	fruit_spawner()

func _on_check_money_timer_timeout():
	$CanvasLayer/JuiceLvl/Money.text = "$ " + GlobalVariables.getMoneyString( GlobalVariables.player.money )
	$CanvasLayer/Field.loadAllPanelData()
#	$CanvasLayer/JuiceHouse.loadHouses()
#	GlobalVariables.save()
#	print("Saving changes")


func _on_fruit_label_mult_timer_timeout():
	$CanvasLayer/JuiceLvl/FruitMultiplier.text = ""
	$CanvasLayer/JuiceLvl/FruitMultiplier.hide()
	
func reset_game():
	field.reset()
	upgrades.reset()
	boosts.reset()
	shop.reset()
	garage.reset()
	houses.reset()
