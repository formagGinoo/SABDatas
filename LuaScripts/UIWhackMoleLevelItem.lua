local UIItemBase = require("UI/Common/UIItemBase")
local UIWhackMoleLevelItem = class("UIWhackMoleLevelItem", UIItemBase)

function UIWhackMoleLevelItem:OnInit()
end

function UIWhackMoleLevelItem:OnFreshData()
  if self.m_itemData.levelCfg then
    self.m_txt_level_Text.text = tostring(self.m_itemData.levelCfg.m_mName)
  end
  UILuaHelper.SetActive(self.m_levelState_Pass, self.m_itemData.levelState == 0)
  UILuaHelper.SetActive(self.m_levelState_Normal, self.m_itemData.levelState == 1)
  UILuaHelper.SetActive(self.m_levelState_Lock, self.m_itemData.levelState == 2)
end

function UIWhackMoleLevelItem:OnBtnlevelSelectClicked()
  if self.m_itemData.levelState == 2 then
  end
  if self.m_itemData.levelState == 0 then
  end
  if self.m_itemData.levelState == 1 then
    StackFlow:Push(UIDefines.ID_FORM_WHACKMOLEBATTLEMAIN, {
      iLevelID = self.m_itemData.levelCfg.m_LevelID,
      iSubActId = self.m_itemData.levelCfg.m_SubActID,
      iActId = 1030
    })
    StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_WHACKMOLELEVELSELECT)
  end
end

return UIWhackMoleLevelItem
