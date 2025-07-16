local Form_PopupBond = class("Form_PopupBond", require("UI/UIFrames/Form_PopupBondUI"))
local MaxBondEffectNum = 3
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function Form_PopupBond:SetInitParam(param)
end

function Form_PopupBond:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroBondItemClk)
  }
  self.m_luaHeroBondListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollview_bebound_InfinityGrid, "HeroBond/UIHeroBondPopItem", initGridData)
  self.m_curShowBondList = {}
  local initHeroGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClk)
  }
  self.m_luaHeroListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollview_avatar_InfinityGrid, "HeroBond/UIPopUpBondHeroItem", initHeroGridData)
  self.m_showHeroDataList = {}
end

function Form_PopupBond:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  if self.m_csui.m_param and self.m_csui.m_param.battleShow then
    CS.UI.UILuaHelper.SetPauseExcept(true)
  end
end

function Form_PopupBond:OnInactive()
  if self.m_csui.m_param and self.m_csui.m_param.battleShow then
    CS.UI.UILuaHelper.SetPauseExcept(false)
  end
  self.super.OnInactive(self)
end

function Form_PopupBond:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PopupBond:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  if tParam.battleShow then
    self.m_isShowAllBond = false
    local heroIDList = tParam.formationHeroIDList
    local heroDataList = self:GetHeroDataList(heroIDList)
    local bondList = HeroManager:GetHeroBond():GetBondsByHeroList(heroDataList)
    local activeBondIDs = {}
    for bondId, stage in pairs(tParam.activeBonds) do
      activeBondIDs[bondId] = stage
    end
    self.m_curShowBondList = {}
    for m = 1, #bondList do
      if activeBondIDs[bondList[m].bondID] then
        bondList[m].bondActiveStage = activeBondIDs[bondList[m].bondID]
        table.insert(self.m_curShowBondList, bondList[m])
      end
    end
    local formationHeroIDs = {}
    for i, heroID in pairs(tParam.formationHeroIDList) do
      formationHeroIDs[heroID] = heroID
    end
    self.m_heroDataList = {}
    for m = 1, #heroDataList do
      if formationHeroIDs[m] then
        table.insert(self.m_heroDataList, heroDataList[m])
      end
    end
  else
    self.m_isShowAllBond = tParam.isShowAllBond
    if self.m_isShowAllBond == true then
      self.m_curShowBondList = HeroManager:GetHeroBond():GetAllBondList(self.m_isShowAllBond)
    else
      local heroIDList = tParam.heroIDList
      self.m_heroDataList = self:GetHeroDataList(heroIDList)
      self.m_curShowBondList = HeroManager:GetHeroBond():GetBondsByHeroList(self.m_heroDataList)
    end
  end
  local bondID = tParam.chooseBondID
  self.m_curChooseBondIndex = self:GetBondIndexByID(bondID)
  self.m_curShowBondList[self.m_curChooseBondIndex].isChoose = true
end

