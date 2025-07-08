local UIItemBase = require("UI/Common/UIItemBase")
local LetterListItem = class("LetterListItem", UIItemBase)

function LetterListItem:OnInit()
  self.c_btnClick = self.m_itemRootObj:GetComponent("ButtonExtensions")
  self.c_btnClick.Clicked = handler(self, self.OnHeroItemClick)
end

function LetterListItem:OnFreshData()
  local letterData = self.m_itemData.letter
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_btn_select:SetActive(self.m_itemData.bIsLetterSelected)
  local cfg = AttractManager:GetAttractArchiveCfgByHeroIDAndArchiveID(self.m_itemData.heroId, letterData.iArchiveId)
  self.m_letterName_Text.text = cfg.m_mLetterName
  self.m_letterName_done_Text.text = cfg.m_mLetterName
  self.m_itemRootObj.transform.localRotation = Vector3.zero
end

function LetterListItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(189)
end

return LetterListItem
