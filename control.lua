require "util"
require "defines"
require "lib"

on_area_selection = script.generate_event_name()

selection_left_top = nil

for k,v in pairs(defines.events) do
	--script.on_event(v, function (event) message(get_event_name(event.name)) end)
end 

function get_event_name(_name)
	for k,v in pairs(defines.events) do
		if v == _name then
			return k
		end
	end
end 

function startingItems(player)
  player.insert{name="test", count=100}
end




script.on_event(defines.events.on_player_created,  function (event) startingItems(game.get_player(event.player_index)) end)


script.on_event(defines.events.on_tick,  function (event) on_tick(event) end)
script.on_event(defines.events.on_put_item,  function (event) on_put_item(event) end)

last_position = nil
last_position_tick = nil

function on_put_item(event)
	local player = game.players[event.player_index]
	if player.cursor_stack.valid_for_read then
		if player.cursor_stack.name == "test" then 
			if not selection_left_top then
				selection_left_top = event.position
			else -- remove previous area entity

				area = expand_area(last_area, 1)
				for _,entity in pairs(player.surface.find_entities(area)) do
					if entity.name == "m2k-dbg-overlay-red" then 
						entity.destroy()
					end
				end
			end
			-- visualisation of the selected area
			local area = {left_top = selection_left_top, right_bottom = event.position}
			area = normalise(area)
			
			
			for x,y in iarea(area, 1) do
				player.surface.create_entity{name = "m2k-dbg-overlay-red", position = {x=x, y=y}, force=player.force}
			end
			last_area = area
			last_position = event.position
			last_position_tick = event.tick
		end
	end
end


function on_tick(event)

	local player = game.player


	if last_position_tick then
		if event.tick - last_position_tick == 1 then -- slightly move the mouse to know if the player is still cliking	
			
			local new_position = player.real2screenposition(player.screen2realposition(player.real2screenposition(last_position)))
			if (game.tick/2) %2 == 0 then
				new_position.x = new_position.x + 1
				new_position.y = new_position.y + 1
			else
				new_position.x = new_position.x - 1
				new_position.y = new_position.y - 1
			end
			new_position = player.real2screenposition(player.screen2realposition(new_position)) -- allows to clear roundings error from factorio
			player.cursor_position = new_position

		elseif event.tick - last_position_tick > 1 then -- click has been released
			local area = {left_top = selection_left_top, right_bottom = last_position}
			normalized_area = normalise(area)
			game.raise_event(on_area_selection, {selected_area = area, normalized_selected_area = normalized_area, surface = player.surface})

			for _,entity in pairs(player.surface.find_entities(area)) do
				if entity.name == "m2k-dbg-overlay-red" then 
					entity.destroy()
				end
			end
			last_position_tick = nil
			selection_left_top = nil

		end
	end
end


script.on_event(defines.events.on_built_entity, function(event) on_built_entity(event) end)

function on_built_entity(event)
	local entity = event.created_entity
	local player = game.players[event.player_index]

	if entity.name == "m2k-dbg-small-blue" then
		entity.destroy()
		local stack = {name = player.cursor_stack.name, count = player.cursor_stack.count+1}
		player.cursor_stack.clear()
		player.cursor_stack.set_stack(stack)
	end
end

function normalise(_area)
	if _area.left_top.x > _area.right_bottom.x then
		x1, x2 = _area.right_bottom.x, _area.left_top.x
	else
		x1, x2 = _area.left_top.x, _area.right_bottom.x
	end
	if _area.left_top.y > _area.right_bottom.y then
		y1, y2 = _area.right_bottom.y, _area.left_top.y
	else
		y1, y2 = _area.left_top.y, _area.right_bottom.y
	end
	return {left_top = {x = math.floor(x1) + 0.5, y = math.floor(y1) + 0.5}, right_bottom = { x = math.floor(x2) + 0.5, y = math.floor(y2) + 0.5} }
end

--[[

	local new_position = player.real2screenposition(event.position)
	if new_position.x %2 == 0 then
		new_position.x = new_position.x + 1
	else
		new_position.x = new_position.x - 1
	end
	if new_position.y %2 == 0 then
		new_position.y = new_position.y + 1
	else
		new_position.y = new_position.y - 1
	end
	player.cursor_position = new_position


	local position = player.real2screenposition(event.position)
	message(string.format("%d -- x=%d, y=%d", game.tick,position.x, position.y ))

]]