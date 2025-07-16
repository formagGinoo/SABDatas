local UIItemBase = require("UI/Common/UIItemBase")
local UIMonsterPreviewItem = class("UIMonsterPreviewItem", UIItemBase)
local Table_Unpack = table.unpack

function UIMonsterPreviewItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_monsterIcon = self:createMonsterIcon(self.m_common_monster_small)
  self.m_monsterIcon:SetClickCB(handler(self, self.OnMonsterClk))
end

function UIMonsterPreviewItem:OnFreshData()
  self:FreshChapterUI()
end

function UIMonsterPreviewItem:FreshChapterUI()
  if not self.m_monsterIcon then
    return
  end
  local monsterCfg = self.m_itemData.monsterCfg
  local isHide = self.m_itemData.isHide
  self.m_monsterIcon:SetMonsterData(monsterCfg, isHide)
  self:FreshChoose(self.m_itemData.isChoose or false)
end

function UIMonsterPreviewItem:SetChooseStatus(isChoose)
  self.m_itemData.isChoose = isChoose
  self:FreshChoose(isChoose)
end

function UIMonsterPreviewItem:FreshChoose(isChoose)
  UILuaHelper.SetActive(self.m_img_monster_select, isChoose)
end

function UIMonsterPreviewItem:OnMonsterClk(monsterID)
  if not self.m_itemIndex then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIMonsterPreviewItem
