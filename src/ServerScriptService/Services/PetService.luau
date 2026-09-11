local Service = {}
local Config = require(game.ReplicatedStorage.Shared.GameConfig)
local Data = require(script.Parent.PlayerDataService)
local RNG = Random.new()

function Service.GetMultiplier(player)
    local d = Data.Get(player)
    if not d then return 1 end
    local multiplier = 1
    for _, pet in ipairs(d.EquippedPets) do
        if type(pet) == "table" and tonumber(pet.Multiplier) then
            multiplier += math.max(0, pet.Multiplier - 1)
        end
    end
    return multiplier
end

function Service.Hatch(player, eggName)
    local d = Data.Get(player)
    local egg = Config.HatchEggs[eggName]
    if not d or not egg or d.Coins < egg.Cost then return nil, "Not enough coins" end
    d.Coins -= egg.Cost
    local roll = RNG:NextNumber(0, 100)
    local total = 0
    for _, pet in ipairs(egg.Pets) do
        total += pet.Chance
        if roll <= total then
            local owned = {Name=pet.Name, Rarity=pet.Rarity, Multiplier=pet.Multiplier}
            table.insert(d.Pets, owned)
            if #d.EquippedPets < Config.MaxEquippedPets then
                table.insert(d.EquippedPets, owned)
            end
            Data.MarkDirty(player)
            return owned
        end
    end
    return nil, "Hatch roll failed"
end

return Service
