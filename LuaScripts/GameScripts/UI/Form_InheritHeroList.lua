local Form_InheritHeroList = class("Form_InheritHeroList", require("UI/UIFrames/Form_InheritHeroListUI"))
local HeroSortCfg = _ENV.HeroSortCfg
local DefaultChooseFilterIndex = 2
local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local INHERIT_SYNC_CD = GlobalManagerIns:GetValue_ByName("InheritCD").m_Value or ""

function Form_InheritHeroList:SetInitParam(param)
end

function Form_InheritHeroList:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_heroListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_hero_list_InfinityGrid, "UIHeroListCommonItem", initGridData)
  self.m_heroListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnItemClk))
  local goFilterBtnRoot = self.m_rootTrans:Find("content_node/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  self.m_heroSort = HeroManager:GetHeroSort()
  self.m_filterData = {}
  self.m_curFilterIndex = nil
  self.m_bFilterDown = nil
  self.m_curChooseHeroID = nil
  self.m_selItemIndex = nil
end

function Form_InheritHeroList:OnActive()
  self.super.OnActive(self)
  self.m_pos = self.m_csui.m_param.pos
  self.m_inheritHeroList = {}
  self.m_curChooseHeroID = nil
  self.m_filterChanged = nil
  self:RefreshUI()
  self:ChangeOkBtnState()
end

function Form_InheritHeroList:OnInactive()
  self.super.OnInactive(self)
  if self.m_heroListInfinityGrid and self.m_selItemIndex then
    self.m_heroListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
  end
  self.m_selItemIndex = nil
  self.m_curChooseHeroID = nil
  self.m_filterChanged = nil
end

function Form_InheritHeroList:RefreshUI()
  self.m_inheritHeroList = self:GenerateData()
  self.m_widgetBtnFilter:RefreshTabConfig(HeroSortCfg, self.m_curFilterIndex, self.m_bFilterDown, handler(self, self.OnHeroSortChanged))
  if self.m_curFilterIndex == nil then
    self.m_bFilterDown = false
    self.m_curFilterIndex = self.m_curFilterIndex or DefaultChooseFilterIndex
  end
  self:OnFilterChanged()
end

function Form_InheritHeroList:GenerateData()
  local list = {}
  local heroList = InheritManager:GetListOfInheritableHeroes()
  for i, v in ipairs(heroList) do
    list[i] = {}
    list[i].serverData = HeroManager:GenerateCommonHeroIconData(v.serverData)
    list[i].characterCfg = v.characterCfg
  end
  return list
end

function Form_InheritHeroList:RefreshInheritHeroList(selData)
  if selData and table.getn(self.m_inheritHeroList) > 0 and not self.m_filterChanged then
    for i, v in ipairs(self.m_inheritHeroList) do
      if v.serverData.iHeroId == selData.serverData.iHeroId then
        v.is_selected = true
        self.m_selItemIndex = i
      end
    end
  end
  self.m_filterChanged = false
  self.m_heroListInfinityGrid:ShowItemList(self.m_inheritHeroList, true)
end

function Form_InheritHeroList:FreshSortHero()
  local heroSort = HeroManager:GetHeroSort()
  heroSort:SortHeroList(self.m_inheritHeroList, self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_InheritHeroList:OnHeroSortChanged(iIndex, bDown)
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

function Form_InheritHeroList:OnFilterChanged()
  local inheritHeroList = self:GenerateData()
  self.m_inheritHeroList = self.m_heroSort:FilterHeroList(inheritHeroList, self.m_filterData)
  self.m_filterChanged = true
  self:OnHeroSortChanged(self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_InheritHeroList:OnBtnFilterClicked()
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

function Form_InheritHeroList:ChangeOkBtnState()
  self.m_btn_yes_gray:SetActive(self.m_curChooseHeroID == nil)
  self.m_btn_yes_red:SetActive(self.m_curChooseHeroID ~= nil)
end

function Form_InheritHeroList:OnItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  self:ChooseOneItem(fjItemIndex)
  self:ChangeOkBtnState()
end

function Form_InheritHeroList:ChooseOneItem(fjItemIndex)
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

function Form_InheritHeroList:OnBtnyesgrayClicked()
  if not self.m_curChooseHeroID then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30019)
  end
end

function Form_InheritHeroList:OnBtnyesredClicked()
  if not self.m_curChooseHeroID then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30019)
    return
  end
  local heroData = HeroManager:GetHeroDataByID(self.m_curChooseHeroID)
  local oldLv = heroData.serverData.iLevel or 0
  local newLv = InheritManager:GetInheritLevel()
  StackTop:Push(UIDefines.ID_FORM_INHERITTIPS, {
    tipsID = 1217,
    heroId = self.m_curChooseHeroID,
    levelInfo = {oldLv = oldLv, newLv = newLv},
    func1 = function()
      InheritManager:ReqInheritAddHero(self.m_curChooseHeroID, self.m_pos)
      self:OnBtnCloseClicked()
      local voice = HeroManager:GetHeroTransfusionVoice(self.m_curChooseHeroID)
      if voice and voice ~= "" then
        log.error(voice)
        CS.UI.UILuaHelper.StartPlaySFX(voice)
      end
    end
  })
end

function Form_InheritHeroList:OnBtnnoblackClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_INHERITHEROLIST)
end

function Form_InheritHeroList:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_INHERITHEROLIST)
end

function Form_InheritHeroList:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_INHERITHEROLIST)
end

function Form_InheritHeroList:IsOpenGuassianBlur()
  return true
end

function Form_InheritHeroList:IsFullScreen()
  return false
end

function Form_InheritHeroList:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_InheritHeroList", Form_InheritHeroList)
return Form_InheritHeroList
