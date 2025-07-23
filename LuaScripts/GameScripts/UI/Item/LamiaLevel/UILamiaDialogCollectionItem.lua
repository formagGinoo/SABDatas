local UIItemBase = require("UI/Common/UIItemBase")
local UILamiaDialogCollectionItem = class("UILamiaDialogCollectionItem", UIItemBase)

function UILamiaDialogCollectionItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_levelCfg = nil
  if not utils.isNull(self.m_btn_story_item) then
    local btn = self.m_btn_story_item:GetComponent("ButtonExtensions")
    if not utils.isNull(btn) then
      btn.Clicked = handler(self, self.OnBtnstoryitemClicked)
    end
  end
end

function UILamiaDialogCollectionItem:OnFreshData()
  self.m_levelCfg = self.m_itemData
  self.m_txt_num_Text.text = self.m_levelCfg.m_LevelRef
  self.m_txt_title_Text.text = self.m_levelCfg.m_mLevelName
  local posRoot = self.m_itemIndex % 2 == 0 and self.m_right_pos or self.m_left_pos
  UILuaHelper.SetParent(self.m_item_root, posRoot, true)
end

function UILamiaDialogCollectionItem:OnBtnstoryitemClicked()
  if not self.m_itemData then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UILamiaDialogCollectionItem
