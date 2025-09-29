local Form_InheritLevelQuickUpResult = class("Form_InheritLevelQuickUpResult", require("UI/UIFrames/Form_InheritLevelQuickUpResultUI"))

function Form_InheritLevelQuickUpResult:SetInitParam(param)
end

function Form_InheritLevelQuickUpResult:AfterInit()
  self.super.AfterInit(self)
  self.m_RolesListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_role_list_InfinityGrid, "Inherit/UILevelUpOverItem")
end

function Form_InheritLevelQuickUpResult:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
end

function Form_InheritLevelQuickUpResult:OnInactive()
  self.super.OnInactive(self)
end

function Form_InheritLevelQuickUpResult:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_InheritLevelQuickUpResult:RefreshUI()
  local param = self.m_csui.m_param
  self.m_heroIDList = {}
  local beforeLevel = 200
  local afterLevel = 200
  local mHeroIdLevelChange = param.vHeroIdLevelChange
  log.info("param.vHeroIdLevelChange: " .. table.serialize(mHeroIdLevelChange))
  for i = 1, #mHeroIdLevelChange do
    local v = mHeroIdLevelChange[i]
    table.insert(self.m_heroIDList, {
      heroData = HeroManager:GetHeroDataByID(v.iHeroId),
      iLevel = v.iNewLevel
    })
    beforeLevel = math.min(beforeLevel, v.iOldLevel)
    afterLevel = math.min(afterLevel, v.iNewLevel)
  end
  table.sort(self.m_heroIDList, function(a, b)
    if a.iNewLevel == b.iNewLevel then
      return HeroManager:GetHeroiPower(a.heroData.serverData.iHeroId) > HeroManager:GetHeroiPower(b.heroData.serverData.iHeroId)
    else
      return a.iNewLevel > b.iNewLevel
    end
  end)
  self.m_iAfterLevel = afterLevel
  self.m_iBeforeLevel = beforeLevel
  self.m_txt_lv_before_Text.text = ConfigManager:GetCommonTextById(20386) .. self.m_iBeforeLevel
  self.m_txt_lv_after_Text.text = ConfigManager:GetCommonTextById(20386) .. self.m_iAfterLevel
  self.m_RolesListInfinityGrid:ShowItemList(self.m_heroIDList)
end

local fullscreen = true
ActiveLuaUI("Form_InheritLevelQuickUpResult", Form_InheritLevelQuickUpResult)
return Form_InheritLevelQuickUpResult
