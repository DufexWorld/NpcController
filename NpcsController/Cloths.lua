local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function weld(t1, t2)
   local weld = t1:FindFirstChildOfClass("Weld")
   --weld.Part0 = t2
   weld.Part1 = t2
   return weld
end

local Clothes = ReplicatedStorage.Packages.Clothes
local MainClass = {}
local Packages: Classes = {
   Eyes = {
      Folder = Clothes.Eyes,
      Sort = function(self): Decal
         local List = self.Folder:GetChildren()
         
         return List[math.random(1, #List)]
      end,
      Assert = function(self, target, eyes)
         local head = target:FindFirstChild("Head")
         eyes:Clone().Parent = head
      end,
   },
   Mouths = {
      Folder = Clothes.Mouth,
      Sort = function(self): Decal
         local List = self.Folder:GetChildren()
         
         return List[math.random(1, #List)]
      end,
      Assert = function(self, target, Mouths)
         local head = target:FindFirstChild("Head")
         Mouths:Clone().Parent = head
      end,
   },
   Pants = {
      Folder = Clothes.Pants,
      Sort = function(self): Decal
         local List = self.Folder:GetChildren()
         
         return List[math.random(1, #List)]
      end,
      Assert = function(self, target: Model, Pants: Model)
         Pants = Pants:Clone()
         
         local rightLegCharacter, leftLegCharacter = 
         target:FindFirstChild("Right Leg"), target:FindFirstChild("Left Leg")
         local modelRight, modelLeft = 
         Pants:FindFirstChild("Right Leg"), Pants:FindFirstChild("Left Leg")
         
         modelRight.CFrame = rightLegCharacter.CFrame
         modelLeft.CFrame = leftLegCharacter.CFrame

         weld(modelRight, rightLegCharacter)
         weld(modelLeft, leftLegCharacter)
         Pants.Parent = target
      end,
   },
   Shirts = {
      Folder = Clothes.Shirt,
      Sort = function(self): Decal
         local List = self.Folder:GetChildren()
         
         return List[math.random(1, #List)]
      end,
      Assert = function(self, target: Model, Shirt: Model)
         Shirt = Shirt:Clone()
         
         local rightArmCharacter, leftArmCharacter, Torso = 
         target:FindFirstChild("Right Arm"), target:FindFirstChild("Left Arm"), target:FindFirstChild("Torso")
         local modelRight, modelLeft, modelTorso = 
         Shirt:FindFirstChild("Right Arm"), Shirt:FindFirstChild("Left Arm"), Shirt:FindFirstChild("Torso")
         
         if modelRight then
            modelRight.CFrame = rightArmCharacter.CFrame
            weld(modelRight, rightArmCharacter)
         end
         if modelLeft then
            modelLeft.CFrame = leftArmCharacter.CFrame
            weld(modelLeft, leftArmCharacter)
         end
         if modelTorso then            
            modelTorso.CFrame = Torso.CFrame
            weld(modelTorso, Torso)
         end

         Shirt.Parent = target
      end,
   },
   Hair = {
      Folder = Clothes.PrimaryHair,
      Sort = function(self): Decal
         local List = self.Folder:GetChildren()
         
         return List[math.random(1, #List)]
      end,
      Assert = function(self, target: Model, Hair: Model)
         Hair = Hair:Clone()         
         local Hair, Head = Hair:FindFirstChild("Head"), target:FindFirstChild("Head")
         Hair.CFrame = Head:FindFirstChild("HairAttachment").WorldCFrame

         weld(Hair, Head)
         Hair.Parent = target
      end,
   },
   Shoes = {
      Folder = Clothes.Shoes,
      Sort = function(self): Decal
         local List = self.Folder:GetChildren()
         
         return List[math.random(1, #List)]
      end,
      Assert = function(self, target: Model, Shoes: Model)
         Shoes = Shoes:Clone()
         
         local rightLegCharacter, leftLegCharacter = 
         target:FindFirstChild("Right Leg"), target:FindFirstChild("Left Leg")
         local modelRight, modelLeft = 
         Shoes:FindFirstChild("Right Leg"), Shoes:FindFirstChild("Left Leg")
         
         modelRight.CFrame = rightLegCharacter.CFrame
         modelLeft.CFrame = leftLegCharacter.CFrame

         weld(modelRight, rightLegCharacter)
         weld(modelLeft, leftLegCharacter)
         Shoes.Parent = target
      end,
   },
}

function MainClass:setColorForModel(target, color)
   for _, part: BasePart in target:GetChildren() do
      if part:IsA("BasePart") then
         part.Color = color
      end
   end
end

function MainClass:applyFor(character: Model)
   task.defer(function()
      local color = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))

      for _, cloth in Packages do
         local model = cloth:Sort()         
         cloth:Assert(character, model)
         self:setColorForModel(model, color)
      end
   end)
end

MainClass.Package = Packages

type Classes = {[string]: {
   Assert: (_: any, characterTarget: Model, cloth: Model) -> (),
   Sort: (_: any)-> Model,
   Folder: Folder
}} & typeof(MainClass)

return MainClass