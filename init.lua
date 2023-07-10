-- Copyright (C) 2021 Norbert Thien, multimediamobil - Region Süd, Lizenz: Creative Commons BY-SA 4.0
-- Kein Rezept, nur im Creative Modus verwendbar oder mit give <playername> alan:info_tool

-- TODO: Erweiterung: Anzeige des Rezeptes
-- TODO: Erweiterung: Anzeige, wer den Block gesetzt hat
-- TODO: Erweiterung: Infotext (meta)-Ausgabe auf owned by beschränken
-- TODO: Erweiterung: dynamische Größe des Formspecs (in Abhängigkeit von den gefunden Informationen)

local S = minetest.get_translator("alan")


local function above_or_under(placer, pointed_thing)
	if placer:get_player_control().sneak then
		return pointed_thing.above
	else
		return pointed_thing.under
	end
end


minetest.register_tool("alan:info_tool", {
	description = "Alan - a tool to get information about the punched node",
	inventory_image = "alan_inventory.png",
	stack_max = 1, -- nur einmal als Werkzeug im Inventar
	liquids_pointable = true, -- auch Wasser etc. kann angewählt werden

	on_use = function(itemstack, placer, pointed_thing)
		local playername = placer:get_player_name()

		local output = ""

		if pointed_thing == nil or pointed_thing.type ~= "node" then -- abbrechen, falls kein oder falscher Objekttyp angeklickt
			output = "Der Objekttyp wurde nicht erkannt." -- This tool only works on nodes
		else
			local pos_pointed = above_or_under(placer, pointed_thing)
			local registered_name = minetest.get_node(pos_pointed).name or "Kein technischer Name gefunden" -- Registrierungsnamen ermitteln

			local description = ItemStack(registered_name):get_description() or "Keine Beschreibung gefunden" -- Beschreibung/Tooltip ermitteln
								-- local stack = ItemStack(registered_name)
								-- local description = stack:get_description() or "Keine Beschreibung vorhanden"
			if string.len(description) > 40 then -- sehr lange Beschreibungen kürzen
				description = string.sub(description, 1, 40)
				description = description .. " ... (gekürzt)"
			end

			local param = minetest.get_node(pos_pointed).param1 or "Kein Param1-Wert gefunden"
			local param2 = minetest.get_node(pos_pointed).param2 or "Kein Param2-Wert gefunden"

			local protected = minetest.is_protected(pos_pointed, playername) -- ist Objekt für puncher geschützt?
			local meta = minetest.get_meta(pos_pointed)
			local owner = meta:get_string("owner") or "Keine Angaben zum Besitz gefunden"

			local info = meta:get_string("infotext") or "Kein Infotext gefunden"

			if owner == "" then
				if string.find(info, "owned") or string.find(info, "Owned") then
					owner = info
				else
					owner = "Keine Angaben zum Besitz gefunden"
				end
			end

			output = "Beschreibung: " .. description .. "\n"
			output = output .. "Technischer Name: " .. registered_name .. "\n\n"

			local _, _, x, y, z = string.find(minetest.pos_to_string(pos_pointed), "(%-?%d+),(%-?%d+),(%-?%d+)")

			output = output .. "Position: x = " .. x .. ", y = " .. y .. ", z = " .. z .. "\n"
			output = output .. "Param-Wert: " .. param .. "\n"
			output = output .. "Param2-Wert: " .. param2 .. "\n\n"

			output = output .. "Objekt-Schutz: " .. dump(protected) .. "\n"
			output = output .. "Besitz von: " .. owner
		end

		local formspec =
					"formspec_version[4]" ..
					"size[11.1,4.5]" ..
					"textarea[0.25,0.4;11.1,4.5;;;".. output .."]" ..
					"button_exit[8.8,3.5;2.0,0.75;quit;quit]"

		minetest.show_formspec(playername, "alan_info", formspec)
	end
})


-- local stack = ItemStack(registered_name)
-- stack:get_meta():set_string("description", "Meine Beschreibung") -- eigene Beschreibung setzen

-- minetest.registered_items[registered_name].description -- alternative Möglichkeit?

-- if pointed_thing.type == "object" then
		-- local entity = pointed_thing.ref:get_luaentity()
		-- if entity and entity.name == "WAS-FÜR-EIN-OBJEKT" then
