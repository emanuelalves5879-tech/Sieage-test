local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- Criar grupos de colisão
local GLADIATOR_GROUP = "Gladiators"
local PLAYER_GROUP = "Players"
local PREVIEW_GROUP = "Preview"

-- Criar os grupos de colisão
PhysicsService:CreateCollisionGroup(GLADIATOR_GROUP)
PhysicsService:CreateCollisionGroup(PLAYER_GROUP)
PhysicsService:CreateCollisionGroup(PREVIEW_GROUP)

-- Configurar para que gladiadores e jogadores NÃO colidam entre si
PhysicsService:CollisionGroupSetCollidable(GLADIATOR_GROUP, PLAYER_GROUP, false)
PhysicsService:CollisionGroupSetCollidable(PLAYER_GROUP, GLADIATOR_GROUP, false)

-- Configurar para que o preview NÃO colida com gladiadores nem jogadores
PhysicsService:CollisionGroupSetCollidable(PREVIEW_GROUP, GLADIATOR_GROUP, false)
PhysicsService:CollisionGroupSetCollidable(GLADIATOR_GROUP, PREVIEW_GROUP, false)
PhysicsService:CollisionGroupSetCollidable(PREVIEW_GROUP, PLAYER_GROUP, false)
PhysicsService:CollisionGroupSetCollidable(PLAYER_GROUP, PREVIEW_GROUP, false)

-- Função para aplicar o grupo de colisão a todas as partes de um modelo
local function setCollisionGroupForModel(model, groupName)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(descendant, groupName)
		end
	end
end

-- Aplicar grupo de colisão ao gladiador existente no Workspace
local function setupGladiator()
	local gladiator = workspace:FindFirstChild("Gladiator")
	if gladiator then
		setCollisionGroupForModel(gladiator, GLADIATOR_GROUP)
		-- Desativa pulo automático para evitar que o gladiador pule quando o jogador chega perto
		local humanoid = gladiator:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.AutoJumpEnabled = false
		end
		print("[GladiatorCollision] Grupo de colisão aplicado ao gladiador")
	end
end

-- Aplicar grupo de colisão ao personagem do jogador
local function setupPlayerCharacter(character)
	setCollisionGroupForModel(character, PLAYER_GROUP)
end

-- Configurar gladiador existente
setupGladiator()

-- Monitorar novos gladiadores adicionados ao Workspace
workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Model") and string.find(descendant.Name, "Gladiator") then
		task.wait(0.1) -- Pequeno delay para garantir que o modelo está totalmente carregado
		setCollisionGroupForModel(descendant, GLADIATOR_GROUP)
		-- Desativa pulo automático
		local humanoid = descendant:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.AutoJumpEnabled = false
		end
		print("[GladiatorCollision] Novo gladiador detectado e configurado:", descendant.Name)
	end
end)

-- Configurar jogadores existentes
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		setupPlayerCharacter(player.Character)
	end
	player.CharacterAdded:Connect(setupPlayerCharacter)
end

-- Configurar novos jogadores que entrarem
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupPlayerCharacter)
end)