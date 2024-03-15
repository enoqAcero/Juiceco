extends Node2D

@onready var item_scene := load("res://Scenes/PurchaseItem.tscn")
@onready var upgrades_list := $Panel/ScrollContainer/VBoxContainer

func _ready():
#	reset()
	fill_upgrades_list()
	
	initialize_upgrades()

func fill_upgrades_list():
	
	clean_list()
	
	for i in GlobalVariables.player.Upgrades.size():
		
		var upgrade = GlobalVariables.player.Upgrades[i]
		
		if upgrade == null:
			GlobalVariables.player.Upgrades[i] = UpdateData.new()
			upgrade = GlobalVariables.player.Upgrades[i]
			
		if upgrade.epic or upgrade.active:
			continue
		
		var item = item_scene.instantiate()

		item.get_node("Icon").texture = upgrade.skin
		item.get_node("Button").text = GlobalVariables.getMoneyString( upgrade.cost )
		item.get_node("Button").show()
		item.get_node("ButtonEpic").hide()
		item.get_node("Name").text = upgrade.name
		item.get_node("Description").text = upgrade.description

		if upgrade.cost > GlobalVariables.player.money:
			item.get_node("Button").disabled = true

		else:
			item.get_node("Button").pressed.connect( Callable(buy_upgrade).bind( i, false ) )

		upgrades_list.add_child( item )

func fill_epic_upgrades_list():
	
	clean_list()
	
	for i in GlobalVariables.player.Upgrades.size():
		
		var upgrade = GlobalVariables.player.Upgrades[i]
		
		if not upgrade.epic or upgrade.epic_active:
			continue

		var item = item_scene.instantiate()

		item.get_node("Icon").texture = upgrade.skin
		item.get_node("ButtonEpic").text = GlobalVariables.getMoneyString( upgrade.cost )
		item.get_node("Button").hide()
		item.get_node("ButtonEpic").show()
		item.get_node("Name").text = upgrade.name
		item.get_node("Description").text = upgrade.description

		if upgrade.cost > GlobalVariables.player.money:
			
			item.get_node("ButtonEpic").disabled = true

		else:
			item.get_node("ButtonEpic").pressed.connect( Callable(buy_upgrade).bind( i, true ) )
		
		upgrades_list.add_child( item )

func clean_list():
	for item in upgrades_list.get_children():
		item.queue_free()

func buy_upgrade(index:int, epic:bool):
	
	var upgrade = GlobalVariables.player.Upgrades[index]
	
	
	print(index)	
	
	if GlobalVariables.player.money >= upgrade.cost:
		GlobalVariables.player.money -= upgrade.cost
		if epic:
			GlobalVariables.player.Upgrades[index].epic_active = true
			fill_epic_upgrades_list()
		else:
			GlobalVariables.player.Upgrades[index].active = true
			fill_upgrades_list()
			
		
		if upgrade.type == GlobalVariables.UpgradeType.FEATURE:
			enable_feature_upgrade( index )
			
			GlobalVariables.save()

func initialize_upgrades():

	for i in range( GlobalVariables.player.Upgrades.size() ):
		var upgrade = GlobalVariables.player.Upgrades[i]
		if upgrade.active:
			enable_feature_upgrade( i )

func enable_feature_upgrade( index ):
	match index:
		0: # Enable the fruit race switch
			var run_switch = get_parent().get_node("runButton")
			run_switch.toggle_mode = true
			run_switch.button_pressed = true
			print( "Enabling race switch" )

func _on_close_button_pressed():
	hide()

func _on_button_pressed():
	fill_upgrades_list()

func _on_button_2_pressed():
	fill_epic_upgrades_list()

func reset():
	for upgrade in GlobalVariables.player.Upgrades:
		if upgrade != null:
			upgrade.active = false
			upgrade.epic_active = false
