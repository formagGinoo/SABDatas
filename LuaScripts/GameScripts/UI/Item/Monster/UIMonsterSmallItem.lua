local UIItemBase = require("UI/Common/UIItemBase")
local UIMonsterSmallItem = class("UIMonsterSmallItem", UIItemBase)
local Table_Unpack = table.unpack

function UIMonsterSmallItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_monsterIcon = self:createMonsterIcon(self.m_itemRootObj)
  self.m_monsterIcon:SetClickCB(handler(self, self.OnMonsterClk))
end

function UIMonsterSmallItem:OnFreshData()
  self:FreshChapterUI()
end

function UIMonsterSmallItem:FreshChapterUI()
  if not self.m_monsterIcon then
    return
  end
  local monsterCfg = self.m_itemData.monsterCfg
  local isHide = self.m_itemData.isHide
  self.m_monsterIcon:SetMonsterData(monsterCfg, isHide)
end

function UIMonsterSmallItem:OnMonsterClk(monsterIcon)
  if not monsterIcon then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(monsterIcon)
  end
end

return UIMonsterSmallItem
