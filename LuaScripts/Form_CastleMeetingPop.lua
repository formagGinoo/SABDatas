local Form_CastleMeetingPop = class("Form_CastleMeetingPop", require("UI/UIFrames/Form_CastleMeetingPopUI"))
local HeroSortCfg = HeroCouncilSortCfg
local MaxHeroCount = 5

function Form_CastleMeetingPop:SetInitParam(param)
end

function Form_CastleMeetingPop:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnFilter = self:createFilterButton(self.m_meeting_filter)
  self.m_heroSort = HeroManager:GetHeroSort()
  self.m_allHeroList = nil
  self.m_curFilterIndex = nil
  self.m_bFilterDown = nil
  self.m_curChooseHeroList = nil
  self.m_grayImgMaterial = self.m_img_reset_Image.material
  self.heroPrefabHelper = self.m_pnl_hero:GetComponent("PrefabHelper")
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClick)
  }
  self.m_luaHeroListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "Castle/CouncilHallHeroListItem", initGridData)
end

function Form_CastleMeetingPop:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(188)
end

function Form_CastleMeetingPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_CastleMeetingPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleMeetingPop:FreshData()
  self.m_filterData = {}
  self.m_curChooseHeroList = table.deepcopy(CouncilHallManager:GetCouncilHero())
  self.m_allHeroList = CouncilHallManager:GetCouncilHallHeroList()
  if self.m_curFilterIndex == nil then
    self.m_bFilterDown = false
    self.m_curFilterIndex = self.m_curFilterIndex or 1
  end
end

function Form_CastleMeetingPop:FreshUI()
  self.m_widgetBtnFilter:RefreshTabConfig(HeroSortCfg, self.m_curFilterIndex, self.m_bFilterDown, handler(self, self.OnHeroSortChanged))
  self:OnFilterChanged()
  self:FreshChooseHeroList()
end

function Form_CastleMeetingPop:FreshHeroList()
  self.m_luaHeroListInfinityGrid:ShowItemList(self.m_allShowHeroList)
end

function Form_CastleMeetingPop:FreshChooseHeroList()
  utils.ShowPrefabHelper(self.heroPrefabHelper, handler(self, self.OnInitChooseHeroItem), self.m_curChooseHeroList)
  if #self.m_curChooseHeroList == 0 then
    self.m_img_reset_Image.material = self.m_grayImgMaterial
    self.m_btn_confirm:SetActive(false)
    self.m_btn_gray:SetActive(true)
  else
    self.m_img_reset_Image.material = nil
    self.m_btn_confirm:SetActive(true)
    self.m_btn_gray:SetActive(false)
  end
end

function Form_CastleMeetingPop:OnInitChooseHeroItem(go, index, hero_id)
  local idx = index + 1
  go.transform.localScale = Vector3(0.74, 0.74, 1)
  local commonHeroItem = self:createHeroIcon(go)
  local heroData = HeroManager:GetHeroDataByID(hero_id)
  commonHeroItem:SetHeroData(heroData.serverData, nil, nil, true)
  commonHeroItem:SetHeroIconClickCB(function()
    self:OnChooseHeroItemClick(hero_id)
  end)
end

function Form_CastleMeetingPop:OnChooseHeroItemClick(hero_id)
  for i, v in ipairs(self.m_curChooseHeroList) do
    if v == hero_id then
      table.remove(self.m_curChooseHeroList, i)
      break
    end
  end
  self:FreshChooseHeroList()
  for i, v in ipairs(self.m_allShowHeroList) do
    if v.serverData.iHeroId == hero_id then
      v.is_CouncilSelected = false
      self.m_luaHeroListInfinityGrid:ReBind(i)
      break
    end
  end
end

function Form_CastleMeetingPop:OnHeroItemClick(index, go)
  local itemIndex = index + 1
  local data = self.m_allShowHeroList[itemIndex]
  if not data then
    return
  end
  local id = data.serverData.iHeroId
  local trueIdentity = data.characterCfg.m_TrueIdentity
  local is_CouncilSelected = false
  for i, v in ipairs(self.m_curChooseHeroList) do
    if v == id then
      is_CouncilSelected = true
      table.remove(self.m_curChooseHeroList, i)
      break
    end
  end
  if not is_CouncilSelected and #self.m_curChooseHeroList >= MaxHeroCount then
    return
  end
  if not is_CouncilSelected then
    local is_have = false
    for _, heroID in ipairs(self.m_curChooseHeroList) do
      local cfg = HeroManager:GetHeroConfigByID(heroID)
      if trueIdentity and trueIdentity ~= 0 and trueIdentity == cfg.m_TrueIdentity then
        is_have = cfg
        break
      end
    end
    if is_have then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(47004), is_have.m_mName, data.characterCfg.m_mName))
      return
    end
    table.insert(self.m_curChooseHeroList, id)
  end
  self:FreshChooseHeroList()
  data.is_CouncilSelected = not is_CouncilSelected
  self.m_luaHeroListInfinityGrid:ReBind(itemIndex)
end

function Form_CastleMeetingPop:FreshSortHero()
  self.m_heroSort:SortCouncilHeroList(self.m_allShowHeroList, self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_CastleMeetingPop:OnHeroSortChanged(iIndex, bDown)
  self.m_curFilterIndex = iIndex
  self.m_bFilterDown = bDown
  self:FreshSortHero()
  self:FreshHeroList()
end

function Form_CastleMeetingPop:OnBtnFilterClicked()
  local function chooseBackFun(filterData)
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
  
  utils.openForm_filter(self.m_filterData, self.m_btn_Filter.transform, {x = 0, y = 0}, {x = -35, y = 40}, chooseBackFun, false)
end

function Form_CastleMeetingPop:OnFilterChanged()
  self.m_allShowHeroList = self.m_heroSort:FilterHeroList(self.m_allHeroList, self.m_filterData)
  for i, v in ipairs(self.m_allShowHeroList) do
    v.is_CouncilSelected = false
    for index = #self.m_curChooseHeroList, 1, -1 do
      local hero_id = self.m_curChooseHeroList[index]
      if v.serverData.iHeroId == hero_id then
        v.is_CouncilSelected = true
        break
      end
    end
  end
  self:OnHeroSortChanged(self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_CastleMeetingPop:OnBtnresetClicked()
  if #self.m_curChooseHeroList == 0 then
    return
  end
  self.m_curChooseHeroList = {}
  self:FreshUI()
end

function Form_CastleMeetingPop:OnBtncancelClicked()
  self:CloseForm()
end

function Form_CastleMeetingPop:OnBtnconfirmClicked()
  local oriHeroList = CouncilHallManager:GetCouncilHero()
  local is_changed = false
  if #oriHeroList == #self.m_curChooseHeroList then
    for index, value in ipairs(oriHeroList) do
      if value ~= self.m_curChooseHeroList[index] then
        is_changed = true
        break
      end
    end
  else
    is_changed = true
  end
  if not is_changed then
    self:CloseForm()
    return
  end
  CouncilHallManager:RqsSetCouncilHero(self.m_curChooseHeroList, function()
    self:CloseForm()
  end)
end

function Form_CastleMeetingPop:OnBtngrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(47003))
end

function Form_CastleMeetingPop:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleMeetingPop", Form_CastleMeetingPop)
return Form_CastleMeetingPop
