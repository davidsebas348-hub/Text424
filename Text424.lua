--------------------------------------------------
-- TOGGLE
--------------------------------------------------
getgenv().SILENT_AIM = not getgenv().SILENT_AIM

if not getgenv().SILENT_AIM then
	return
end

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local remote = ReplicatedStorage
	:WaitForChild("SystemResources")
	:WaitForChild("BufferCache")
	:WaitForChild("RequestActionSync")

local function getCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- MÁS CERCANO (SOLO CON TOOL EQUIPADA)
--------------------------------------------------
local function getClosestPlayer()
	local myChar = getCharacter()
	local myRoot = getRoot(myChar)
	if not myRoot then return nil end

	local closest = nil
	local shortest = math.huge

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hum = plr.Character:FindFirstChild("Humanoid")
			local head = plr.Character:FindFirstChild("Head")
			local root = getRoot(plr.Character)
			local tool = plr.Character:FindFirstChildOfClass("Tool")

			-- 🔥 SOLO SI TIENE TOOL EN LA MANO
			if hum and hum.Health > 0 and head and root and tool then
				local dist = (root.Position - myRoot.Position).Magnitude

				if dist < shortest then
					shortest = dist
					closest = plr
				end
			end
		end
	end

	return closest
end

--------------------------------------------------
-- DISPARO
--------------------------------------------------
local function fireSilentShot()
	if not getgenv().SILENT_AIM then return end

	local myChar = getCharacter()
	local myRoot = getRoot(myChar)
	local target = getClosestPlayer()

	if not myRoot or not target then return end

	local head = target.Character:FindFirstChild("Head")
	local hum = target.Character:FindFirstChild("Humanoid")
	if not head or not hum then return end

	local origin = myRoot.Position
	local hitPos = head.Position
	local dir = (hitPos - origin).Unit

	remote:FireServer({
		direction = dir,
		hitPosition = hitPos,
		origin = origin,
		IsHeadshot = true,
		hitHumanoid = hum,
		hitInstance = head
	})
end

--------------------------------------------------
-- LOOP CONTROLADO
--------------------------------------------------
task.spawn(function()
	while getgenv().SILENT_AIM do
		task.wait(0.6)
		fireSilentShot()
	end
end)
