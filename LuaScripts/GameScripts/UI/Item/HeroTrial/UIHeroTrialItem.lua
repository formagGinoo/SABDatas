local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroTrialItem = class("UIHeroTrialItem", UIItemBase)

function UIHeroTrialItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
    UILuaHelper.BindButtonClickManual(self.m_itemRootObj.transform:GetComponent(T_Button), function()
      self.m_itemClkBackFun(self.m_itemIndex)
    end)
  end
end

function UIHeroTrialItem:OnFreshData()
  UILuaHelper.SetActive(self.m_icon_up, false)
  UILuaHelper.SetActive(self.m_hourglass, self.m_itemData.iShowHourglass)
  UILuaHelper.SetActive(self.m_card_reward, not self.m_itemData.isFinish)
  UILuaHelper.SetActive(self.m_select, self.m_itemData.selectIndex == self.m_itemIndex)
  UILuaHelper.SetActive(self.m_card_checkmark, self.m_itemData.isFinish)
  UILuaHelper.SetActive(self.m_card_redpoint, self.m_itemData.iShowRed)
  UILuaHelper.SetAtlasSprite(self.m_img_head_Image, self.m_itemData.headPath)
end

return UIHeroTrialItem
