local UIItemBase = require("UI/Common/UIItemBase")
local ActTaskTabItem = class("ActTaskTabItem", UIItemBase)

function ActTaskTabItem:OnInit()
  local button = self.m_itemRootObj:GetComponent("Button")
  button.onClick:RemoveAllListeners()
  button.onClick:AddListener(handler(self, self.OnItemClicked))
  self.c_tab_img_red_line = self.m_itemTemplateCache:GameObject("c_tab_img_red_line")
  self.c_tab_txt_day_unselect = self.m_itemTemplateCache:GameObject("c_tab_txt_day_unselect")
  self.c_tab_img_lock = self.m_itemTemplateCache:GameObject("c_tab_img_lock")
  self.c_tab_img_red = self.m_itemTemplateCache:GameObject("c_tab_img_red")
  self.c_tab_img_fin = self.m_itemTemplateCache:GameObject("c_tab_img_fin")
  self.c_tab_txt_day_Text = self.m_itemTemplateCache:TMPPro("c_tab_txt_day")
  self.c_tab_txt_day_unselect_Text = self.m_itemTemplateCache:TMPPro("c_tab_txt_day_unselect")
  self.c_txt_lock_day_Text = self.m_itemTemplateCache:TMPPro("c_txt_lock_day")
  self.c_txt_finish_day_Text = self.m_itemTemplateCache:TMPPro("c_txt_finish_day")
  self.c_tab_txt_day_select_Text = self.m_itemTemplateCache:TMPPro("c_tab_txt_day_select")
  self.c_tab_txt_day_select = self.m_itemTemplateCache:GameObject("c_tab_txt_day_select")
end

function ActTaskTabItem:OnFreshData()
  local data = self.m_itemData
  self.c_tab_txt_day_Text.text = self.m_itemIndex
  self.c_txt_lock_day_Text.text = self.m_itemIndex
  self.c_txt_finish_day_Text.text = self.m_itemIndex
  self.c_tab_txt_day_unselect_Text.text = self.m_itemIndex
  self.c_tab_txt_day_select_Text.text = self.m_itemIndex
  self.c_tab_img_red_line:SetActive(data.bIsSelect)
  self.c_tab_txt_day_select:SetActive(data.bIsSelect)
  self.c_tab_txt_day_unselect:SetActive(not data.bIsSelect and data.bUnlock and data.bState ~= MTTDProto.QuestState_Over)
  self.c_tab_img_lock:SetActive(not data.bUnlock)
  self.c_tab_img_fin:SetActive(not data.bIsSelect and data.bState == MTTDProto.QuestState_Over)
  if data.bIsSelect then
    UILuaHelper.PlayAnimationByName(self.c_tab_img_red_line, "img_red_line_in")
  end
  self.c_tab_img_red:SetActive(data.bShowRed)
end

function ActTaskTabItem:OnItemClicked()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex)
  end
end

return ActTaskTabItem
