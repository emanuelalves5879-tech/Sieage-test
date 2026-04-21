-- ============================================
-- CONFIGURAÇÕES DO JOGO
-- ============================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = {}

-- ============================================
-- VARIÁVEIS DO JOGO
-- ============================================
GameConfig.vidaMaxima = 500
GameConfig.vidaAtual = 500
GameConfig.dinheiro = 100

-- RemoteEvent para sincronizar vida com clientes (obtido quando necessário)
local function getHealthChangedEvent()
	return ReplicatedStorage:FindFirstChild("HealthChanged")
end

local function getGameOverEvent()
	return ReplicatedStorage:FindFirstChild("GameOver")
end

-- ============================================
-- FUNÇÕES DE VIDA
-- ============================================

-- Perde vida (chamado quando zumbi chega ao final)
function GameConfig.PerderVida(quantidade)
	GameConfig.vidaAtual = GameConfig.vidaAtual - quantidade
	
	-- Não deixa a vida ficar negativa
	if GameConfig.vidaAtual < 0 then
		GameConfig.vidaAtual = 0
	end
	
	print("[Vida] " .. GameConfig.vidaAtual .. "/" .. GameConfig.vidaMaxima)
	
	-- Notifica todos os clientes sobre a mudança de vida
	local healthChangedEvent = getHealthChangedEvent()
	if healthChangedEvent then
		healthChangedEvent:FireAllClients(GameConfig.vidaAtual, GameConfig.vidaMaxima)
	end
	
	-- Se a vida chegou a zero, game over
	if GameConfig.vidaAtual <= 0 then
		print("=== GAME OVER! ===")
		local gameOverEvent = getGameOverEvent()
		if gameOverEvent then
			gameOverEvent:FireAllClients()
		end
	end
end

-- Ganha vida (se quiser adicionar cura depois)
function GameConfig.GanharVida(quantidade)
	GameConfig.vidaAtual = GameConfig.vidaAtual + quantidade
	
	if GameConfig.vidaAtual > GameConfig.vidaMaxima then
		GameConfig.vidaAtual = GameConfig.vidaMaxima
	end
end

-- Retorna a vida atual (para a GUI usar)
function GameConfig.GetVida()
	return GameConfig.vidaAtual, GameConfig.vidaMaxima
end

-- ============================================
-- FUNÇÕES DE DINHEIRO
-- ============================================

function GameConfig.GanharDinheiro(quantidade)
	GameConfig.dinheiro = GameConfig.dinheiro + quantidade
	print("[Dinheiro] " .. GameConfig.dinheiro)
end

function GameConfig.GastarDinheiro(quantidade)
	if GameConfig.dinheiro >= quantidade then
		GameConfig.dinheiro = GameConfig.dinheiro - quantidade
		return true  -- Sucesso
	end
	return false  -- Sem dinheiro suficiente
end

function GameConfig.GetDinheiro()
	return GameConfig.dinheiro
end

return GameConfig
