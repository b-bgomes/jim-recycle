local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject() end)

PlayerJob = {}
onDuty = false
Peds = {}
Targets = {}
searchProps = {}
Props = {}
local TrollyProp = nil



RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job if PlayerData.job.name == Config.JobRole then onDuty = PlayerJob.onduty end end)
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty) if Config.JobRole then if PlayerJob.name == Config.JobRole then onDuty = duty end end end)

AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() ~= resource then return end
	QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job if PlayerData.job.name == Config.JobRole then onDuty = PlayerJob.onduty end end)
end)

--- Blips + Peds
CreateThread(function()
	JobLocation = PolyZone:Create({
		vec2(992.39141845703, -3113.3854980469),
		vec2(1028.5169677734, -3113.1450195312),
		vec2(1027.978515625, -3088.9782714844),
		vec2(992.19049072266, -3089.8234863281)
	},
	{ name = "Recycling", debugPoly = Config.Debug })
	JobLocation:onPlayerInOut(function(isPointInside)
		if not isPointInside then
			EndJob() ClearProps()
			if Config.Debug then print("^5Debug^7: ^3PolyZone^7: ^2Leaving Area^7. ^2Clocking out and cleaning up^7") end
			if Config.JobRole then
				if onDuty then TriggerServerEvent("QBCore:ToggleDuty") end
			elseif onDuty == true then
				onDuty = false
			end
		else MakeProps()
		end
	end)

	for _, v in pairs(Config.Locations) do
		for i = 1, #v do
			local v = v[i]
			if Config.Blips and v.blipTrue then blip = makeBlip({coords = v.coords, sprite = v.sprite, col = v.col, name = v.name})	end
			if Config.Pedspawn then
				if not Peds[v.name..i] then
					loadModel(v.model)
					Peds[v.name..i] = makePed(v.model, v.coords, true, false, v.scenario, nil)
				end
			end
		end
	end
	--Make Targets
	local price = "" if Config.PayAtDoor then price = " ($"..Config.PayAtDoor..")" end
	Targets["RecyclingEnter"] =
		exports['qb-target']:AddBoxZone("RecyclingEnter", vec3(746.82, -1398.93, 26.55), 0.4, 1.6, { name="RecyclingEnter", debugPoly=Config.Debug, minZ=25.2, maxZ=28.0 },
			{ options = { { event = "jim-recycle:TeleWareHouse", icon = "fas fa-recycle", label = Loc[Config.Lan].target["enter"]..price, enter = true, job = Config.JobRole }, },
			distance = 1.5 })

	Targets["RecyclingExit"] =
		exports['qb-target']:AddBoxZone("RecyclingExit", vec3(991.97, -3097.81, -39.0), 1.6, 0.4, { name="RecyclingExit", debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-recycle:TeleWareHouse", icon = "fas fa-recycle", label = Loc[Config.Lan].target["exit"], enter =  false }, },
			distance = 1.5 })

	Targets["RecycleDuty"] =
		exports['qb-target']:AddCircleZone("RecycleDuty", vec3(995.36, -3099.91, -39.2), 0.45, { name="RecycleDuty", debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-recycle:dutytoggle", icon = "fas fa-hard-hat", label = Loc[Config.Lan].target["duty"], job = Config.JobRole }, },
			distance = 1.5 })
	--Recyclable Material Trader
	for i = 1, #Config.Locations["Trade"] do
		Targets["Trade"..i] =
			exports['qb-target']:AddCircleZone("Trade"..i, Config.Locations["Trade"][i].coords.xyz, 1.1, { name="Trade"..i, debugPoly=Config.Debug, useZ=true, },
				{ options = { { event = "jim-recycle:Trade:Menu", icon = "fas fa-box", label = Loc[Config.Lan].target["trade"]  }, },
				distance = 1.5 })
	end
	--[[--Sell Materials
	for i = 1, #Config.Locations["Recycle"] do
		Targets["Recycle"..i] =
			exports['qb-target']:AddCircleZone("Recycle"..i, Config.Locations["Recycle"][i].coords.xyz, 1.1, { name="Recycle"..i, debugPoly=Config.Debug, useZ=true, },
				{ options = { { event = "jim-recycle:Selling:Menu", icon = "fas fa-box", label = Loc[Config.Lan].target["sell"] }, },
				distance = 2.5 })
	end
	--Bottle Selling Third Eyes
	for i = 1, #Config.Locations["BottleBanks"] do
		Targets["BottleBank"..i] =
			exports['qb-target']:AddCircleZone("BottleBank"..i, Config.Locations["BottleBanks"][i].coords.xyz, 1.2,	{ name="BottleBank"..i, debugPoly=Config.Debug, useZ=true, },
				{ options = { { event = "jim-recycle:Bottle:Menu", icon = "fas fa-certificate", label = Loc[Config.Lan].target["sell_bottles"], job = Config.JobRole  }, },
				distance = 1.5 })
	end]]
end)

