local Form_GachaWishSecondWindow = class("Form_GachaWishSecondWindow", require("UI/UIFrames/Form_GachaWishSecondWindowUI"))
local DefaultChooseFilterIndex = 6
local HeroSortCfg = _ENV.HeroSortCfg
local WISH_HERO_MAX_COUNT = 5

function Form_GachaWishSecondWindow:SetInitParam(param)
end

function Form_GachaWishSecondWindow:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk),
    itemLongPressBackFun = handler(self, self.OnItemLongPress)
  }
  self.m_heroListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_dispatch_hero_list_InfinityGrid, "UIHeroListCommonItem", initGridData)
  local goFilterBtnRoot = self.m_rootTrans:Find("content_node/m_pnl_filter/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  self.m_heroSort = HeroManager:GetHeroSort()
  self.m_wishHeroObjList = {}
  for i = 1, WISH_HERO_MAX_COUNT do
    local common_hero_middle = self.m_hero_list.transform:Find("c_common_hero_middle" .. i).gameObject
    local commonHeroItem = self:createHeroIcon(common_hero_middle)
    commonHeroItem:SetHeroIconClickCB(function()
      self:OnHeroItemClick(i)
    end)
    self.m_wishHeroObjList[i] = commonHeroItem
  end
  self.m_filterData = {}
  self.m_curFilterIndex = nil
  self.m_bFilterDown = nil
  self.m_curChooseHeroID = nil
  self.m_selHeroList = {}
end

function Form_GachaWishSecondWindow:OnActive()
  self.super.OnActive(self)
  local params = self.m_csui.m_param
  if not params then
    return
  end
  self.m_wishListID = params.wishListID
  self.m_wishCamp = params.camp
  self.m_heroNum = params.heroNum
  self.m_gachaId = params.gachaId
  self.m_canWishHeroList = {}
  self.m_canWishHeroListBeforeFilter = {}
  self.m_curChooseHeroID = nil
  self.m_wishList = GachaManager:GetWishHeroIdByCamp(self.m_gachaId, self.m_wishCamp) or {}
  self.m_selHeroList = self.m_wishList
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_GachaWishSecondWindow:OnInactive()
  self.super.OnInactive(self)
  self.m_curChooseHeroID = nil
  self:RemoveAllEventListeners()
end

function Form_GachaWishSecondWindow:AddEventListeners()
  self:addEventListener("eGameEvent_SaveGachaWishHeroList", handler(self, self.OnSaveWishHeroList))
end

function Form_GachaWishSecondWindow:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GachaWishSecondWindow:RefreshUI()
  self.m_canWishHeroList = {}
  self.m_canWishHeroListBeforeFilter = {}
  local heroIdMap = GachaManager:GetGachaWishCfgHeroList(self.m_wishListID, self.m_wishCamp)
  for i, v in pairs(heroIdMap) do
    self.m_canWishHeroList[#self.m_canWishHeroList + 1] = GachaManager:GenerateGachaWishHeroData(v)
    self.m_canWishHeroListBeforeFilter[#self.m_canWishHeroListBeforeFilter + 1] = GachaManager:GenerateGachaWishHeroData(v)
  end
  self.m_widgetBtnFilter:RefreshTabConfig(HeroSortCfg, self.m_curFilterIndex, self.m_bFilterDown, handler(self, self.OnHeroSortChanged))
  if self.m_curFilterIndex == nil then
    self.m_bFilterDown = false
    self.m_curFilterIndex = self.m_curFilterIndex or DefaultChooseFilterIndex
  end
  local campCfg = HeroManager:GetCharacterCampCfgByCamp(self.m_wishCamp)
  CS.UI.UILuaHelper.SetAtlasSprite(self.m_campicon_Image, campCfg.m_WishListIcon, nil, nil, true)
  self.m_txt_campname_Text.text = campCfg.m_mCampName
  self:OnFilterChanged()
  self:RefreshInfinityGridSelectedUI(self.m_selHeroList)
  self:ShowTopSelectHero()
end

function Form_GachaWishSecondWindow:ShowTopSelectHero()
  for i = 1, WISH_HERO_MAX_COUNT do
    local heroId = self.m_selHeroList[i]
    if heroId then
      local index, heroData = self:CheckInTableIndex(self.m_canWishHeroListBeforeFilter, heroId)
      if heroData then
        self.m_wishHeroObjList[i]:SetHeroData(heroData.serverData, nil, nil, true, true)
        self.m_wishHeroObjList[i]:SetActive(true)
      else
        self.m_wishHeroObjList[i]:SetActive(false)
      end
    else
      self.m_wishHeroObjList[i]:SetActive(false)
    end
  end
end

function Form_GachaWishSecondWindow:RefreshInfinityGridSelectedUIOnSorted(heroList)
  if self.m_heroListInfinityGrid and self.m_canWishHeroList then
    for i, v in ipairs(self.m_canWishHeroList) do
      if table.indexof(heroList, v.serverData.iHeroId) then
        self.m_heroListInfinityGrid:OnChooseItem(i, true)
      else
        self.m_heroListInfinityGrid:OnChooseItem(i, false)
      end
    end
  end
end

function Form_GachaWishSecondWindow:RefreshInfinityGridSelectedUI(heroList)
  self.m_selHeroList = {}
  if self.m_heroListInfinityGrid and self.m_canWishHeroListBeforeFilter then
    for i, v in ipairs(self.m_canWishHeroListBeforeFilter) do
      if table.indexof(heroList, v.serverData.iHeroId) then
        self.m_selHeroList[#self.m_selHeroList + 1] = v.serverData.iHeroId
        self.m_heroListInfinityGrid:OnChooseItem(i, true)
      else
        self.m_heroListInfinityGrid:OnChooseItem(i, false)
      end
    end
  end
end

function Form_GachaWishSecondWindow:RefreshHeroList()
  self.m_heroListInfinityGrid:ShowItemList(self.m_canWishHeroList)
end

function Form_GachaWishSecondWindow:FreshSortHero()
  local heroSort = HeroManager:GetHeroSort()
  heroSort:SortHeroList(self.m_canWishHeroList, self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_GachaWishSecondWindow:OnHeroSortChanged(iIndex, bDown)
  self.m_curFilterIndex = iIndex
  self.m_bFilterDown = bDown
  self:FreshSortHero()
  self:RefreshHeroList()
end

function Form_GachaWishSecondWindow:OnFilterChanged()
  self.m_canWishHeroList = self.m_heroSort:FilterHeroList(self.m_canWishHeroListBeforeFilter, self.m_filterData)
  self:OnHeroSortChanged(self.m_curFilterIndex, self.m_bFilterDown)
  self:RefreshInfinityGridSelectedUIOnSorted(self.m_selHeroList)
end

function Form_GachaWishSecondWindow:OnBtnFilterClicked()
  local function chooseBackFun(filterData)
    self.m_curChooseHeroID = nil
    
    self.m_filterData = filterData
    self:OnFilterChanged()
    UILuaHelper.SetActive(self.m_filter_select, false)
    if self.m_filterData then
      for _, value in pairs(self.m_filterData) do
        if value ~= 0 then
          UILuaHelper.SetActive(self.m_filter_select, true)
          break
        end
      end
    end
  end
  
  utils.openForm_filter(self.m_filterData, self.m_btn_Filter.transform, {x = 0, y = 0}, {x = -35, y = 40}, chooseBackFun, false, false, true)
end

function Form_GachaWishSecondWindow:OnItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  self:ChooseOneItem(fjItemIndex)
end

function Form_GachaWishSecondWindow:OnItemLongPress(index)
  if not index then
    return
  end
  local itemIndex = index + 1
  local chooseHeroData = self.m_canWishHeroList[itemIndex]
  if not chooseHeroData then
    return
  end
  local iChooseHeroId = chooseHeroData.serverData.iHeroId
  StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {heroID = iChooseHeroId})
end

function Form_GachaWishSecondWindow:OnHeroItemClick(index)
  local heroId = self.m_selHeroList[index]
  if not heroId then
    return
  end
  local heroIndex = self:CheckInTableIndex(self.m_canWishHeroList, heroId)
  if heroIndex then
    self.m_heroListInfinityGrid:OnChooseItem(heroIndex, false)
  end
  table.remove(self.m_selHeroList, index)
  self:ShowTopSelectHero()
end

function Form_GachaWishSecondWindow:ChooseOneItem(fjItemIndex)
  local chooseHeroData = self.m_canWishHeroList[fjItemIndex]
  if not chooseHeroData then
    return
  end
  local count = table.getn(self.m_selHeroList)
  local iChooseHeroId = chooseHeroData.serverData.iHeroId
  local selTabIndex = table.indexof(self.m_selHeroList, iChooseHeroId)
  if count > self.m_heroNum or count == self.m_heroNum and not selTabIndex then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 42001)
    return
  end
  local heroID
  if chooseHeroData then
    local tempServerData = chooseHeroData.serverData or {}
    heroID = tempServerData.iHeroId
  end
  if selTabIndex then
    local heroIndex = self:CheckInTableIndex(self.m_canWishHeroList, iChooseHeroId)
    self.m_heroListInfinityGrid:OnChooseItem(heroIndex, false)
    table.remove(self.m_selHeroList, selTabIndex)
  else
    self.m_heroListInfinityGrid:OnChooseItem(fjItemIndex, true)
    table.insert(self.m_selHeroList, heroID)
  end
  self:ShowTopSelectHero()
end

function Form_GachaWishSecondWindow:CheckInTableIndex(tempTable, heroId)
  if tempTable then
    for i, v in ipairs(tempTable) do
      if v.serverData and v.serverData.iHeroId == heroId then
        return i, v
      end
    end
  end
end

function Form_GachaWishSecondWindow:OnBtnresetClicked()
  self.m_selHeroList = {}
  self:ShowTopSelectHero()
  self:RefreshInfinityGridSelectedUI(self.m_selHeroList)
end

function Form_GachaWishSecondWindow:OnBtnquitClicked()
  if #self.m_wishList == self.m_heroNum and #self.m_selHeroList == self.m_heroNum then
    local flag1 = self:TableEqual(self.m_wishList, self.m_selHeroList)
    local flag2 = self:TableEqual(self.m_selHeroList, self.m_wishList)
    if not flag1 or not flag2 then
      utils.popUpDirectionsUI({
        tipsID = 1158,
        func1 = function()
          self:CloseForm()
        end
      })
    else
      self:CloseForm()
    end
  else
    self:CloseForm()
  end
end

function Form_GachaWishSecondWindow:OnBtnsendsureClicked()
  if self.m_gachaId and self.m_selHeroList then
    local wishList = GachaManager:GetGachaWishListById(self.m_gachaId)
    local selList = {}
    for i, v in pairs(wishList) do
      local flag = false
      for m, n in pairs(self.m_wishList) do
        if v == n then
          flag = true
          break
        end
      end
      if not flag then
        selList[#selList + 1] = v
      end
    end
    table.insertto(selList, self.m_selHeroList)
    if #self.m_selHeroList < self.m_heroNum then
      utils.popUpDirectionsUI({
        tipsID = 1157,
        func1 = function()
          GachaManager:ReqGachaSetWishList(self.m_gachaId, selList)
        end
      })
    else
      GachaManager:ReqGachaSetWishList(self.m_gachaId, selList)
    end
  end
end

function Form_GachaWishSecondWindow:OnSaveWishHeroList()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 42002)
  self:CloseForm()
end

function Form_GachaWishSecondWindow:IsOpenGuassianBlur()
  return true
end

function Form_GachaWishSecondWindow:TableEqual(table1, table2)
  if table1 and table2 then
    for i, v in pairs(table1) do
      local flag = false
      for m, n in pairs(table2) do
        if v == n then
          flag = true
          break
        end
      end
      if not flag then
        return false
      end
    end
    return true
  end
  return false
end

function Form_GachaWishSecondWindow:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GachaWishSecondWindow", Form_GachaWishSecondWindow)
return Form_GachaWishSecondWindow
