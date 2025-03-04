local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local GetAuctionSellItemInfo = GetAuctionSellItemInfo
local GetItemQualityColor = GetItemQualityColor

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	local AuctionFrame = _G.AuctionFrame
	AuctionFrame:StripTextures(true)
	AuctionFrame:CreateBackdrop('Transparent')
	AuctionFrame.backdrop:Point('TOPLEFT', 10, 0)
	AuctionFrame.backdrop:Point('BOTTOMRIGHT', 0, 0)

	local Buttons = {
		_G.BrowseSearchButton,
		_G.BrowseBidButton,
		_G.BrowseBuyoutButton,
		_G.BrowseCloseButton,
		_G.BidBidButton,
		_G.BidBuyoutButton,
		_G.BidCloseButton,
		_G.AuctionsCreateAuctionButton,
		_G.AuctionsCancelAuctionButton,
		_G.AuctionsStackSizeMaxButton,
		_G.AuctionsNumStacksMaxButton,
		_G.AuctionsCloseButton
	}

	local CheckBoxes = {
		_G.IsUsableCheckButton,
		_G.ShowOnPlayerCheckButton
	}

	local EditBoxes = {
		_G.BrowseName,
		_G.BrowseMinLevel,
		_G.BrowseMaxLevel,
		_G.BrowseBidPriceGold,
		_G.BrowseBidPriceSilver,
		_G.BrowseBidPriceCopper,
		_G.BidBidPriceGold,
		_G.BidBidPriceSilver,
		_G.BidBidPriceCopper,
		_G.AuctionsStackSizeEntry,
		_G.AuctionsNumStacksEntry,
		_G.StartPriceGold,
		_G.StartPriceSilver,
		_G.StartPriceCopper,
		_G.BuyoutPriceGold,
		_G.BuyoutPriceCopper,
		_G.BuyoutPriceSilver
	}

	local SortTabs = {
		_G.BrowseQualitySort,
		_G.BrowseLevelSort,
		_G.BrowseDurationSort,
		_G.BrowseHighBidderSort,
		_G.BrowseCurrentBidSort,
		_G.BidQualitySort,
		_G.BidLevelSort,
		_G.BidDurationSort,
		_G.BidBuyoutSort,
		_G.BidStatusSort,
		_G.BidBidSort,
		_G.AuctionsQualitySort,
		_G.AuctionsDurationSort,
		_G.AuctionsHighBidderSort,
		_G.AuctionsBidSort,
	}

	for _, Button in pairs(Buttons) do
		S:HandleButton(Button, true)
	end

	for _, CheckBox in pairs(CheckBoxes) do
		S:HandleCheckBox(CheckBox)
	end

	for _, EditBox in pairs(EditBoxes) do
		S:HandleEditBox(EditBox)
		EditBox:SetTextInsets(1, 1, -1, 1)
	end

	for i = 1, AuctionFrame.numTabs do
		local tab = _G['AuctionFrameTab'..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point('BOTTOMLEFT', AuctionFrame, 'BOTTOMLEFT', 20, -30)
			tab.SetPoint = E.noop
		end
	end

	for _, Tab in pairs(SortTabs) do
		Tab:StripTextures()
		Tab:SetNormalTexture([[Interface\Buttons\UI-SortArrow]])
		Tab:StyleButton()
	end

	for _, Filter in pairs(_G.AuctionFrameBrowse.FilterButtons) do
		Filter:StripTextures()
		Filter:StyleButton()

		Filter = Filter:GetName()
		_G[Filter..'Lines']:SetAlpha(0)
		_G[Filter..'Lines'].SetAlpha = E.noop
		_G[Filter..'NormalTexture']:SetAlpha(0)
		_G[Filter..'NormalTexture'].SetAlpha = E.noop
	end

	S:HandleCloseButton(_G.AuctionFrameCloseButton, AuctionFrame.backdrop)

	_G.AuctionFrameMoneyFrame:Point('BOTTOMRIGHT', AuctionFrame, 'BOTTOMLEFT', 181, 11)

	-- Browse Frame
	_G.BrowseTitle:ClearAllPoints()
	_G.BrowseTitle:Point('TOP', AuctionFrame, 'TOP', 0, -5)

	_G.BrowseScrollFrame:StripTextures()

	_G.BrowseFilterScrollFrame:StripTextures()

	S:HandleScrollBar(_G.BrowseFilterScrollFrameScrollBar)
	S:HandleScrollBar(_G.BrowseScrollFrameScrollBar)
	S:HandleNextPrevButton(_G.BrowsePrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(_G.BrowseNextPageButton, nil, nil, true)

	-- Bid Frame
	_G.BidTitle:ClearAllPoints()
	_G.BidTitle:Point('TOP', _G.AuctionFrame, 'TOP', 0, -5)

	_G.BidScrollFrame:StripTextures()

	_G.BidBidText:ClearAllPoints()
	_G.BidBidText:Point('RIGHT', _G.BidBidButton, 'LEFT', -270, 2)

	_G.BidCloseButton:Point('BOTTOMRIGHT', 66, 6)
	_G.BidBuyoutButton:Point('RIGHT', _G.BidCloseButton, 'LEFT', -4, 0)
	_G.BidBidButton:Point('RIGHT', _G.BidBuyoutButton, 'LEFT', -4, 0)

	_G.BidBidPrice:Point('BOTTOM', 25, 10)

	S:HandleScrollBar(_G.BidScrollFrameScrollBar)
	_G.BidScrollFrameScrollBar:ClearAllPoints()
	_G.BidScrollFrameScrollBar:Point('TOPRIGHT', _G.BidScrollFrame, 'TOPRIGHT', 23, -18)
	_G.BidScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.BidScrollFrame, 'BOTTOMRIGHT', 0, 16)

	--Auctions Frame
	_G.AuctionsTitle:ClearAllPoints()
	_G.AuctionsTitle:Point('TOP', AuctionFrame, 'TOP', 0, -5)

	_G.AuctionsScrollFrame:StripTextures()

	S:HandleScrollBar(_G.AuctionsScrollFrameScrollBar)
	_G.AuctionsScrollFrameScrollBar:ClearAllPoints()
	_G.AuctionsScrollFrameScrollBar:Point('TOPRIGHT', _G.AuctionsScrollFrame, 'TOPRIGHT', 23, -20)
	_G.AuctionsScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.AuctionsScrollFrame, 'BOTTOMRIGHT', 0, 18)

	_G.AuctionsCloseButton:Point('BOTTOMRIGHT', 66, 6)
	_G.AuctionsCancelAuctionButton:Point('RIGHT', _G.AuctionsCloseButton, 'LEFT', -4, 0)

	_G.AuctionsStackSizeEntry.backdrop:SetAllPoints()
	_G.AuctionsNumStacksEntry.backdrop:SetAllPoints()

	_G.AuctionsItemButton:StripTextures()
	_G.AuctionsItemButton:SetTemplate('Default', true)
	_G.AuctionsItemButton:StyleButton()

	_G.AuctionsItemButton:HookScript('OnEvent', function(self, event)
		if event == 'NEW_AUCTION_UPDATE' and self:GetNormalTexture() then
			self:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			self:GetNormalTexture():SetInside()

			local quality = select(4, GetAuctionSellItemInfo())
			if quality then
				self:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	S:HandleDropDownBox(_G.BrowseDropDown, 155)
	S:HandleDropDownBox(_G.PriceDropDown)

	-- Progress Frame
	_G.AuctionProgressFrame:StripTextures()
	_G.AuctionProgressFrame:SetTemplate('Transparent')

	local AuctionProgressFrameCancelButton = _G.AuctionProgressFrameCancelButton
	S:HandleButton(AuctionProgressFrameCancelButton)
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	AuctionProgressFrameCancelButton:GetNormalTexture():SetTexture(E.Media.Textures.Close)
	AuctionProgressFrameCancelButton:GetNormalTexture():SetInside()
	AuctionProgressFrameCancelButton:Size(28)
	AuctionProgressFrameCancelButton:Point('LEFT', _G.AuctionProgressBar, 'RIGHT', 8, 0)

	for Frame, NumButtons in pairs({['Browse'] = _G.NUM_BROWSE_TO_DISPLAY, ['Auctions'] = _G.NUM_AUCTIONS_TO_DISPLAY, ['Bid'] = _G.NUM_BIDS_TO_DISPLAY}) do
		for i = 1, NumButtons do
			local Button = _G[Frame..'Button'..i]
			local ItemButton = _G[Frame..'Button'..i..'Item']
			local Texture = _G[Frame..'Button'..i..'ItemIconTexture']
			local Name = _G[Frame..'Button'..i..'Name']
			local Highlight = _G[Frame..'Button'..i..'Highlight']

			ItemButton:SetTemplate()
			ItemButton:StyleButton()
			ItemButton.IconBorder:SetAlpha(0)

			Button:StripTextures()
			Button:SetHighlightTexture(E.media.blankTex)
			Button:GetHighlightTexture():SetVertexColor(1, 1, 1, .2)

			ItemButton:GetNormalTexture():SetTexture()
			Button:GetHighlightTexture():Point("TOPLEFT", ItemButton, "TOPRIGHT", 2, 0)
			Button:GetHighlightTexture():Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -2, 5)

			S:HandleIcon(Texture)
			Texture:SetInside()
		end
	end

	-- Custom Backdrops
	for _, Frame in pairs({_G.AuctionFrameBrowse, _G.AuctionFrameAuctions}) do
		Frame.LeftBackground = CreateFrame('Frame', nil, Frame)
		Frame.LeftBackground:SetTemplate('Transparent')
		Frame.LeftBackground:SetFrameLevel(Frame:GetFrameLevel() - 1)

		Frame.RightBackground = CreateFrame('Frame', nil, Frame)
		Frame.RightBackground:SetTemplate('Transparent')
		Frame.RightBackground:SetFrameLevel(Frame:GetFrameLevel() - 1)
	end

	local AuctionFrameAuctions = _G.AuctionFrameAuctions
	AuctionFrameAuctions.LeftBackground:Point('TOPLEFT', 15, -72)
	AuctionFrameAuctions.LeftBackground:Point('BOTTOMRIGHT', -545, 34)

	AuctionFrameAuctions.RightBackground:Point('TOPLEFT', AuctionFrameAuctions.LeftBackground, 'TOPRIGHT', 3, 0)
	AuctionFrameAuctions.RightBackground:Point('BOTTOMRIGHT', AuctionFrame, -8, 34)

	local AuctionFrameBrowse = _G.AuctionFrameBrowse
	AuctionFrameBrowse.LeftBackground:Point('TOPLEFT', 20, -103)
	AuctionFrameBrowse.LeftBackground:Point('BOTTOMRIGHT', -575, 34)

	AuctionFrameBrowse.RightBackground:Point('TOPLEFT', AuctionFrameBrowse.LeftBackground, 'TOPRIGHT', 4, 0)
	AuctionFrameBrowse.RightBackground:Point('BOTTOMRIGHT', AuctionFrame, 'BOTTOMRIGHT', -8, 34)

	local AuctionFrameBid = _G.AuctionFrameBid
	AuctionFrameBid.Background = CreateFrame('Frame', nil, AuctionFrameBid)
	AuctionFrameBid.Background:SetTemplate('Transparent')
	AuctionFrameBid.Background:Point('TOPLEFT', 22, -72)
	AuctionFrameBid.Background:Point('BOTTOMRIGHT', 66, 34)
	AuctionFrameBid.Background:SetFrameLevel(AuctionFrameBid:GetFrameLevel() - 1)
end

S:AddCallbackForAddon('Blizzard_AuctionUI', 'AuctionHouse', LoadSkin)
