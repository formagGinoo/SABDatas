local Form_ReferotherteamCopyTips = class("Form_ReferotherteamCopyTips", require("UI/UIFrames/Form_ReferotherteamCopyTipsUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum

function Form_ReferotherteamCopyTips:SetInitParam(param)
end

function Form_ReferotherteamCopyTips:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroWidgetList = {}
  self:InitHeroWidgets()
end

function Form_ReferotherteamCopyTips:InitHeroWidgets()
  for i = 1, FormPlotMaxNum do
    local heroIconRoot = self["m_common_hero_small_replace" .. i]
    if heroIconRoot then
      local heroWidget = self:createHeroIcon(heroIconRoot)
      if heroWidget then
        self.m_HeroWidgetList[#self.m_HeroWidgetList + 1] = heroWidget
        heroWidget:SetActive(false)
      end
    end
  end
end

function Form_ReferotherteamCopyTips:OnActive()
  self.super.OnActive(self)
  local teamData = self.m_csui.m_param.teamData
  local power = 0
  local heroDataList = teamData or {}
  for i = 1, FormPlotMaxNum do
    local serverData = heroDataList[i]
    local heroWidget = self.m_HeroWidgetList[i]
    if heroWidget then
      if serverData then
        heroWidget:SetActive(true)
        heroWidget:SetHeroData(serverData, nil, nil, true)
        power = power + serverData.iPower
      else
        heroWidget:SetActive(false)
      end
    end
  end
  self.m_txt_powermine_Text.text = tostring(power)
end

function Form_ReferotherteamCopyTips:OnInactive()
  self.super.OnInactive(self)
  local call_back = self.m_csui.m_param.call_back
  if call_back then
    call_back()
  end
end

function Form_ReferotherteamCopyTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ReferotherteamCopyTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ReferotherteamCopyTips", Form_ReferotherteamCopyTips)
return Form_ReferotherteamCopyTips
