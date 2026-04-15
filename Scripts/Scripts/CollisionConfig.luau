-- ============================================
-- CONFIGURAÇÃO DE COLISÃO
-- Players, Mobs, Gladiators e Preview não colidem entre si
-- ============================================

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- Registra os grupos de colisão (API moderna)
PhysicsService:RegisterCollisionGroup("Players")
PhysicsService:RegisterCollisionGroup("Mobs")
PhysicsService:RegisterCollisionGroup("Gladiators")
PhysicsService:RegisterCollisionGroup("Preview")

-- Players não colidem com Mobs
PhysicsService:CollisionGroupSetCollidable("Players", "Mobs", false)

-- Mobs não colidem entre si (incluindo corpos mortos durante DeathCleanup)
PhysicsService:CollisionGroupSetCollidable("Mobs", "Mobs", false)

-- Gladiators não colidem com Players nem Mobs
PhysicsService:CollisionGroupSetCollidable("Gladiators", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Gladiators", "Mobs", false)

-- Preview não colide com nada (é apenas visual)
PhysicsService:CollisionGroupSetCollidable("Preview", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Preview", "Mobs", false)
PhysicsService:CollisionGroupSetCollidable("Preview", "Gladiators", false)

-- ============================================
-- APLICA AOS PLAYERS
-- ============================================
local function aplicarColisaoPlayer(character)
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Players"
		end
	end
	
	-- Aplica também a futuras partes adicionadas
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Players"
		end
	end)
end

-- Players que já estão no jogo
for _, player in Players:GetPlayers() do
	if player.Character then
		aplicarColisaoPlayer(player.Character)
	end
end

-- Novos players que entrarem
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(aplicarColisaoPlayer)
end)

-- ============================================
-- APLICA AOS GLADIADORES
-- ============================================
local function aplicarColisaoGladiator(model)
	-- Desativa pulo automático e define JumpHeight como 0
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.AutoJumpEnabled = false
		humanoid.JumpHeight = 0
		humanoid.JumpPower = 0
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true -- Desativa controle de movimento do Humanoid
	end
	
	-- Aplica grupo de colisão a todas as partes
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Gladiators"
		end
	end
	
	-- Aplica também a futuras partes adicionadas
	model.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Gladiators"
		end
	end)
end

-- Gladiadores existentes no Workspace
for _, obj in workspace:GetChildren() do
	if obj:IsA("Model") and obj.Name == "Gladiator" then
		aplicarColisaoGladiator(obj)
	end
end

-- Monitora novos gladiadores adicionados ao Workspace
workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Model") and descendant.Name == "Gladiator" then
		task.wait(0.1) -- Pequeno delay para garantir que o modelo está carregado
		aplicarColisaoGladiator(descendant)
	end
end)