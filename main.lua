repeat task.wait() until game:IsLoaded()
wait(1)
function securityMode()
	if securityModeEnabled == true then
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

		while securityModeEnabled == true do
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

function deleteMap()
	if deleteMapEnabled == true then
		repeat
			task.wait()
		until game:IsLoaded()
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
	if hideInfoPlayerEnabled == true then
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

function autoreplay()
	while autoreplay == true do
		local resultUI = game:GetService("Players").LocalPlayer.PlayerGui.ResultsUI
		if resultUI and resultUI.Enabled == true then
			wait(3)
			local args = {
				[1] = "replay",
			}
			game:GetService("ReplicatedStorage")
				:WaitForChild("endpoints")
				:WaitForChild("client_to_server")
				:WaitForChild("set_game_finished_vote")
				:InvokeServer(unpack(args))
		end
		wait()
	end
end

function autoleave()
	while getgenv().autoleave == true do
		local resultUI = game:GetService("Players").LocalPlayer.PlayerGui.ResultsUI
		if resultUI and resultUI.Enabled == true then
			wait(3)
			game:GetService("ReplicatedStorage").endpoints.client_to_server.teleport_back_to_lobby:InvokeServer("leave")
		end
		wait()
	end
end

function autostart()
	while autoStart == true do
		local voteStart = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("VoteStart")
		if voteStart and voteStart.Enabled == true then
			game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()
		end
		wait()
	end
end

function autoskipwave()
	while autoSkipWave == true do
		local voteSkip = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("VoteSkip")
		if voteSkip and voteSkip.Enabled == true then
			game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_wave_skip:InvokeServer()
		end
	end
end

function autoPlaceUnit()
	while autoPlaceUnit == true do
		local Loader = require(game:GetService("ReplicatedStorage").src.Loader)
		local success, upvalues = pcall(debug.getupvalues, Loader.init)

		if not success then
			warn("Failed to get upvalues from Loader.init")
			return
		end

		local Modules = {
			["CORE_CLASS"] = upvalues[6],
			["CORE_SERVICE"] = upvalues[7],
			["SERVER_CLASS"] = upvalues[8],
			["SERVER_SERVICE"] = upvalues[9],
			["CLIENT_CLASS"] = upvalues[10],
			["CLIENT_SERVICE"] = upvalues[11],
		}

		local StatsServiceClient = Modules["CLIENT_SERVICE"] and Modules["CLIENT_SERVICE"]["StatsServiceClient"]

		function createAreaVisualization(center, radius)
			local area = Instance.new("Part")
			area.Name = "UnitSpawnArea"
			area.Size = Vector3.new(radius * 2, 0.1, radius * 2)
			area.Position = center + Vector3.new(0, 0.05, 0)
			area.Anchored = true
			area.CanCollide = false
			area.Transparency = 0.5
			area.Color = Color3.fromRGB(0, 255, 0)
			area.Shape = Enum.PartType.Cylinder
			area.Orientation = Vector3.new(90, 0, 0)
			area.Parent = workspace
			return area
		end

		function getRandomPositionAroundWaypoint(waypointPosition, radius)
			local angle = math.random() * (2 * math.pi)
			local distance = math.random() * radius
			local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
			return waypointPosition + offset
		end

		function GetCFrame(position, rotationX, rotationY)
			return CFrame.new(position) * CFrame.Angles(math.rad(rotationX), math.rad(rotationY), 0)
		end

		if
			StatsServiceClient
			and StatsServiceClient.module
			and StatsServiceClient.module.session
			and StatsServiceClient.module.session.collection
			and StatsServiceClient.module.session.collection.collection_profile_data
			and StatsServiceClient.module.session.collection.collection_profile_data.equipped_units
		then
			local equippedUnits = StatsServiceClient.module.session.collection.collection_profile_data.equipped_units
			local radius = 10
			local existingPositions = {}

			local lane = workspace._BASES.pve.LANES:FindFirstChild("1")
			local waypoint = lane:FindFirstChild("1")
			if not waypoint then
				warn("Waypoint not found in lane")
				return
			end

			createAreaVisualization(waypoint.Position, radius)

			for _, unit in pairs(equippedUnits) do
				if type(unit) == "table" then
					for _, unitID in pairs(unit) do
						local spawnPosition = getRandomPositionAroundWaypoint(waypoint.Position, radius)
						local spawnCFrame = GetCFrame(spawnPosition, 0, 0)

						local args = {
							[1] = unitID,
							[2] = spawnCFrame,
						}

						table.insert(existingPositions, spawnPosition)
						game:GetService("ReplicatedStorage")
							:WaitForChild("endpoints")
							:WaitForChild("client_to_server")
							:WaitForChild("spawn_unit")
							:InvokeServer(unpack(args))
					end
				else
					local spawnPosition = getRandomPositionAroundWaypoint(waypoint.Position, radius)
					local spawnCFrame = GetCFrame(spawnPosition, 0, 0)

					local args = {
						[1] = unit,
						[2] = spawnCFrame,
					}

					table.insert(existingPositions, spawnPosition)
					game:GetService("ReplicatedStorage")
						:WaitForChild("endpoints")
						:WaitForChild("client_to_server")
						:WaitForChild("spawn_unit")
						:InvokeServer(unpack(args))
				end
			end
		end
		wait()
	end
