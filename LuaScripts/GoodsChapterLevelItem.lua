local UIItemBase = require("UI/Common/UIItemBase")
local GoodsChapterLevelItem = class("GoodsChapterLevelItem", UIItemBase)

function GoodsChapterLevelItem:OnInit()
end

function GoodsChapterLevelItem:OnFreshData()
  local config = self.m_itemData.config
  local data = self.m_itemData.server_data
  self.iStoreId = self.m_itemData.iStoreId
  self.is_Purchased = data and data.iBuyTime > 0 and true or false
  local reward_list = utils.changeCSArrayToLuaTable(config.m_PayReward) or {}
  local reward = reward_list[1]
  UILuaHelper.SetAtlasSprite(self.m_icon_gift_Image, ItemManager:GetItemIconPathByID(reward[1]))
  self.reward = reward
  self.m_txt_chapter_Text.text = config.m_mLevelName
  self.m_txt_num_Text.text = "X" .. reward[2]
  local level_id = config.m_MainLevelID
  local is_unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, level_id)
  local is_got = data and data.mLevelInfo[config.m_Level] and true or false
  self.m_btn_collection:SetActive(is_unlock and not is_got)
  self.m_mask_lock:SetActive(not is_unlock)
  self.m_icon_received:SetActive(is_got)
end

function GoodsChapterLevelItem:OnIcongiftClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({
    iID = self.reward[1],
    iNum = self.reward[2]
  })
end

function GoodsChapterLevelItem:OnBtncollectionClicked()
  if self.is_Purchased then
    MallGoodsChapterManager:RqsGetBaseStoreChapterReward(self.iStoreId, self.m_itemData.config.m_GoodsID, self.m_itemData.config.m_Level, false)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(40042))
  end
end

return GoodsChapterLevelItem
