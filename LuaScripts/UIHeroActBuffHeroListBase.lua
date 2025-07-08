local UIHeroActBuffHeroListBase = class("UIHeroActBuffHeroListBase", require("UI/Common/UIBase"))

function UIHeroActBuffHeroListBase:AfterInit()
  UIHeroActBuffHeroListBase.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_heroListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_hero_list_InfinityGrid, "HeroActivity/UIActBuffHeroItem", initGridData)
  self.m_heroListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnItemClk))
end

function UIHeroActBuffHeroListBase:OnActive()
  UIHeroActBuffHeroListBase.super.OnActive(self)
  self.group_id = self.m_csui.m_param.activityID
  self:FreshUI()
end

function UIHeroActBuffHeroListBase:OnInactive()
  UIHeroActBuffHeroListBase.super.OnInactive(self)
end

function UIHeroActBuffHeroListBase:FreshUI()
  local all_config = HeroActivityManager:GetActActLamiaBonusChaCfgsByGroup(self.group_id)
  local hero_list = {}
  for i, v in ipairs(all_config) do
    local id = v.m_Character
    local hero_data = HeroManager:GetHeroDataByConfigID(id)
    if not hero_data then
      hero_data = {
        serverData = {iHeroId = id, iLevel = 1}
      }
      hero_data.is_owned = false
    else
      hero_data.is_owned = true
    end
    hero_data.bonus_config = v
    hero_list[i] = hero_data
  end
  self.m_heroListInfinityGrid:ShowItemList(hero_list)
end

function UIHeroActBuffHeroListBase:OnItemClk(index, go)
end

function UIHeroActBuffHeroListBase:OnBtnCloseClicked()
  self:CloseForm()
end

function UIHeroActBuffHeroListBase:OnBtnReturnClicked()
  self:CloseForm()
end

function UIHeroActBuffHeroListBase:OnDestroy()
  UIHeroActBuffHeroListBase.super.OnDestroy(self)
end

function UIHeroActBuffHeroListBase:IsOpenGuassianBlur()
  return true
end

return UIHeroActBuffHeroListBase
