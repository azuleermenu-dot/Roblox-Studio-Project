local Config = {}

Config.DataStoreName = "EggMinerSimulator_v1"
Config.StartingCoins = 0
Config.StartingBackpack = 25
Config.StartingPickaxe = "Wooden"
Config.SellMultiplier = 1
Config.HatchCost = 500
Config.MaxEquippedPets = 3
Config.MiningCooldown = 0.12
Config.AutosaveSeconds = 60

Config.Pickaxes = {
    Wooden = {Power = 1, Capacity = 25, Cost = 0},
    Stone = {Power = 3, Capacity = 50, Cost = 100},
    Iron = {Power = 7, Capacity = 100, Cost = 500},
    Gold = {Power = 15, Capacity = 250, Cost = 2500},
    Diamond = {Power = 35, Capacity = 500, Cost = 10000},
}

Config.Eggs = {
    BasicEgg = {MaxHealth = 25, Reward = 25, Hatchable = true},
    CrystalEgg = {MaxHealth = 100, Reward = 150, Hatchable = true},
    GoldenEgg = {MaxHealth = 500, Reward = 1000, Hatchable = true},
}

Config.HatchEggs = {
    BasicEgg = {
        Cost = 500,
        Pets = {
            {Name="Tiny Mouse", Rarity="Common", Multiplier=1.2, Chance=60},
            {Name="Blue Bunny", Rarity="Uncommon", Multiplier=1.5, Chance=25},
            {Name="Crystal Fox", Rarity="Rare", Multiplier=2, Chance=10},
            {Name="Golden Dragon", Rarity="Epic", Multiplier=4, Chance=4},
            {Name="Cosmic Phoenix", Rarity="Legendary", Multiplier=10, Chance=1},
        }
    }
}

return Config
