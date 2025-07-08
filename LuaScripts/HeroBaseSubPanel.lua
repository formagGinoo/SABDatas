local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroBaseSubPanel = class("HeroBaseSubPanel", UISubPanelBase)
local DefaultChooseTab = 1

function HeroBaseSubPanel:OnInit()
  self.m_curChooseTab = nil
  self.m_subPanelData = {
    [HeroManager.HeroBaseTab.BaseInfo] = {
      panelRoot = self.m_hero_base_info_root,
      subPanelName = "HeroBaseInfoSubPanel",
      subPanelLua = nil,
      backFun = function(changeType)
        self:OnBaseClkBack(changeType)
      end
    }
  }
  self.m_curShowHeroData = nil
  self.m_allHeroList = nil
  self.m_curChooseHeroIndex = nil
  self.m_isShowOutAnim = false
  self:AddEventListeners()
  self.m_openTime = 0
end

function HeroBaseSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_ResetLevel", handler(self, self.OnHeroResetLevel))
end

function HeroBaseSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HeroBaseSubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.heroData
  self.m_allHeroList = self.m_panelData.allHeroList
  self.m_curChooseHeroIndex = self.m_panelData.chooseIndex
  local curChooseTab = self.m_panelData.chooseTab or DefaultChooseTab
  if self.m_panelData.isJustFreshData == true then
    curChooseTab = self.m_curChooseTab or DefaultChooseTab
  end
  self:FreshChangeHeroTab(curChooseTab)
end

function HeroBaseSubPanel:OnActivePanel()
  self.m_openTime = TimeUtil:GetServerTimeS()
  ReportManager:ReportSystemOpen(GlobalConfig.SYSTEM_ID.CharacterLevel, self.m_openTime)
end

function HeroBaseSubPanel:OnHidePanel()
  ReportManager:ReportSystemClose(GlobalConfig.SYSTEM_ID.CharacterLevel, self.m_openTime)
end

function HeroBaseSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  for _, subPanelData in ipairs(self.m_subPanelData) do
    if subPanelData.subPanelLua then
      subPanelData.subPanelLua:dispose()
      subPanelData.subPanelLua = nil
    end
  end
  HeroBaseSubPanel.super.OnDestroy(self)
end

function HeroBaseSubPanel:ShowPanelOutAnim(index, backFun)
  if not index then
    return
  end
  local heroTab = self.m_subPanelData[index]
  if not heroTab then
    return
  end
  local subPanelLua = heroTab.subPanelLua
  if not subPanelLua then
    return
  end
  if subPanelLua.ShowOutAnim then
    subPanelLua:ShowOutAnim(backFun)
  else
    backFun()
  end
end

function HeroBaseSubPanel:FreshChangeHeroTab(index)
  local lastHeroTab = self.m_curChooseTab
  if lastHeroTab then
    local lastSubPanelData = self.m_subPanelData[lastHeroTab]
    if lastSubPanelData.subPanelLua then
      lastSubPanelData.subPanelLua:SetActive(false)
    end
  end
  if index then
    self.m_curChooseTab = index
    local curSubPanelData = self.m_subPanelData[index]
    if curSubPanelData then
      if curSubPanelData.subPanelLua == nil then
        local initData = curSubPanelData.backFun and {
          backFun = curSubPanelData.backFun
        } or nil
        self:CreateSubPanel(curSubPanelData.subPanelName, curSubPanelData.panelRoot, self, initData, {
          heroData = self.m_curShowHeroData,
          allHeroList = self.m_allHeroList,
          chooseIndex = self.m_curChooseHeroIndex,
          initData = initData
        }, function(subPanelLua)
          if subPanelLua then
            curSubPanelData.subPanelLua = subPanelLua
            if curSubPanelData.isNeedShowEnterAnim and subPanelLua.ShowEnterInAnim then
              subPanelLua:ShowEnterInAnim()
              curSubPanelData.isNeedShowEnterAnim = false
            end
            if curSubPanelData.isNeedShowTabAnim and subPanelLua.ShowTabInAnim then
              subPanelLua:ShowTabInAnim()
              curSubPanelData.isNeedShowTabAnim = false
            end
          end
        end)
      else
        self:FreshCurTabSubPanelInfo()
      end
    end
  end
end

function HeroBaseSubPanel:FreshCurTabSubPanelInfo()
  if not self.m_curChooseTab then
    return
  end
  if not self.m_curShowHeroData then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  local subPanelLua = curSubPanelData.subPanelLua
  if subPanelLua then
    subPanelLua:SetActive(true)
    subPanelLua:FreshData({
      heroData = self.m_curShowHeroData,
      allHeroList = self.m_allHeroList,
      chooseIndex = self.m_curChooseHeroIndex
    })
  end
end

function HeroBaseSubPanel:ShowEnterInAnim()
  if not self.m_curChooseTab then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local subPanelLua = curSubPanelData.subPanelLua
    if subPanelLua then
      if subPanelLua.ShowEnterInAnim then
        subPanelLua:ShowEnterInAnim()
      end
    else
      curSubPanelData.isNeedShowEnterAnim = true
    end
  end
end

function HeroBaseSubPanel:ShowTabInAnim()
  if not self.m_curChooseTab then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local subPanelLua = curSubPanelData.subPanelLua
    if subPanelLua then
      if subPanelLua.ShowTabInAnim then
        subPanelLua:ShowTabInAnim()
      end
    else
      curSubPanelData.isNeedShowTabAnim = true
    end
  end
end

function HeroBaseSubPanel:OnBaseClkBack(heroBaseTabType)
  self:ShowPanelOutAnim(self.m_curChooseTab, function()
    self:FreshChangeHeroTab(heroBaseTabType)
    self:ShowTabInAnim()
  end)
end

function HeroBaseSubPanel:OnHeroResetLevel()
  self:FreshChangeHeroTab(HeroManager.HeroBaseTab.BaseInfo)
end

function HeroBaseSubPanel:GetDownloadResourceExtra()
  local vSubPanelName = {
    "HeroBaseInfoSubPanel",
    "HeroBreakSubPanel"
  }
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(vSubPanelName) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
    if vPackageSub ~= nil then
      for i = 1, #vPackageSub do
        vPackage[#vPackage + 1] = vPackageSub[i]
      end
    end
    if vResourceExtraSub ~= nil then
      for i = 1, #vResourceExtraSub do
        vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
      end
    end
  end
  return vPackage, vResourceExtra
end

return HeroBaseSubPanel