end

function autoUpgradeUnit()
	while autoUpgradeUnit == true do
		local Loader = require(game:GetService("ReplicatedStorage").src.Loader)
		local upvalues = debug.getupvalues(Loader.init)

		local Modules = {
			["CORE_CLASS"] = upvalues[6],
			["CORE_SERVICE"] = upvalues[7],
			["SERVER_CLASS"] = upvalues[8],
			["SERVER_SERVICE"] = upvalues[9],
			["CLIENT_CLASS"] = upvalues[10],
			["CLIENT_SERVICE"] = upvalues[11],
		}

		local ownedUnits = Modules["CLIENT_SERVICE"]["StatsServiceClient"].module.session.collection.collection_profile_data.owned_units
		local equippedUnits = Modules["CLIENT_SERVICE"]["StatsServiceClient"].module.session.collection.collection_profile_data.equipped_units

		function checkEquippedAgainstOwned()
			local matchedUUIDs = {}

			for _, equippedUUID in pairs(equippedUnits) do
				for key, ownedUUID in pairs(ownedUnits) do
					if tostring(equippedUUID) == tostring(key) then
						table.insert(matchedUUIDs, key)
					end
				end
			end

			return matchedUUIDs
		end

		function printUnitNames(matchedUUIDs)
			for _, matchedUUID in pairs(matchedUUIDs) do
				local ownedUnit = ownedUnits[matchedUUID]
				if ownedUnit and ownedUnit.unit_id then
					print(ownedUnit.unit_id)
				end
			end
		end
		local matchingUUIDs = checkEquippedAgainstOwned()
		if #matchingUUIDs > 0 then
			print("Found Units")
		end
		local args = {
			[1] = matchingUUIDs
		}

		local success, err = pcall(function()
			game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("upgrade_unit_ingame"):InvokeServer(unpack(args))
		end)

		if not success then
			warn("Erro ao realizar upgrade da unidade:", err)
		else
			print("Unidade atualizada:", unitInMap.Name)
		end
		wait()
	end
end

