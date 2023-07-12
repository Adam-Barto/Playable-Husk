if CLIENT then return end

local characterID = "Husk_player"
local jobID = "PlayerHuskJob"

local function MoveInvSlot(oldCharacter, newCharacter, invSlot)
	local item = oldCharacter.Inventory.GetItemInLimbSlot(invSlot)
	if item then
		item.Drop()
		local index = newCharacter.Inventory.FindLimbSlot(invSlot)
		if index then
			newCharacter.Inventory.TryPutItem(item, index, true, false)
		end
	end
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

		MoveInvSlot(character, newCharacter, InvSlotType.Card)
		MoveInvSlot(character, newCharacter, InvSlotType.Headset)
		MoveInvSlot(character, newCharacter, InvSlotType.Head)

		Entity.Spawner.AddEntityToRemoveQueue(character)

		if client == nil then
			return
		end

		newCharacter.TeamID = character.TeamID

		client.SetClientCharacter(newCharacter)

		local info = CharacterInfo(characterID, client.Name, client.Name)
		info.Job = Job(JobPrefab.Get(jobID))
		info.Head = client.CharacterInfo.Head
		info.Head.HairIndex = 0
		info.Head.BeardIndex = 0
		info.Head.MoustacheIndex = 0
		info.Head.FaceAttachmentIndex = 0

		newCharacter.Info = info
	end)
end

Hook.Add("character.created", "convertJobs", function(character)
	Timer.Wait(function()
		if character.HasJob(jobID) and character.IsHuman then
			RespawnCharacter(character)
		elseif not character.IsHuman and character.Name == characterID then
			print("deleted duplicate character")

			if character.Inventory then
				for bb, items in pairs(character.Inventory.FindAllItems()) do
					Entity.Spawner.AddItemToRemoveQueue(items)
				end
			end
			Entity.Spawner.AddEntityToRemoveQueue(character)
		end
	end, 1000)
end)