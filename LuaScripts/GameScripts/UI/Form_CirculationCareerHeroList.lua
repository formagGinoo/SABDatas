local Form_CirculationCareerHeroList = class("Form_CirculationCareerHeroList", require("UI/UIFrames/Form_CirculationCareerHeroListUI"))
local HeroSortCfg = _ENV.HeroSortCfg
local DefaultChooseFilterIndex = 2
local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")

function Form_CirculationCareerHeroList:SetInitParam(param)
end

function Form_CirculationCareerHeroList:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_heroListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_hero_list_InfinityGrid, "UIHeroListCommonItem", initGridData)
  self.m_heroListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnItemClk))
  local goFilterBtnRoot = self.m_rootTrans:Find("content_node/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  self.m_btn_Filter:SetActive(false)
  self.m_heroSort = HeroManager:GetHeroSort()
  self.m_curFilterIndex = nil
  self.m_bFilterDown = nil
  self.m_curChooseHeroID = nil
  self.m_selItemIndex = nil
end

function Form_CirculationCareerHeroList:OnActive()
  self.super.OnActive(self)
  self.m_pos = self.m_csui.m_param.pos
  self.m_curCareerID = self.m_csui.m_param.careerID
  self.m_conflictHeros = self.m_csui.m_param.conflictHeros
  self.m_inheritHeroList = {}
  self.m_curChooseHeroID = nil
  self.m_filterChanged = nil
  self.m_filterData = {
    0,
    self.m_curCareerID,
    0,
    0
  }
  self:RefreshUI()
  self:ChangeOkBtnState()
end

function Form_CirculationCareerHeroList:OnInactive()
  self.super.OnInactive(self)
  if self.m_heroListInfinityGrid and self.m_selItemIndex then
    self.m_heroListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
  end
  self.m_selItemIndex = nil
  self.m_curChooseHeroID = nil
  self.m_filterChanged = nil
end

function Form_CirculationCareerHeroList:RefreshUI()
  self.m_inheritHeroList = self:GenerateData()
  self.m_widgetBtnFilter:RefreshTabConfig(HeroSortCfg, self.m_curFilterIndex, self.m_bFilterDown, handler(self, self.OnHeroSortChanged))
  if self.m_curFilterIndex == nil then
    self.m_bFilterDown = false
    self.m_curFilterIndex = self.m_curFilterIndex or DefaultChooseFilterIndex
  end
  self:OnFilterChanged()
end

function Form_CirculationCareerHeroList:GetListOfCareerHeroes()
  local inheritList = {}
  local heroList = HeroManager:GetHeroList()
  local conflictHeroDic = {}
  for i, v in pairs(self.m_conflictHeros) do
    conflictHeroDic[v] = true
  end
  for i, v in pairs(heroList) do
    if not conflictHeroDic[v.serverData.iHeroId] then
      table.insert(inheritList, v)
    end
  end
  return inheritList
end

function Form_CirculationCareerHeroList:GenerateData()
  local list = {}
  local heroList = self:GetListOfCareerHeroes()
  for i, v in ipairs(heroList) do
    list[i] = {}
    list[i].serverData = HeroManager:GenerateCommonHeroIconData(v.serverData)
    list[i].characterCfg = v.characterCfg
  end
  return list
end

function Form_CirculationCareerHeroList:RefreshInheritHeroList(selData)
  self.m_filterChanged = false
  self.m_heroListInfinityGrid:ShowItemList(self.m_inheritHeroList, true)
  if not self.m_inheritHeroList or #self.m_inheritHeroList == 0 then
    self.m_pnl_empty:SetActive(true)
  else
    self.m_pnl_empty:SetActive(false)
  end
end

function Form_CirculationCareerHeroList:FreshSortHero()
  local heroSort = HeroManager:GetHeroSort()
  heroSort:SortHeroList(self.m_inheritHeroList, self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_CirculationCareerHeroList:OnHeroSortChanged(iIndex, bDown)
  local selData
  if self.m_selItemIndex and self.m_heroListInfinityGrid then
    self.m_heroListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
    selData = self.m_inheritHeroList[self.m_selItemIndex]
  end
  self.m_curFilterIndex = iIndex
  self.m_bFilterDown = bDown
  self:FreshSortHero()
  self:RefreshInheritHeroList(selData)
end

function Form_CirculationCareerHeroList:OnFilterChanged()
  local inheritHeroList = self:GenerateData()
  self.m_inheritHeroList = self.m_heroSort:FilterHeroList(inheritHeroList, self.m_filterData)
  self.m_filterChanged = true
  self:OnHeroSortChanged(self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_CirculationCareerHeroList:OnBtnFilterClicked()
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
  
  utils.openForm_filter(self.m_filterData, self.m_btn_Filter.transform, {x = 1, y = 1}, {x = 35, y = -40}, chooseBackFun, false)
end

function Form_CirculationCareerHeroList:ChangeOkBtnState()
  self.m_btn_yes_gray:SetActive(self.m_curChooseHeroID == nil)
  self.m_btn_yes_red:SetActive(self.m_curChooseHeroID ~= nil)
end

function Form_CirculationCareerHeroList:OnItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  self:ChooseOneItem(fjItemIndex)
  self:ChangeOkBtnState()
end

function Form_CirculationCareerHeroList:ChooseOneItem(fjItemIndex)
  local chooseHeroData = self.m_inheritHeroList[fjItemIndex]
  if not chooseHeroData then
    return
  end
  self.m_curChooseHeroID = chooseHeroData.serverData.iHeroId
  self.m_heroListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
  self.m_heroListInfinityGrid:OnChooseItem(fjItemIndex, true)
  self.m_selItemIndex = fjItemIndex
  local heroID
  if chooseHeroData then
    local tempServerData = chooseHeroData.serverData or {}
    heroID = tempServerData.iHeroId
  end
  self.m_curChooseHeroID = heroID
end

function Form_CirculationCareerHeroList:OnBtnyesgrayClicked()
  if not self.m_curChooseHeroID then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30019)
  end
end

function Form_CirculationCareerHeroList:OnBtnyesredClicked()
  if not self.m_curChooseHeroID then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30019)
    return
  end
  local vSetList = {}
  local info = {}
  info.iCareerType = self.m_curCareerID
  info.iLocation = self.m_pos
  info.iHeroID = self.m_curChooseHeroID
  table.insert(vSetList, info)
  HeroManager:ReqSetCirculationCareerHero(vSetList)
  self:OnBtnCloseClicked()
end

function Form_CirculationCareerHeroList:OnBtnnoblackClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_CIRCULATIONCAREERHEROLIST)
end

function Form_CirculationCareerHeroList:OnBtnCloseClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_CIRCULATIONCAREERHEROLIST)
end

function Form_CirculationCareerHeroList:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_CIRCULATIONCAREERHEROLIST)
end

function Form_CirculationCareerHeroList:IsOpenGuassianBlur()
  return true
end

function Form_CirculationCareerHeroList:IsFullScreen()
  return false
end

function Form_CirculationCareerHeroList:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_CirculationCareerHeroList", Form_CirculationCareerHeroList)
return Form_CirculationCareerHeroList
