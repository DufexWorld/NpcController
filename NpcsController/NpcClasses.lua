local _Classes = {
   Human = {
      ClassName = "Human",
      WalkSpeed = 4,
      RunSpeed = 15,
      CanBeDamaged = true,
      CanJump = false,
      Cloths = true,
      AutoName = true,
      AutoPath = true,
      Health = 100,
      MaxHealth = 100,
      Animations = require(script.Parent.NpcsData.Human["Human.animations"]),
      MetaTarget = require(script.Parent.NpcsData.Human["Human.class"]),
   },
   MissionCoordinator = {
      ClassName = "MissionCoordinator",
      WalkSpeed = 12,
      CanBeDamaged = false,
      Mission = nil,
   },
   Agent = {
      ClassName = "Agent",
      WalkSpeed = 4,
      RunSpeed = 15,
      Cloths = false,
      CanBeDamaged = false,
      CanJump = false,
      Health = math.huge,
      MaxHealth = math.huge,
      Animations = require(script.Parent.NpcsData.Human["Human.animations"]),
      MetaTarget = require(script.Parent.NpcsData.Agents["Agent.class"])
   },
   Sorcerer = {
      ClassName = "Sorcerer",
      WalkSpeed = 12,
      CanBeDamaged = true,
      Health = 100,
      MaxHealth = 100,
   },
   Curse = {
      ClassName = "Curse",
      WalkSpeed = 12,
      CanBeDamaged = true,
      Health = 100,
      MaxHealth = 100,
   },
   Bandit = {
      ClassName = "Bandit",
      WalkSpeed = 15,
      CanBeDamaged = true,
      Respawn = true,
      Health = 150,
      MaxHealth = 150,
      AttackDamage = 5;
      Animations = require(script.Parent.NpcsData.Human["Human.animations"]),
      MetaTarget = require(script.Parent.NpcsData.Bandit["Bandit.class"]),
   }
};

return table.freeze(_Classes)