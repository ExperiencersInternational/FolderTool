--[[
	FolderTool™
	A plugin to group selected items to a folder and ungroup them.
	Created by GamersInternational and LucasTutoriaisSaimo for Rii-built Studios
]]

local SelectionService = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Toolbar = plugin:CreateToolbar("FolderTool")

local Button_GroupIntoFolder = Toolbar:CreateButton(
	"Group selected items into a folder",
	"This button groups all items that are currently selected into a folder.",
	"rbxassetid://7081112821"
)

local Button_UngroupFromFolder = Toolbar:CreateButton(
	"Ungroup items in selected folder",
	"This button ungroups all items that are in the selected folder.",
	"rbxassetid://7081124672"
)


Button_GroupIntoFolder.Click:Connect(function()
	local selectedObjects = SelectionService:Get()

	if #selectedObjects == 0 then
		warn("FolderTool | You must have at least one Instance to group.")
		return
	end

	xpcall(function()
		--\\ Some instances can't be moved. We check that using xpcall.
		for _, child in ipairs(selectedObjects) do
			child.Parent = child.Parent
		end
	end, function() warn("FolderTool | One item is not moveable. Please de-select any services / any special Instances.") end)

	local folder = Instance.new("Folder")
	folder.Parent = selectedObjects[1].Parent
	for _, child in ipairs(selectedObjects) do
		child.Parent = folder
	end
	ChangeHistoryService:SetWaypoint("FolderTool: Grouped items into a folder")
end)

Button_UngroupFromFolder.Click:Connect(function()
	local selectedObjects = SelectionService:Get()

	if #selectedObjects == 0 then
		warn("FolderTool | You need to select a folder first!")
		return;
	end

	for _, child in ipairs(selectedObjects) do
		if not child:IsA("Folder") then
			warn("FolderTool | You can only un-group folders.")
			return
		end

		--\\ Validation, just making sure every children is a folder.
	end

	for _, folder in ipairs(selectedObjects) do
		for _, child in ipairs(folder:GetChildren()) do
			child.Parent = folder.Parent
		end

		folder.Parent = nil
		--\\ While it would be great, we can't :Destroy folders here.
		--   Because then, you can't click CTRL + Z to un-do it, as the folder is now locked, sadly.
		--   However, this shouldn't have that big of a performance implication.
	end

	ChangeHistoryService:SetWaypoint("FolderTool: Un-grouped items from a folder")
end)
