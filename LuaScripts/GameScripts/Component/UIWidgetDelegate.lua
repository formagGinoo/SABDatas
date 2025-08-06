local BaseComponent = require("Component/BaseComponent")
local meta = class("UIWidgetDelegate", BaseComponent)

function meta:OnLoad()
  self.m_vWidgetList = {}
  self:bindFunction("createBackButton")
  self:bindFunction("createFilterButton")
  self:bindFunction("createItemIcon")
  self:bindFunction("createEquipIcon")
  self:bindFunction("createCommonItem")
  self:bindFunction("createNumStepper")
  self:bindFunction("createHeroIcon")
  self:bindFunction("removeWidget")
  self:bindFunction("createMonsterIcon")
  self:bindFunction("createResourceBar")
  self:bindFunction("createHeroTeamIcon")
  self:bindFunction("createLevelMaterialItem")
  self:bindFunction("createShopGoodsItem")
  self:bindFunction("createLegacySkillIcon")
  self:bindFunction("createTaskBar")
  self:bindFunction("createPlayerHead")
  self:bindFunction("createRogueItemIcon")
  self:bindFunction("createPackGiftPoint")
end

function meta:createBackButton(...)
  local prefab = require("UI/Widgets/BackButton").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createFilterButton(...)
  local prefab = require("UI/Widgets/FilterButton").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createItemIcon(...)
  local prefab = require("UI/Widgets/ItemIcon").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createEquipIcon(...)
  local prefab = require("UI/Widgets/EquipIcon").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createCommonItem(...)
  local prefab = require("UI/Widgets/CommonItem").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createNumStepper(...)
  local prefab = require("UI/Widgets/NumStepper").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createHeroIcon(...)
  local prefab = require("UI/Widgets/HeroIcon").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createMonsterIcon(...)
  local prefab = require("UI/Widgets/MonsterIcon").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createResourceBar(...)
  local prefab = require("UI/Widgets/ResourceBar").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createHeroTeamIcon(...)
  local prefab = require("UI/Widgets/HeroTeamIcon").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createLevelMaterialItem(...)
  local prefab = require("UI/Widgets/LevelMaterialItem").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createShopGoodsItem(...)
  local prefab = require("UI/Widgets/ShopGoodsItem").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createLegacySkillIcon(...)
  local prefab = require("UI/Widgets/LegacySkillIcon").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createTaskBar(...)
  local prefab = require("UI/Widgets/TaskBar").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createPlayerHead(...)
  local prefab = require("UI/Widgets/PlayerHead").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createRogueItemIcon(...)
  local prefab = require("UI/Widgets/RogueItemIcon").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:createPackGiftPoint(...)
  local prefab = require("UI/Widgets/PackGiftPoint").new(...)
  table.insert(self.m_vWidgetList, prefab)
  return prefab
end

function meta:doWidgetFunction(sFuncName, ...)
  for _, uiWidget in ipairs(self.m_vWidgetList) do
    if uiWidget[sFuncName] then
      uiWidget[sFuncName](uiWidget, ...)
    end
  end
end

function meta:OnUpdate(...)
  self:doWidgetFunction("OnUpdate", ...)
end

function meta:OnDestroy(...)
  self:doWidgetFunction("OnDestroy", ...)
  self.m_vWidgetList = {}
end

function meta:removeWidget(widget)
  for i, uiWidget in ipairs(self.m_vWidgetList) do
    if uiWidget == widget then
      table.remove(self.m_vWidgetList, i)
      break
    end
  end
end

return meta