function autoEquipUnit()
	local Loader = require(game:GetService("ReplicatedStorage").src.Loader)
	upvalues = debug.getupvalues(Loader.init)
	local Modules = {
		["CORE_CLASS"] = upvalues[6],
		["CORE_SERVICE"] = upvalues[7],
		["SERVER_CLASS"] = upvalues[8],
		["SERVER_SERVICE"] = upvalues[9],
		["CLIENT_CLASS"] = upvalues[10],
		["CLIENT_SERVICE"] = upvalues[11],
	}

	local ownedUnits =
		Modules["CLIENT_SERVICE"]["StatsServiceClient"].module.session.collection.collection_profile_data.owned_units
	local selectedUUIDs = {}
	local count = 0

	if type(ownedUnits) == "table" then
		local uuidList = {}

		for _, unit in pairs(ownedUnits) do
			if unit.uuid then
				table.insert(uuidList, unit.uuid)
			end
		end

		while count < 6 and #uuidList > 0 do
			local randomIndex = math.random(1, #uuidList)
			local uuid = uuidList[randomIndex]

			if not selectedUUIDs[uuid] then
				selectedUUIDs[uuid] = true
				count = count + 1
				print(uuid)
				local args = {
					[1] = tostring(uuid),
				}

				game:GetService("ReplicatedStorage")
					:WaitForChild("endpoints")
					:WaitForChild("client_to_server")
					:WaitForChild("equip_unit")
					:InvokeServer(unpack(args))
			end

			table.remove(uuidList, randomIndex)
		end
	else
		print("A tabela 'owned_units' não é válida ou está vazia.")
	end
end

function checkPlayerXp()
	local Loader = require(game:GetService("ReplicatedStorage").src.Loader)
	upvalues = debug.getupvalues(Loader.init)
	local Modules = {
		["CORE_CLASS"] = upvalues[6],
		["CORE_SERVICE"] = upvalues[7],
		["SERVER_CLASS"] = upvalues[8],
		["SERVER_SERVICE"] = upvalues[9],
		["CLIENT_CLASS"] = upvalues[10],
		["CLIENT_SERVICE"] = upvalues[11],
	}
	local playerXp = Modules["CLIENT_SERVICE"]["StatsServiceClient"].module.session.profile_data.player_xp
	if playerXp == 0 then
		local args = {
			[1] = "EventClover",
			[2] = "gems10",
		}

		game:GetService("ReplicatedStorage")
			:WaitForChild("endpoints")
			:WaitForChild("client_to_server")
			:WaitForChild("buy_from_banner")
			:InvokeServer(unpack(args))
	else
		print("Have Played")
	end
end

function checkProgressionPlayer()
	while checkProgressionPlayer == true do
		local Loader = require(game:GetService("ReplicatedStorage").src.Loader)
		upvalues = debug.getupvalues(Loader.init)
		local Modules = {
			["CORE_CLASS"] = upvalues[6],
			["CORE_SERVICE"] = upvalues[7],
			["SERVER_CLASS"] = upvalues[8],
			["SERVER_SERVICE"] = upvalues[9],
			["CLIENT_CLASS"] = upvalues[10],
			["CLIENT_SERVICE"] = upvalues[11],
		}
		local storyFinished = Modules["CLIENT_SERVICE"]["StatsServiceClient"].module.session.profile_data.level_data.completed_story_levelsA

		if storyFinished == namek_level_6 then
			print("Story Finished")
			local inLobby = workspace:FindFirstChild("_LOBBY_CONFIG")
			if inLobby then
				local args = {
					[1] = "_lobbytemplategreen1"
				}
				
				game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer(unpack(args))
				local args = {
					[1] = "_lobbytemplategreen1",
					[2] = "namek_infinite",
					[3] = true,
					[4] = "Hard",
				}
	
				game:GetService("ReplicatedStorage")
					:WaitForChild("endpoints")
					:WaitForChild("client_to_server")
					:WaitForChild("request_lock_level")
					:InvokeServer(unpack(args))
				wait(1)
				local args = {
					[1] = "_lobbytemplategreen1",
				}
			
				game:GetService("ReplicatedStorage")
					:WaitForChild("endpoints")
					:WaitForChild("client_to_server")
					:WaitForChild("request_start_game")
					:InvokeServer(unpack(args))
				break
			else
				autoreplay()
				break
			end
		else
			print("Story Not Finished")
			if inLobby then
				local args = {
					[1] = "_lobbytemplategreen1"
				}
				
				game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer(unpack(args))			
				local args = {
					[1] = "namek"
				}
				
				game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("lobby_world_skip"):InvokeServer(unpack(args))
				break			
			else
				autoleave()
				break
			end
		end
		wait()
	end
end

function blackScreen()
	if blackScreenEnabled == true then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "BlackScreenTempestHub"
		screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
		
		local frame = Instance.new("Frame")
		frame.Name = "BackgroundFrame"
		frame.Size = UDim2.new(1, 0, 2, 0)
		frame.Position = UDim2.new(0, 0, 0, -60)
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.Parent = screenGui
		
		local centerFrame = Instance.new("Frame")
		centerFrame.Name = "CenterFrame"
		centerFrame.Size = UDim2.new(0, 300, 0, 300)
		centerFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
		centerFrame.AnchorPoint = Vector2.new(0, 0.7)
		centerFrame.BackgroundTransparency = 1
		centerFrame.Parent = frame
		
		local yOffset = 0
		local player = game.Players.LocalPlayer
		
		local name = player.Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(0, 200, 0, 50)
		nameLabel.Position = UDim2.new(0.5, -100, 0, yOffset)
		nameLabel.Text = "Name: " .. name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 20
		nameLabel.BackgroundTransparency = 1
		nameLabel.Parent = centerFrame
		yOffset = yOffset + 55
		
		local levelText = player.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text
		local numberAndAfter = levelText:sub(7)
		local levelLabel = Instance.new("TextLabel")
		levelLabel.Name = "LevelLabel"
		levelLabel.Size = UDim2.new(0, 200, 0, 50)
		levelLabel.Position = UDim2.new(0.5, -100, 0, yOffset)
		levelLabel.Text = "Level: " .. numberAndAfter
		levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		levelLabel.TextSize = 20
		levelLabel.BackgroundTransparency = 1
		levelLabel.Parent = centerFrame
		yOffset = yOffset + 55
		
		local gemsAmount = game:GetService("Players").LocalPlayer._stats:FindFirstChild("gem_amount")
		local Gems = Instance.new("TextLabel")
		Gems.Name = "gemsLabel"
		Gems.Size = UDim2.new(0, 200, 0, 50)
		Gems.Position = UDim2.new(0.5, -100, 0, yOffset)
		Gems.Text = "Gems: " .. gemsAmount.Value
		Gems.TextColor3 = Color3.fromRGB(255, 255, 255)
		Gems.TextSize = 20
		Gems.BackgroundTransparency = 1
		Gems.Parent = centerFrame
		yOffset = yOffset + 55
		
		local goldAmount = game:GetService("Players").LocalPlayer._stats:FindFirstChild("gold_amount")
		local Gold = Instance.new("TextLabel")
		Gold.Name = "goldLabel"
		Gold.Size = UDim2.new(0, 200, 0, 50)
		Gold.Position = UDim2.new(0.5, -100, 0, yOffset)
		Gold.Text = "Gold: " .. goldAmount.Value
		Gold.TextColor3 = Color3.fromRGB(255, 255, 255)
		Gold.TextSize = 20
		Gold.BackgroundTransparency = 1
		Gold.Parent = centerFrame
		yOffset = yOffset + 55
		
		local holidayAmount = game:GetService("Players").LocalPlayer._stats:FindFirstChild("_resourceHolidayStars")
		local Holiday = Instance.new("TextLabel")
		Holiday.Name = "holidayLabel"
		Holiday.Size = UDim2.new(0, 200, 0, 50)
		Holiday.Position = UDim2.new(0.5, -100, 0, yOffset)
		Holiday.Text = "Holiday Stars: " .. holidayAmount.Value
		Holiday.TextColor3 = Color3.fromRGB(255, 255, 255)
		Holiday.TextSize = 20
		Holiday.BackgroundTransparency = 1
		Holiday.Parent = centerFrame
		yOffset = yOffset + 55
		
		local candyAmount = game:GetService("Players").LocalPlayer._stats:FindFirstChild("_resourceCandies")
		local candy = Instance.new("TextLabel")
		candy.Name = "candyLabel"
		candy.Size = UDim2.new(0, 200, 0, 50)
		candy.Position = UDim2.new(0.5, -100, 0, yOffset)
		candy.Text = "Candy: " .. candyAmount.Value
		candy.TextColor3 = Color3.fromRGB(255, 255, 255)
		candy.TextSize = 20
		candy.BackgroundTransparency = 1
		candy.Parent = centerFrame
		yOffset = yOffset + 55
		wait()
	end
end

function kaitun()
	while kaitunEnabled == true do
		local inLobby = workspace:FindFirstChild("_LOBBY_CONFIG")
		if inLobby then
			print("inLobby")
			checkPlayerXp()
			wait(2)
			autoEquipUnit()
			wait(1)
			checkProgressionPlayer()
			break
		else
			print("inGame")
			autoStart()
			autoSkipWave()
			autoPlaceUnit()
			autoUpgradeUnit()
			checkProgressionPlayer()
			break
        end
		wait()
	end
end

function webhook()
    while webhookEnabled == true do
        local discordWebhookUrl = urlwebhook
        local resultUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ResultsUI")

        if resultUI and resultUI.Enabled == true then
            local ValuesRewards = {}
            local ValuesStatPlayer = {}        
            local name = game:GetService("Players").LocalPlayer.Name
            local formattedName = "||" .. name .. "||"

            local levelText = game:GetService("Players").LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text
            local numberAndAfter = levelText:sub(7)

            local player = game:GetService("Players").LocalPlayer
            local scrollingFrame = player.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame

            local Loader = require(game:GetService("ReplicatedStorage").src.Loader)
            local upvalues = debug.getupvalues(Loader.init)
            local Modules = {
                ["CORE_CLASS"] = upvalues[6],
                ["CORE_SERVICE"] = upvalues[7],
                ["SERVER_CLASS"] = upvalues[8],
                ["SERVER_SERVICE"] = upvalues[9],
                ["CLIENT_CLASS"] = upvalues[10],
                ["CLIENT_SERVICE"] = upvalues[11],
            }
            local inventory = Modules["CLIENT_SERVICE"]["StatsServiceClient"].module.session.inventory.inventory_profile_data.normal_items

            for _, frame in pairs(scrollingFrame:GetChildren()) do
                if (frame.Name == "GemReward" or frame.Name == "GoldReward" or frame.Name == "TrophyReward" or frame.Name == "XPReward") and frame.Visible then
                    local amountLabel = frame:FindFirstChild("Main") and frame.Main:FindFirstChild("Amount")
                    if amountLabel then
                        local rewardType = frame.Name:gsub("Reward", "")
                        local gainedAmount = amountLabel.Text
                        local totalAmount = inventory[rewardType:lower()]
            
                        if totalAmount then
                            table.insert(ValuesRewards, gainedAmount .. "[" .. totalAmount .. "]\n")
                        else
                            table.insert(ValuesRewards, gainedAmount .. "\n")
                        end
                    end
                end
            end

            local rewardsString = table.concat(ValuesRewards, "\n")

            local levelDataRemote = workspace._MAP_CONFIG:WaitForChild("GetLevelData")
            local ResultUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ResultsUI")
            local act = ResultUI.Holder.LevelName.Text
            local levelData = levelDataRemote:InvokeServer()

            local ValuesMapConfig = {}
            
            local result = ResultUI.Holder.Title.Text
            local elapsedTimeText = ResultUI.Holder.Middle.Timer.Text
            local timeParts = string.split(elapsedTimeText, ":")
            local totalSeconds = 0
            
            if #timeParts == 3 then
                local hours = tonumber(timeParts[1]) or 0
                local minutes = tonumber(timeParts[2]) or 0
                local seconds = tonumber(timeParts[3]) or 0
                totalSeconds = (hours * 3600) + (minutes * 60) + seconds
            elseif #timeParts == 2 then
                local minutes = tonumber(timeParts[1]) or 0
                local seconds = tonumber(timeParts[2]) or 0
                totalSeconds = (minutes * 60) + seconds
            elseif #timeParts == 1 then
                totalSeconds = tonumber(timeParts[1]) or 0
            end
            
            local hours = math.floor(totalSeconds / 3600)
            local minutes = math.floor((totalSeconds % 3600) / 60)
            local seconds = totalSeconds % 60
            
            local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            
            if type(levelData) == "table" then
                if levelData.world and levelData._gamemode and levelData._difficulty then
                    local formattedValue = levelData.world .. " " .. act .." - " .. levelData._gamemode .. " [" .. levelData._difficulty .. "]"
            
                    local FormattedFinal = "\n" .. formattedTime .. " - " .. result .. "\n" .. formattedValue
            
                    table.insert(ValuesMapConfig, FormattedFinal)
                else
                    print("Faltando informações necessárias no levelData.")
                end
            else
                print("O dado recebido não é uma tabela.")
            end      

            local playerData = Modules["CLIENT_SERVICE"]["StatsServiceClient"].module.session.profile_data
            local gemsEmoji = "<:gemsAA:1322365177320177705>"
            local goldEmoji = "<:goldAA:1322369598015668315>"
            local traitReroll = "<:traitRerollAA:1322370533106384987>"

            local keysToPrint = {
                ["gem_amount"] = gemsEmoji,
                ["gold_amount"] = goldEmoji,
                ["trait_reroll_tokens"] = traitReroll,
                ["trophies"] = "🏆",
                ["christmas2024_meter_value"] = "🎁"
            }
            
            local battlepassData = playerData.battlepass_data
            local silverChristmasXp = battlepassData.silver_christmas.xp
            
            local ValuesBattlepassXp = {}
            
            local holidayStars = game:GetService("Players").LocalPlayer._stats:FindFirstChild("_resourceHolidayStars")
            local Candies = game:GetService("Players").LocalPlayer._stats:FindFirstChild("_resourceCandies")
            
            if holidayStars and Candies then
                table.insert(ValuesBattlepassXp, holidayStars.Value)
                table.insert(ValuesBattlepassXp, Candies.Value)
            end
            
            table.insert(ValuesBattlepassXp, silverChristmasXp)
            table.insert(ValuesBattlepassXp, battlepassData)
            
            local message = ""
            
            for _, key in ipairs({"gem_amount", "gold_amount", "trait_reroll_tokens", "trophies", "christmas2024_meter_value"}) do
                if playerData[key] then
                    message = message .. keysToPrint[key] .. " " .. playerData[key] .. "\n"
                end
            end
            
            if holidayStars then
                local holidayEmoji = "<:holidayEventAA:1322369599517491241>"
                message = message .. holidayEmoji .. tostring(holidayStars.Value) .. "\n"
            end            
            if Candies then
                local candieEmoji = "<:candieAA:1322369601182629929>"
                message = message .. candieEmoji .. Candies.Value .. "\n"
            end
            
            table.insert(ValuesStatPlayer, message)            
            local statsString = table.concat(ValuesStatPlayer, "\n")
            local mapConfigString = table.concat(ValuesMapConfig, "\n")
            
            local color = 7995647
            if result == "DEFEAT" then
                color = 16711680
            elseif result == "VICTORY" then
                color = 65280
            end

            local payload = {
                content = pingContent,
                embeds = {
                    {
                        description = string.format("User: %s\nLevel: %s\n\nPlayer Stats:\n%s\nRewards:\n%s\nMatch Result:%s", formattedName, numberAndAfter, statsString, rewardsString, mapConfigString),
                        color = color,
                        fields = {
                            {
                                name = "Discord",
                                value = "https://discord.gg/ey83AwMvAn"
                            }
                        },
                        author = {
                            name = "Anime Adventures"
                        },
                        thumbnail = {
                            url = "https://cdn.discordapp.com/attachments/1060717519624732762/1307102212022861864/get_attachment_url.png?ex=673e5b4c&is=673d09cc&hm=1d58485280f1d6a376e1bee009b21caa0ae5cad9624832dd3d921f1e3b2217ce&"
                        }
                    }
                },
                attachments = {}
            }

            local payloadJson = HttpService:JSONEncode(payload)

            if syn and syn.request then
                local response = syn.request({
                    Url = discordWebhookUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = payloadJson
                })

                if response.Success then
                    print("Webhook sent successfully")
                    break
                else
                    warn("Error sending message to Discord with syn.request:", response.StatusCode, response.Body)
                end
            elseif http_request then
                local response = http_request({
                    Url = discordWebhookUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = payloadJson
                })

                if response.Success then
                    print("Webhook sent successfully")
                    break
                else
                    warn("Error sending message to Discord with http_request:", response.StatusCode, response.Body)
                end
            else
                print("Synchronization not supported on this device.")
            end
        end
        wait(1)
    end
end

local autoreplay = true
local autoStart = true
local autoSkipWave = true
local autoPlaceUnit = true
local autoUpgradeUnit = true
local checkProgressionPlayer = true
local securityModeEnabled = false
local deleteMapEnabled = false
local blackScreenEnabled = true
local hideInfoPlayerEnabled = true
local kaitunEnabled = false
local webhookEnabled = false
local discordWebhookUrl = ""
if kaitunEnabled == true then
	kaitun()
end
if hideInfoPlayerEnabled == true then
	hideInfoPlayer()
end
if securityModeEnabled == true then
	securityMode()
end
if deleteMapEnabled == true then
	deleteMap()
end
if blackScreenEnabled == true then
	blackScreen()
end
if webhookEnabled == true then
	webhook()
end
print("Executado")
