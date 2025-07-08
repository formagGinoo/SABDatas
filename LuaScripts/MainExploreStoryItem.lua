local UIItemBase = require("UI/Common/UIItemBase")
local MainExploreStoryItem = class("MainExploreStoryItem", UIItemBase)

function MainExploreStoryItem:OnInit()
  local button = self.m_itemRootObj:GetComponent("Button")
  button.onClick:RemoveAllListeners()
  button.onClick:AddListener(handler(self, self.OnItemClicked))
end

function MainExploreStoryItem:OnFreshData()
  local config = self.m_itemData[1]
  self.m_txt_infor_Text.text = config.m_mStoryTitle
  local reward = utils.changeCSArrayToLuaTable(config.m_icon)
  UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, ItemManager:GetItemIconPathByID(reward[1]))
  local unlock_count = MainExploreManager:GetUnlockStorySubCount(config.m_StoryID)
  self.m_txt_infornum_Text.text = unlock_count .. "/" .. #self.m_itemData
  self.m_pnl_obtain:SetActive(unlock_count >= #self.m_itemData)
  self.m_img_light:SetActive(unlock_count < #self.m_itemData)
  self:RegisterOrUpdateRedDotItem(self.m_img_buyitem_reddot, RedDotDefine.ModuleType.MainExploreStoryItem, {
    m_StoryID = config.m_StoryID,
    max_count = #self.m_itemData
  })
end

function MainExploreStoryItem:OnItemClicked()
  StackPopup:Push(UIDefines.ID_FORM_MAINEXPLOREREMENBER, {
    configs = self.m_itemData
  })
end

return MainExploreStoryItem