---- Render Props -------
function MakeProps()
	--Floor Level Props (Using these for the selection pool)
	if Config.Debug then print("^5Debug^7: ^3MakeProps^7() ^2Spawning props") end
	local propTable = {
		"ex_Prop_Crate_Bull_SC_02",
		"ex_prop_crate_wlife_bc",
		"ex_Prop_Crate_watch",
		"ex_Prop_Crate_SHide",
		"ex_Prop_Crate_Oegg",
		"ex_Prop_Crate_MiniG",
		"ex_Prop_Crate_FReel",
		"ex_Prop_Crate_Closed_BC",
		"ex_Prop_Crate_Jewels_BC",
		"ex_Prop_Crate_Art_02_SC",
		"ex_Prop_Crate_clothing_BC",
		"ex_Prop_Crate_biohazard_BC",
		"ex_Prop_Crate_Bull_BC_02",
		"ex_Prop_Crate_Art_BC",
		"ex_Prop_Crate_Money_BC",
		"ex_Prop_Crate_clothing_SC",
		"ex_Prop_Crate_Art_02_BC",
		"ex_Prop_Crate_Money_SC",
		"ex_Prop_Crate_Med_SC",
		"ex_Prop_Crate_Jewels_racks_BC",
		"ex_Prop_Crate_Jewels_SC",
		"ex_Prop_Crate_Med_BC",
		"ex_Prop_Crate_Gems_SC",
		"ex_Prop_Crate_Elec_SC",
		"ex_Prop_Crate_Tob_SC",
		"ex_Prop_Crate_Gems_BC",
		"ex_Prop_Crate_biohazard_SC",
		"ex_Prop_Crate_furJacket_SC",
		"ex_Prop_Crate_Expl_bc",
		"ex_Prop_Crate_Elec_BC",
		"ex_Prop_Crate_Tob_SC",
		"ex_Prop_Crate_Closed_BC",
		"ex_Prop_Crate_Narc_BC",
		"ex_Prop_Crate_Narc_SC",
		"ex_Prop_Crate_Tob_BC",
		"ex_Prop_Crate_furJacket_BC",
		"ex_Prop_Crate_HighEnd_pharma_BC",
	}
	for location in pairs(Config.Locations["Centres"]) do local loc = Config.Locations["Centres"][location]
		for i = 1, #loc.SearchLocations do
			searchProps[#searchProps+1] = makeProp({prop = propTable[math.random(1, #propTable)], coords = loc.SearchLocations[i]}, 1, 0)
		end
		for i = 1, #loc.ExtraPropLocations do
			Props[#Props+1] = makeProp({prop = propTable[math.random(1, #propTable)], coords = loc.ExtraPropLocations[i]}, 1, 0)
		end
	end
	for k in pairs(Config.scrapPool) do loadModel(Config.scrapPool[k].model) end
	--TrollyProp = makeProp({prop = "ex_Prop_Crate_Closed_BC", coords = vector4(999.32, -3093.2, -39.78, 166.38)}, 1, 0)
end

function EndJob()
	if Targets["Package"] then exports["qb-target"]:RemoveTargetEntity(randPackage) end
	if TrollyProp then destroyProp(TrollyProp) TrollyProp = nil end
	for i = 1, #searchProps do SetEntityDrawOutline(searchProps[i], false) end
	randPackage = nil
	if scrapProp then
		destroyProp(scrapProp)
		scrapProp = nil
	end
end

function ClearProps()
	if Config.Debug then print("^5Debug^7: ^3ClearProps^7() ^2Exiting building^7, ^2clearing previous props ^7(^2if any^7)") end
	for _, v in pairs(searchProps) do unloadModel(GetEntityModel(v)) DeleteObject(v) end searchProps = {}
	for _, v in pairs(Props) do unloadModel(GetEntityModel(v)) DeleteObject(v) end Props = {}
	for k in pairs(Config.scrapPool) do unloadModel(Config.scrapPool[k].model) end
	if Targets["DropOff"] then exports["qb-target"]:RemoveTargetEntity(TrollyProp) end
	unloadModel(GetEntityModel(TrollyProp)) DeleteObject(TrollyProp)
end

--Pick one of the crates for the player to choose, generate outline + target
function PickRandomPackage()
	if not TrollyProp then
		loadModel(`ex_Prop_Crate_Closed_BC`)
		TrollyProp = CreateObject(`ex_Prop_Crate_Closed_BC`, 999.32, -3093.2, -39.78, 0, 0, 0) FreezeEntityPosition(TrollyProp, true) SetEntityHeading(TrollyProp, 166.38)
	end
	--If somehow already exists, remove target
	if Targets["Package"] then exports["qb-target"]:RemoveTargetEntity(randPackage, "Search") end
	--Pick random prop to use
	randPackage = searchProps[math.random(1, #searchProps)]
	SetEntityDrawOutline(randPackage, true)
	SetEntityDrawOutlineColor(0, 255, 0, 1.0)
	SetEntityDrawOutlineShader(1)
	--Generate Target Location on the selected package
	Targets["Package"] =
		exports['qb-target']:AddTargetEntity(randPackage,
			{ options = { { event = "jim-recycle:PickupPackage:Start", icon = 'fas fa-magnifying-glass', label = Loc[Config.Lan].target["search"], } },
			distance = 2.5,	})
			print("done")
end
--Event to enter and exit warehouse
RegisterNetEvent("jim-recycle:TeleWareHouse", function(data)
	if data.enter then
		if Config.EnableOpeningHours then
			local ClockTime = GetClockHours()
			if ClockTime >= Config.OpenHour and ClockTime <= Config.CloseHour - 1 then
				if (ClockTime >= Config.OpenHour and ClockTime < 24) or (ClockTime <= Config.CloseHour -1 and ClockTime > 0) then
					if Config.PayAtDoor then
						local p = promise.new()	QBCore.Functions.TriggerCallback("jim-recycle:GetCash", function(cb) p:resolve(cb) end)
						if Citizen.Await(p) >= Config.PayAtDoor then TriggerServerEvent("jim-recycle:DoorCharge")
						else TriggerEvent("QBCore:Notify", Loc[Config.Lan].error["no_money"], "error") return end
					end
					DoScreenFadeOut(500)
					while not IsScreenFadedOut() do	Citizen.Wait(10) end
					SetEntityCoords(PlayerPedId(), Config.InsideTele)
					DoScreenFadeIn(500)
				else
					TriggerEvent("QBCore:Notify", Loc[Config.Lan].error["wrong_time"]..Config.OpenHour..":00am"..Loc[Config.Lan].error["till"]..Config.CloseHour..":00pm", "error")
				end
			else
				TriggerEvent("QBCore:Notify", Loc[Config.Lan].error["wrong_time"]..Config.OpenHour..":00"..Loc[Config.Lan].error["till"]..Config.CloseHour..":00pm", "error")
			end
		else
			DoScreenFadeOut(500)
			while not IsScreenFadedOut() do	Citizen.Wait(10) end
			SetEntityCoords(PlayerPedId(), Config.InsideTele)
			DoScreenFadeIn(500)
		end
	else
		EndJob() -- Resets outlines + targets if needed
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do	Citizen.Wait(10) end
		if onDuty then TriggerEvent('jim-recycle:dutytoggle') end
		SetEntityCoords(PlayerPedId(), Config.OutsideTele)
		DoScreenFadeIn(500)
	end
end)

RegisterNetEvent("jim-recycle:PickupPackage:Start", function()
	TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_MEDIC_KNEEL", 0, true)
	QBCore.Functions.Progressbar("open_locker_drill", Loc[Config.Lan].progressbar["search"], 5000, false, true, {
		disableMovement = true,	disableCarMovement = true, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
		ClearPedTasksImmediately(PlayerPedId())
		TriggerEvent("jim-recycle:PickupPackage:Hold")
	end, function() -- Cancel
	end, "fas fa-magnifying-glass")
end)
RegisterNetEvent("jim-recycle:PickupPackage:Hold", function()
	--Clear current target info
	exports["qb-target"]:RemoveTargetEntity(randPackage, "Search")
	SetEntityDrawOutline(randPackage, false)
	randPackage = nil

	--Make prop to put in hands
	loadAnimDict("anim@heists@box_carry@")
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
	v = Config.scrapPool[math.random(1, #Config.scrapPool)]
    loadModel(v.model)
    scrapProp = CreateObject(v.model, GetEntityCoords(PlayerPedId(), true), true, true, true)
    AttachEntityToEntity(scrapProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 18905), v.xPos, v.yPos, v.zPos, v.xRot, v.yRot, v.zRot, 20.0, true, true, false, true, 1, true)
	--Create target for drop off location
	SetEntityDrawOutline(TrollyProp, true)
	SetEntityDrawOutlineColor(255, 255, 255, 1.0)
	SetEntityDrawOutlineShader(1)
	Targets["DropOff"] =
		exports['qb-target']:AddTargetEntity(TrollyProp,
		{ options = { { event = "jim-recycle:PickupPackage:Finish", icon = 'fas fa-recycle', label = Loc[Config.Lan].target["drop_off"], } },
		distance = 2.5,	})

end)

RegisterNetEvent("jim-recycle:PickupPackage:Finish", function()
	--Once this is triggered it can't be stopped, so remove the target and prop
	if Targets["DropOff"] then exports["qb-target"]:RemoveTargetEntity(TrollyProp, Loc[Config.Lan].target["drop_off"]) Targets["DropOff"] = nil end
	SetEntityDrawOutline(TrollyProp, false) destroyProp(TrollyProp) TrollyProp = nil
	--Remove target and the whole prop, seen as how no ones qb-target works and its my fault 😊
	TrollyProp = CreateObject(`ex_Prop_Crate_Closed_BC`, 999.32, -3093.2, -39.78, 0, 0, 0) FreezeEntityPosition(TrollyProp, true) SetEntityHeading(TrollyProp, 166.38)

	--Load and Start animation
	local dict = "mp_car_bomb" loadAnimDict("mp_car_bomb")
	local anim = "car_bomb_mechanic"
    local isScrapping = true
	FreezeEntityPosition(PlayerPedId(), true)
	Wait(100)
	TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, 3.0, -1, 2.0, 0, 0, 0, 0)
	Wait(3000)
	--When animation is complete
	--Empty hands
	destroyProp(scrapProp)
    scrapProp = nil
	ClearPedTasks(PlayerPedId())
	FreezeEntityPosition(PlayerPedId(), false)
	TriggerServerEvent('jim-recycle:getrecyclablematerial') -- Give rewards
	PickRandomPackage()
end)

RegisterNetEvent('jim-recycle:dutytoggle', function()
	if Config.JobRole then
		if onDuty then EndJob() else PickRandomPackage() end
		TriggerServerEvent("QBCore:ToggleDuty")
	else
		onDuty = not onDuty
		if onDuty then TriggerEvent('QBCore:Notify', Loc[Config.Lan].success["on_duty"], 'success') PickRandomPackage()
		else TriggerEvent('QBCore:Notify', Loc[Config.Lan].error["off_duty"], 'error') EndJob() end
	end
end)

local Selling = false
RegisterNetEvent('jim-recycle:SellAnim', function(item)
	for _, v in pairs (Peds) do
		if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(v)) < 3 then
			Selling = true
			loadAnimDict("mp_common")
			loadAnimDict("amb@prop_human_atm@male@enter")
			if bag == nil then bag = makeProp({prop = `prop_paper_bag_small`, coords = vec4(0,0,0,0)}, 0, 1) end
			AttachEntityToEntity(bag, v, GetPedBoneIndex(v, 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
			--Calculate if you're facing the ped--
			ClearPedTasksImmediately(v)
			lookEnt(v)
			TaskPlayAnim(PlayerPedId(), "amb@prop_human_atm@male@enter", "enter", 1.0, 1.0, 0.3, 16, 0.2, 0, 0, 0)	--Start animations
            TaskPlayAnim(v, "mp_common", "givetake2_b", 1.0, 1.0, 0.3, 16, 0.2, 0, 0, 0)
			Wait(1000)
			AttachEntityToEntity(bag, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
            Wait(1000)
            StopAnimTask(PlayerPedId(), "amb@prop_human_atm@male@enter", "enter", 1.0)
			StopAnimTask(v, "mp_common", "givetake2_b", 1.0)
			TaskStartScenarioInPlace(v, "WORLD_HUMAN_CLIPBOARD", -1, true)
			unloadAnimDict("mp_common")
			unloadAnimDict("amb@prop_human_atm@male@enter")
			destroyProp(bag) unloadModel(`prop_paper_bag_small`)
			bag = nil
			for k in pairs(Config.Prices) do
				if k == item then TriggerServerEvent('jim-recycle:Selling:Mat', item) Selling = false return end
			end
			TriggerServerEvent("jim-recycle:TradeItems", item)
			Selling = false
		end
	end
end)

RegisterNetEvent('jim-recycle:Selling:Menu', function()
	if Selling then return end
	local sellMenu = {
		{ icon = "recyclablematerial", header = Loc[Config.Lan].menu["sell_mats"], txt = Loc[Config.Lan].menu["sell_mats_txt"], isMenuHeader = true },
		{ icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].menu["close"], params = { event = "jim-recycle:CloseMenu" } } }
	for k, v in pairsByKeys(Config.Prices) do
		sellMenu[#sellMenu+1] = {
			disabled = not HasItem(k, 1),
			icon = k,
			header = "<img src=nui://"..Config.img..QBCore.Shared.Items[k].image.." width=30px onerror='this.onerror=null; this.remove();'> "..QBCore.Shared.Items[k].label,
			txt = Loc[Config.Lan].menu["sell_all"]..v..Loc[Config.Lan].menu["each"],
			params = { event = "jim-recycle:SellAnim", args = k } }
	end
    exports['qb-menu']:openMenu(sellMenu)
end)

--Recyclable Trader
RegisterNetEvent('jim-recycle:Trade:Menu', function()
	if Selling then return end
	local p = promise.new() QBCore.Functions.TriggerCallback("jim-recycle:GetRecyclable", function(cb) p:resolve(cb) end) local amount = Citizen.Await(p)
	local tradeMenu = {
		{ icon = "recyclablematerial", header = Loc[Config.Lan].menu["mats_trade"], txt = Loc[Config.Lan].menu["trade_amount"]..amount, isMenuHeader = true },
		{ icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].menu["close"], params = { event = "jim-recycle:CloseMenu" } } }
	if amount >= 1 then tradeMenu[#tradeMenu+1] = { icon = "recyclablematerial", header = Loc[Config.Lan].menu["trade1"], params = { event = "jim-recycle:SellAnim", args = 1 } } end
	if amount >= 10 then tradeMenu[#tradeMenu+1] = { icon = "recyclablematerial", header = Loc[Config.Lan].menu["trade10"], params = { event = "jim-recycle:SellAnim", args = 2 } } end
	if amount >= 100 then tradeMenu[#tradeMenu+1] = { icon = "recyclablematerial", header = Loc[Config.Lan].menu["trade100"], params = { event = "jim-recycle:SellAnim", args = 3 } } end
	if amount >= 1000 then tradeMenu[#tradeMenu+1] = { icon = "recyclablematerial", header = Loc[Config.Lan].menu["trade1000"], params = { event = "jim-recycle:SellAnim", args = 4 } } end
	if #tradeMenu > 2 then exports['qb-menu']:openMenu(tradeMenu)
	else TriggerEvent("QBCore:Notify", Loc[Config.Lan].error["no_mats"], "error") end
end)

--Recyclable Trader
RegisterNetEvent('jim-recycle:Bottle:Menu', function()
	if Selling then return end
	local tradeMenu = {
		{ icon = "recyclablematerial", header = Loc[Config.Lan].menu["sell_mats"], txt = Loc[Config.Lan].menu["sell_mats_txt"], isMenuHeader = true },
		{ icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].menu["close"], params = { event = "jim-recycle:CloseMenu" } } }

	tradeMenu[#tradeMenu+1] = { disabled = not HasItem("can", 1), icon = "can", header = "<img src=nui://"..Config.img..QBCore.Shared.Items["can"].image.." width=30px onerror='this.onerror=null; this.remove();'> "..QBCore.Shared.Items["can"].label, params = { event = "jim-recycle:SellAnim", args = 'can' } }
	tradeMenu[#tradeMenu+1] = { disabled = not HasItem("bottle", 1), icon = "bottle", header = "<img src=nui://"..Config.img..QBCore.Shared.Items["bottle"].image.." width=30px onerror='this.onerror=null; this.remove();'> "..QBCore.Shared.Items["bottle"].label, params = { event = "jim-recycle:SellAnim", args = 'bottle' } }

	if #tradeMenu > 2 then exports['qb-menu']:openMenu(tradeMenu)
	else TriggerEvent("QBCore:Notify", Loc[Config.Lan].error["no_bottles"], "error") end
end)

AddEventHandler('onResourceStop', function(resource) if resource ~= GetCurrentResourceName() then return end
	for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
	for _, v in pairs(Peds) do unloadModel(GetEntityModel(v)) DeletePed(v) end
	for _, v in pairs(Props) do unloadModel(GetEntityModel(v)) DeleteObject(v) end
	for _, v in pairs(searchProps) do unloadModel(GetEntityModel(v)) DeleteObject(v) end
	unloadModel(GetEntityModel(TrollyProp)) DeleteObject(TrollyProp)
	unloadModel(GetEntityModel(scrapProp)) DeleteObject(scrapProp)
	for _, v in pairs(searchProps) do unloadModel(GetEntityModel(v)) DeleteObject(v) end
end)
