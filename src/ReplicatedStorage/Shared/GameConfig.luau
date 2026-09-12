local Config = {}

Config.DataStoreName = "EggMinerSimulator_v1"
Config.StartingCoins = 0
Config.StartingBackpack = 25
Config.StartingPickaxe = "Wooden"
Config.SellMultiplier = 1
Config.HatchCost = 0
Config.MaxEquippedPets = 3
Config.MiningCooldown = 0.12
Config.AutosaveSeconds = 60
Config.NewPlayerProtectionSeconds = 300

Config.Pickaxes = {
    Wooden = {Power = 1, Capacity = 25, Cost = 0},
    Stone = {Power = 3, Capacity = 50, Cost = 100},
    Iron = {Power = 7, Capacity = 100, Cost = 500},
    Gold = {Power = 15, Capacity = 250, Cost = 2500},
    Diamond = {Power = 35, Capacity = 500, Cost = 10000},
}

-- Armor makes egg carriers harder to stagger. The one-tier gap rule and
-- starter protection stop fresh players from being farmed by endgame players.
Config.Armor = {
    {Name="Cloth", DamageReduction=0, StaggerBonus=0, Cost=0},
    {Name="Iron", DamageReduction=5, StaggerBonus=1, Cost=750},
    {Name="Steel", DamageReduction=10, StaggerBonus=2, Cost=3000},
    {Name="Diamond", DamageReduction=16, StaggerBonus=3, Cost=10000},
}

Config.Combat = {
    HitRange=10,
    HitCooldown=0.65,
    BaseDamage=12,
    BaseHitsToSteal=2,
    MaxArmorGap=2,
}

Config.Resources = {
    Stone = {MaxHealth = 20, Reward = 2, Zone = "Forest"},
    Crystal = {MaxHealth = 45, Reward = 8, Zone = "Forest"},
    DesertRock = {MaxHealth = 100, Reward = 20, Zone = "Desert"},
    IceCrystal = {MaxHealth = 180, Reward = 45, Zone = "Ice"},
    MagmaRock = {MaxHealth = 350, Reward = 100, Zone = "Volcano"},
}

Config.HatchEggs = {
    BasicEgg = {Pets = {
        {Name="Tiny Mouse", Rarity="Common", Multiplier=1.2, Chance=70},
        {Name="Blue Bunny", Rarity="Uncommon", Multiplier=1.5, Chance=25},
        {Name="Crystal Fox", Rarity="Rare", Multiplier=2, Chance=5},
    }},
    CrystalEgg = {Pets = {
        {Name="Crystal Bunny", Rarity="Uncommon", Multiplier=2, Chance=55},
        {Name="Crystal Fox", Rarity="Rare", Multiplier=3, Chance=30},
        {Name="Prism Dragon", Rarity="Epic", Multiplier=6, Chance=12},
        {Name="Cosmic Phoenix", Rarity="Legendary", Multiplier=12, Chance=3},
    }},
    GoldenEgg = {Pets = {
        {Name="Golden Bunny", Rarity="Rare", Multiplier=4, Chance=55},
        {Name="Golden Dragon", Rarity="Epic", Multiplier=8, Chance=35},
        {Name="Sun Phoenix", Rarity="Legendary", Multiplier=18, Chance=10},
    }},
    DesertEgg = {Pets = {
        {Name="Sand Fox", Rarity="Uncommon", Multiplier=3, Chance=60},
        {Name="Scarab", Rarity="Rare", Multiplier=5, Chance=30},
        {Name="Golden Sphinx", Rarity="Epic", Multiplier=10, Chance=10},
    }},
    IceEgg = {Pets = {
        {Name="Snow Bunny", Rarity="Rare", Multiplier=6, Chance=60},
        {Name="Frost Fox", Rarity="Epic", Multiplier=12, Chance=30},
        {Name="Ice Phoenix", Rarity="Legendary", Multiplier=25, Chance=10},
    }},
    VolcanoEgg = {Pets = {
        {Name="Ember Cub", Rarity="Epic", Multiplier=15, Chance=60},
        {Name="Magma Dragon", Rarity="Legendary", Multiplier=30, Chance=30},
        {Name="Inferno Titan", Rarity="Mythic", Multiplier=60, Chance=10},
    }},
}

return Config