function Form_PopupBond:GetHeroDataList(heroIDList)
  if not heroIDList then
    return {}
  end
  local heroDataList = {}
  for i, heroID in pairs(heroIDList) do
    local heroData = HeroManager:GetHeroDataByID(heroID)
    if heroData == nil then
      local characterCfg = ConfigManager:GetConfigInsByName("CharacterInfo"):GetValue_ByHeroID(heroID)
      if not characterCfg:GetError() then
        heroData = {
          serverData = {iHeroId = heroID},
          characterCfg = characterCfg
        }
      end
    end
    if heroData then
      heroDataList[#heroDataList + 1] = heroData
    else
    end
  end
  return heroDataList
end

function Form_PopupBond:GetBondIndexByID(bondID)
  for i, bondData in ipairs(self.m_curShowBondList) do
    if bondData.bondID == bondID then
      return i
    end
  end
end

function Form_PopupBond:GetHeroCfgListByIDList(heroIDList)
  if not heroIDList then
    return
  end
  local heroCfgList = {}
  for i, heroID in ipairs(heroIDList) do
    local heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroID)
    if not heroCfg:GetError() then
      heroCfgList[#heroCfgList + 1] = heroCfg
    end
  end
  return heroCfgList
end

function Form_PopupBond:IsHeroActive(heroID)
  if not heroID then
    return
  end
  if not self.m_heroDataList then
    return
  end
  for _, tempHeroData in ipairs(self.m_heroDataList) do
    if tempHeroData.serverData.iHeroId == heroID then
      return true
    end
  end
  return false
end

function Form_PopupBond:IsHeroHave(heroID)
  if not heroID then
    return
  end
  local heroData = HeroManager:GetHeroDataByID(heroID)
  if heroData then
    return true
  end
  return false
end

function Form_PopupBond:FreshUI()
  self.m_luaHeroBondListInfinityGrid:ShowItemList(self.m_curShowBondList)
  self.m_luaHeroBondListInfinityGrid:LocateTo(self.m_curChooseBondIndex - 1)
  self:FreshBondContent()
end

function Form_PopupBond:FreshBondContent()
  if not self.m_curChooseBondIndex then
    return
  end
  local bondData = self.m_curShowBondList[self.m_curChooseBondIndex]
  if not bondData then
    return
  end
  self.m_txt_bebound_explain_Text.text = bondData.bondCfg.m_mDesc
  self:FreshBondEffect(bondData)
  self:FreshBondHeroList(bondData)
end

function Form_PopupBond:FreshBondEffect(bondData)
  local bondIconStr = bondData.bondCfg.m_Icon
  local bondEffectCfgList = bondData.bondEffectCfgList
  local bondActiveStage = bondData.bondActiveStage
  for i = 1, MaxBondEffectNum do
    local bondEffectCfg = bondEffectCfgList[i]
    if bondEffectCfg then
      UILuaHelper.SetActive(self["m_bond_effect" .. i], true)
      UILuaHelper.SetAtlasSprite(self[string.format("m_img_icon_bg%d_Image", i)], HeroManager.BondStageBgPath[i].bgPath)
      UILuaHelper.SetAtlasSprite(self[string.format("m_icon_bond%d_Image", i)], bondIconStr .. "_1")
      self[string.format("m_num_item%d_Text", i)].text = bondEffectCfg.m_RequiredCount
      self[string.format("m_txt_bebound_explain%d_Text", i)].text = bondEffectCfg.m_mDesc
      if self.m_isShowAllBond then
        UILuaHelper.SetCanvasGroupAlpha(self["m_bond_effect" .. i], 1)
      elseif i == bondActiveStage then
        UILuaHelper.SetCanvasGroupAlpha(self["m_bond_effect" .. i], 1)
      else
        UILuaHelper.SetCanvasGroupAlpha(self["m_bond_effect" .. i], 0.6)
      end
    else
      UILuaHelper.SetActive(self["m_bond_effect" .. i], false)
    end
  end
end

function Form_PopupBond:FreshBondHeroList(bondData)
  local bondID = bondData.bondID
  local bondHeroIDList = HeroManager:GetHeroBond():GetHeroIDListByBondID(bondID)
  local heroCfgList = self:GetHeroCfgListByIDList(bondHeroIDList)
  local showBondHeroList = {}
  for i, heroCfg in ipairs(heroCfgList) do
    local heroID = heroCfg.m_HeroID
    local isHeroActive = self:IsHeroActive(heroID)
    local isHeroHave = self:IsHeroHave(heroID)
    local bondHeroData = {
      heroCfg = heroCfg,
      isActive = isHeroActive,
      isHave = isHeroHave,
      isShowAllBond = self.m_isShowAllBond
    }
    showBondHeroList[#showBondHeroList + 1] = bondHeroData
  end
  self.m_showHeroDataList = showBondHeroList
  table.sort(self.m_showHeroDataList, function(a, b)
    if a.isActive ~= b.isActive then
      return a.isActive
    end
    if a.isHave ~= b.isHave then
      return a.isHave
    end
    return a.heroCfg.m_HeroID > b.heroCfg.m_HeroID
  end)
  self.m_luaHeroListInfinityGrid:ShowItemList(self.m_showHeroDataList)
  if #self.m_showHeroDataList > 0 then
    self.m_luaHeroListInfinityGrid:LocateTo(0)
  end
end

function Form_PopupBond:OnHeroBondItemClk(itemIndex)
  if not itemIndex then
    return
  end
  local lastChooseIndex = self.m_curChooseBondIndex
  if lastChooseIndex ~= nil then
    local lastChooseItem = self.m_luaHeroBondListInfinityGrid:GetShowItemByIndex(lastChooseIndex)
    if lastChooseItem then
      lastChooseItem:FreshChoose(false)
    elseif self.m_curShowBondList[lastChooseIndex] then
      self.m_curShowBondList[lastChooseIndex].isChoose = false
    end
  end
  local curChooseItem = self.m_luaHeroBondListInfinityGrid:GetShowItemByIndex(itemIndex)
  if curChooseItem then
    curChooseItem:FreshChoose(true)
  end
  self.m_curChooseBondIndex = itemIndex
  self:FreshBondContent()
end

function Form_PopupBond:OnHeroItemClk(itemIndex)
  if not itemIndex then
    return
  end
  if not self.m_showHeroDataList then
    return
  end
  local bondHeroData = self.m_showHeroDataList[itemIndex]
  if not bondHeroData then
    return
  end
  local heroID = bondHeroData.heroCfg.m_HeroID
  StackPopup:Push(UIDefines.ID_FORM_POPUPHERO_TIPS, {heroID = heroID})
end

function Form_PopupBond:OnBtnemptyClicked()
  self:CloseForm()
end

function Form_PopupBond:OnBtnreturnClicked()
  self:CloseForm()
end

function Form_PopupBond:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PopupBond", Form_PopupBond)
return Form_PopupBond
