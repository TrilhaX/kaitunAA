function securityMode()
    if securityModeGG == true then
        local players = game:GetService("Players")
        local ignorePlaceIds = { 8304191830 }

        local function isPlaceIdIgnored(placeId)
            for _, id in ipairs(ignorePlaceIds) do
                if id == placeId then
                    return true
                end
            end
            return false
        end

        while getgenv().securityMode do
            if #players:GetPlayers() >= 2 then
                local player1 = players:GetPlayers()[1]
                local targetPlaceId = 8304191830

                if game.PlaceId ~= targetPlaceId and not isPlaceIdIgnored(game.PlaceId) then
                    game:GetService("TeleportService"):Teleport(targetPlaceId, player1)
                end
            end
            wait(1)
        end
    end
end

function deletemap()
	if deleteMapGG == true then
		repeat task.wait() until game:IsLoaded()
		wait(5)
		local map = workspace:FindFirstChild("_map")
		local waterBlocks = workspace:FindFirstChild("_water_blocks")

		if map then
			map:Destroy()
		end

		if waterBlocks then
			waterBlocks:Destroy()
		end

		wait(1)
	end
end

function hideInfoPlayer()
	if hideInfoPlayerGG == true then
		local player = game.Players.LocalPlayer
		if not player then
			return
		end

		local head = player.Character and player.Character:FindFirstChild("Head")
		if not head then
			return
		end

		local overhead = head:FindFirstChild("_overhead")
		if not overhead then
			return
		end

		local frame = overhead:FindFirstChild("Frame")
		if not frame then
			return
		end

		frame:Destroy()

		wait(0.1)
	end
end

hideInfoPlayer()
securityMode()
deletemap()
