if CLIENT then return end

local characterID = "Husk_player"
local jobID = "PlayerHuskJob"

local function InventorySwap(oldCharacter, newCharacter)
    print("The Inventory Swap Starts")
    for item in oldCharacter.Inventory.FindAllItems() do
        print(item)
        local index = oldCharacter.Inventory.FindIndex(item)
        print(index)
        --print("Item: " .. item .. " At Index: " .. index)
        newCharacter.Inventory.TryPutItem(item, index, true, false)
    end
    print("The Inventory Swap Ends")
end

local function RespawnCharacter(character)
	print("Respawning " .. character.Name .. " as " .. jobID)

	Entity.Spawner.AddCharacterToSpawnQueue(characterID, character.WorldPosition, function(newCharacter)
		local client = nil
		for key, value in pairs(Client.ClientList) do
			if value.Character == character then
				client = value
			end
		end
		InventorySwap(character, newCharacter)

		local TeamID_Save = character.TeamID
		print("Check Team ID")
		print(character.TeamID)
		print("Old Character on Team?")
		print(character.IsOnPlayerTeam)


		Entity.Spawner.AddEntityToRemoveQueue(character)

		if client == nil then
			return
		end
		newCharacter.TeamID = TeamID_Save
		newCharacter.UpdateTeam()
		print("New Character on Team?")
        print(newCharacter.IsOnPlayerTeam)

--      NetEntityEvent.Type
		client.SetClientCharacter(newCharacter)

		local info = CharacterInfo(characterID, client.Name, client.Name)
		info.Job = Job(JobPrefab.Get(jobID))
		info.Head = client.CharacterInfo.Head
-- 		info.Head.HairIndex = client.CharacterInfo.HairIndex
-- 		info.Head.BeardIndex = client.CharacterInfo.BeardIndex
-- 		info.Head.MoustacheIndex = client.CharacterInfo.MoustacheIndex
-- 		info.Head.FaceAttachmentIndex = client.CharacterInfo.FaceAttachmentIndex

		newCharacter.Info = info
	end)
end

Hook.Add("character.created", "convertJobs", function(character)
	Timer.Wait(function()
		if character.HasJob(jobID) and character.IsHuman then
			RespawnCharacter(character)
		elseif not character.IsHuman and character.Name == characterID then
			print("deleted duplicate character")

-- 			if character.Inventory then
-- 				for bb, items in pairs(character.Inventory.FindAllItems()) do
-- 					Entity.Spawner.AddItemToRemoveQueue(items)
-- 				end
-- 			end
			Entity.Spawner.AddEntityToRemoveQueue(character)
		end
	end, 1000)
end)