--[[
	FolderTool

	A plugin to group selected items to a folder and ungroup them.

	Created by GamersInternational and LucasTutoriaisSaimo for Rii-built Studios

	(C) 2021
]]

local SelectionService = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Toolbar = plugin:CreateToolbar("FolderTool")

local Images = {
	Fold = 'rbxassetid://7081112821',
	Unfold = 'rbxassetid://7081124672',
}

local Buttons = {
	Fold = Toolbar:CreateButton(
		"Group selected items into a folder",
		"This button groups all items that are currently selected into a folder.",
		Images.Fold
	),

	Unfold = Toolbar:CreateButton(
		"Ungroup items in selected folder",
		"This button ungroups all items that are in the selected folder.",
		Images.Unfold
	)
}

local function fold_selection()
	local selectedObjects = SelectionService:Get()

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

	SelectionService:Set({ folder }) -- Selecting the folder at the end
	ChangeHistoryService:SetWaypoint("FolderTool: Grouped items into a folder")
end

local function unfold_selection()
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

	local ToBeSelected = {}

	for _, folder in ipairs(selectedObjects) do
		for _, child in ipairs(folder:GetChildren()) do
			child.Parent = folder.Parent
			table.insert(ToBeSelected, child)
		end

		folder.Parent = nil
		--\\ While it would be great, we can't :Destroy folders here.
		--   Because then, you can't click CTRL + Z to un-do it, as the folder is now locked, sadly.
		--   However, this shouldn't have that big of a performance implication.
	end

	SelectionService:Set(ToBeSelected) -- Selecting the children after ungrouping
	ChangeHistoryService:SetWaypoint("FolderTool: Un-grouped items from a folder")
end

-- Buttons
Buttons.Fold.Click:Connect(fold_selection)
Buttons.Unfold.Click:Connect(unfold_selection)

-- Actions
plugin:CreatePluginAction('FoldObjects', 'Group selected items into a folder', 'Groups all items that are currently selected into a folder.').Triggered:Connect(fold_selection)
plugin:CreatePluginAction('UnfoldObjects', 'Ungroup items in selected folder', 'This button ungroups all items that are in the selected folder.').Triggered:Connect(unfold_selection)