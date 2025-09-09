local Form_HeroCopyTips = class("Form_HeroCopyTips", require("UI/UIFrames/Form_HeroCopyTipsUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum

function Form_HeroCopyTips:SetInitParam(param)
end

function Form_HeroCopyTips:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroWidgetList = {}
  self:InitHeroWidgets()
end

function Form_HeroCopyTips:InitHeroWidgets()
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

function Form_HeroCopyTips:OnActive()
  self.super.OnActive(self)
  local teamData = self.m_csui.m_param.teamData
  local index = 0 .. (self.m_csui.m_param.teamIdx or 1)
  self.m_txt_team_num_Text.text = index
  local heroDataList = teamData or {}
  for i = 1, FormPlotMaxNum do
    local serverData = heroDataList[i]
    local heroWidget = self.m_HeroWidgetList[i]
    if heroWidget then
      if serverData then
        heroWidget:SetActive(true)
        heroWidget:SetHeroData(serverData, nil, nil, true)
      else
        heroWidget:SetActive(false)
      end
    end
  end
end

function Form_HeroCopyTips:OnInactive()
  self.super.OnInactive(self)
  local call_back = self.m_csui.m_param.call_back
  if call_back then
    call_back()
  end
end

function Form_HeroCopyTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroCopyTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroCopyTips", Form_HeroCopyTips)
return Form_HeroCopyTips
