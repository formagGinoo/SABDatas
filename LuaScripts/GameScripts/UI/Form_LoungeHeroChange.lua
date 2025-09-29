local Form_LoungeHeroChange = class("Form_LoungeHeroChange", require("UI/UIFrames/Form_LoungeHeroChangeUI"))

function Form_LoungeHeroChange:SetInitParam(param)
end

function Form_LoungeHeroChange:AfterInit()
  self.super.AfterInit(self)
  local InitData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_loungeChangeInfinityGrid = self:CreateInfinityGrid(self.m_item_list_InfinityGrid, "Lounge/UILoungeChangeHeroItem", InitData)
end

function Form_LoungeHeroChange:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curHeroId = tParam.heroId
  if not self.m_curHeroId then
    return
  end
  self:RefreshUI()
  self.m_csui.m_param = nil
end

function Form_LoungeHeroChange:OnInactive()
  self.super.OnInactive(self)
end

function Form_LoungeHeroChange:RefreshUI()
  self.m_dataList = self:GenerateData()
  for i, v in ipairs(self.m_dataList) do
    if v.heroId == self.m_curHeroId then
      self.m_curChooseIndex = i
      break
    end
  end
  self.m_loungeChangeInfinityGrid:ShowItemList(self.m_dataList)
end

function Form_LoungeHeroChange:GenerateData()
  local list = {}
  local heroList = LoungeManager:GetHeroChangeList()
  for i, v in ipairs(heroList) do
    local tab = {
      heroId = v.m_ID,
      unlockLimitBreakLevel = v.m_UnlockLimitBreakLevel,
      name = v.m_mCharName
    }
    local heroData = HeroManager:GetHeroDataByID(v.m_ID)
    if heroData and heroData.serverData then
      local heroBreak = heroData.serverData.iBreak
      tab.isUnlock = heroBreak >= v.m_UnlockLimitBreakLevel and true or false
    else
      tab.isUnlock = false
    end
    if v.m_CharacterInfoID == self.m_curHeroId then
      tab.isChoose = true
    end
    list[#list + 1] = tab
  end
  table.sort(list, function(a, b)
    local unlock1 = a.isUnlock == true and 1 or 0
    local unlock2 = b.isUnlock == true and 1 or 0
    if unlock1 == unlock2 then
      return a.heroId < b.heroId
    else
      return unlock1 > unlock2
    end
  end)
  return list
end

function Form_LoungeHeroChange:OnItemClk(index)
  local itemIndex = index
  if itemIndex == self.m_curChooseIndex then
    return
  end
  local lastChooseIndex = self.m_curChooseIndex
  local lastShowItem = self.m_loungeChangeInfinityGrid:GetShowItemByIndex(lastChooseIndex)
  if lastShowItem then
    lastShowItem:ChangeChooseStatus(false)
  else
    self.m_dataList[lastChooseIndex].isChoose = false
  end
  self.m_curChooseIndex = itemIndex
  local curChooseItem = self.m_loungeChangeInfinityGrid:GetShowItemByIndex(self.m_curChooseIndex)
  if curChooseItem then
    curChooseItem:ChangeChooseStatus(true)
  else
    self.m_dataList[self.m_curChooseIndex].isChoose = true
  end
end

function Form_LoungeHeroChange:OnBtnconfirmClicked()
  self:OnBtnCloseClicked()
end

function Form_LoungeHeroChange:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_LoungeHeroChange:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_LoungeHeroChange", Form_LoungeHeroChange)
return Form_LoungeHeroChange
