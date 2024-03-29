--[[
	FolderTool
	A plugin to group selected items to a folder and ungroup them.
	Created by GamersInternational and LucasMZ_RBX
	(C) 2022
]]

local SelectionService = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Toolbar = plugin:CreateToolbar("FolderTool")

local Button_GroupIntoFolder = Toolbar:CreateButton(
	"Group",
	"This button groups all items that are currently selected into a folder.",
	"rbxassetid://10627260996"
)

local Button_UngroupFromFolder = Toolbar:CreateButton(
	"Ungroup",
	"This button ungroups all items that are in the selected folder.",
	"rbxassetid://10627263013"
)

local Button_ClassConversion = Toolbar:CreateButton(
	"Convert",
	"This button converts the class of a selected model",
	"rbxassetid://10627262177"
)

Button_GroupIntoFolder.Click:Connect(function()
	local selectedObjects = SelectionService:Get()
	ChangeHistoryService:SetWaypoint("FolderTool: Pre grouping items into a folder")

	if #selectedObjects == 0 then
		warn("You must have at least one Instance to group.")
		return
	end

	local sucess = pcall(function()
		--\\ Some instances can't be moved. We check that using a pcall.

		for _, child in ipairs(selectedObjects) do
			child.Parent = child.Parent
		end
	end)

	if not sucess then
		warn("One item is not movable. Please un-select any services / any special Instances.")
		return;
	end

	local folder = Instance.new("Folder", selectedObjects[1].Parent)
	for _, child in ipairs(selectedObjects) do
		child.Parent = folder
	end
	SelectionService:Set({ folder }) -- {} as :Set() takes an array of objects

	ChangeHistoryService:SetWaypoint("FolderTool: Grouped items into a folder")
end)

Button_UngroupFromFolder.Click:Connect(function()
	local selectedObjects = SelectionService:Get()

	if #selectedObjects == 0 then
		warn("You need to select a folder first!")
		return;
	end

	for _, child in ipairs(selectedObjects) do
		if not child:IsA("Folder") then
			warn("You can only un-group folders.")
			return
		end

		--\\ Validation, just making sure every children is a folder.
	end
	
	local objectsToSelect = {}

	for _, folder in ipairs(selectedObjects) do
		ChangeHistoryService:SetWaypoint("FolderTool: Pre-ungrouping items from a folder")
		for _, child in ipairs(folder:GetChildren()) do
			child.Parent = folder.Parent
			table.insert(objectsToSelect, child)
		end

		folder.Parent = nil
		--\\ While it would be great, we can't :Destroy folders here.
		--   Because then, you can't click CTRL + Z to un-do it, as the folder is now locked, sadly.
		--   However, this shouldn't have that big of a performance implication.
	end
	
	SelectionService:Set(objectsToSelect)
	ChangeHistoryService:SetWaypoint("FolderTool: Un-grouped items from a folder")
end)

Button_ClassConversion.Click:Connect(function()
	local selectedObjects = SelectionService:Get()
	ChangeHistoryService:SetWaypoint("FolderTool: Pre class conversion")
	for _, object in ipairs(selectedObjects) do
		if object.ClassName ~= "Model" then
		  continue
		end
	  
		local folder = Instance.new("Folder")
		folder.Name = object.Name
	  
		for _, child in ipairs(object:GetChildren()) do
		  child.Parent = folder
		end
	  
		folder.Parent = object.Parent
		object:Destroy()
	  end
	  
	  -- set history waypoint
	  ChangeHistoryService:SetWaypoint("FolderTool: Completed class conversion")
end)