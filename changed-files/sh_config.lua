PS.Config = {}

-- Edit below

PS.Config.CommunityName = "Pointshop"

PS.Config.DataProvider = 'pdata'

PS.Config.Branch = 'https://raw.github.com/adamdburton/pointshop/master/' -- Master is most stable, used for version checking.
PS.Config.CheckVersion = true -- Do you want to be notified when a new version of Pointshop is avaliable?

PS.Config.ShopKey = 'F4' -- Any Uppercase key or blank to disable
PS.Config.ShopCommand = 'ps_shop' -- Console command to open the shop, set to blank to disable
PS.Config.ShopChatCommand = '!shop' -- Chat command to open the shop, set to blank to disable

PS.Config.NotifyOnJoin = true -- Should players be notified about opening the shop when they spawn?

PS.Config.PointsOverTime = false -- Should players be given points over time?
PS.Config.PointsOverTimeDelay = 1 -- If so, how many minutes apart?
PS.Config.PointsOverTimeAmount = 10 -- And if so, how many points to give after the time?

PS.Config.AdminCanAccessAdminTab = true -- Can Admins access the Admin tab?
PS.Config.SuperAdminCanAccessAdminTab = true -- Can SuperAdmins access the Admin tab?

PS.Config.CanPlayersGivePoints = true -- Can players give points away to other players?
PS.Config.CanPlayersGiveItems = true -- Can players give items away to other players?
PS.Config.DisplayPreviewInMenu = true -- Can players see the preview of their items in the menu?

PS.Config.PointsName = 'Points' -- What are the points called?
PS.Config.SortItemsBy = 'Price' -- How are items sorted? Set to 'Price' to sort by price.

-- Edit below if you know what you're doing

PS.Config.CalculateBuyPrice = function(ply, item)
	-- You can do different calculations here to return how much an item should cost to buy.
	-- There are a few examples below, uncomment them to use them.
	
	-- Everything half price for admins:
	-- if ply:IsAdmin() then return math.Round(item.Price * 0.5) end
	
	-- 25% off for the 'donators' group
	-- if ply:IsUserGroup('donators') then return math.Round(item.Price * 0.75) end
	
	return math.Round(item.Price * 1)
end

PS.Config.CalculateSellPrice = function(ply, item)
	return math.Round(item.Price * 0.75) -- 75% or 3/4 (rounded) of the original item price
end

-- colors
PS.Config.Dark = Color(73, 77, 100)
PS.Config.Darker = Color(54, 58, 79)
PS.Config.Darkest = Color(36, 39, 58)
PS.Config.Black = Color(0, 0, 0)
PS.Config.White = Color(202, 211, 245)

PS.Config.Red = Color(237, 135, 150)
PS.Config.Green = Color(139, 213, 202)
PS.Config.Blue = Color(138, 173, 244)

PS.Config.NotAfford = PS.Config.Red
PS.Config.Afford = PS.Config.Green
PS.Config.Owned = PS.Config.Blue

-- icons
PS.Config.AdminIcon = Material("icon16/shield.png")
PS.Config.EquippedIcon = Material("icon16/eye.png")
PS.Config.GroupIcon = Material("icon16/group.png")
