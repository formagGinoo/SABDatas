local UIItemBase = require("UI/Common/UIItemBase")
local GoodsChapterLevelItemNew = class("GoodsChapterLevelItemNew", UIItemBase)

function GoodsChapterLevelItemNew:OnInit()
  self.c_item_advanced = self.m_itemTemplateCache:GameObject("c_item_advanced")
end

function GoodsChapterLevelItemNew:OnFreshData()
  self.freeConfig = self.m_itemData.freeDataCfg[1]
  self.PayConfig = self.m_itemData.payDataCfg[1]
  if not self.freeConfig or not self.PayConfig then
    return
  end
  self.c_item_advanced:SetActive(false)
  local data = self.m_itemData.server_data
  self.iStoreId = self.m_itemData.iStoreId
  self.freeGot = data and self.freeConfig.m_Level and data.mLevelInfo[self.freeConfig.m_Level] and true or false
  self.payGot = data and self.PayConfig.m_Level and data.mLevelInfo[self.PayConfig.m_Level] and true or false
  local freeReward_list = utils.changeCSArrayToLuaTable(self.freeConfig.m_FreeReward) or {}
  self.level_id = self.freeConfig.m_MainLevelID
  self.is_unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, self.level_id)
  self.is_Purchased = data and data.iBuyTime > 0 and true or false
  self.m_bg_light1:SetActive(not self.freeGot and self.is_unlock)
  self.m_bg_light2:SetActive(not self.payGot and self.is_unlock and self.is_Purchased)
  self.m_btnUp = self.m_btn_up:GetComponent("ButtonExtensions")
  if self.m_btnUp then
    function self.m_btnUp.Clicked()
      self:OnBtnBuyUp()
    end
  end
  self.m_btnDown = self.m_btn_down:GetComponent("ButtonExtensions")
  if self.m_btnDown then
    function self.m_btnDown.Clicked()
      self:OnBtnBuyDown()
    end
  end
  if freeReward_list and freeReward_list[1] then
    local childCount = self.m_item_pos01.transform.childCount
    if childCount <= 0 then
      local obj = GameObject.Instantiate(self.c_item_advanced, self.m_item_pos01.transform)
    end
    local widget = self.m_item_pos01.transform:GetChild(0).gameObject
    widget:SetActive(true)
    local freeReward = freeReward_list[1]
    local freeWidget = self:createCommonItem(widget)
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = freeReward[1],
      iNum = freeReward[2]
    }, {
      is_have_get = self.freeGot
    })
    freeWidget:SetItemInfo(processItemData)
    freeWidget:SetItemIconClickCB(handler(self, self.OnItemIconClickedFree))
    freeWidget:SetActive(true)
    self.m_txt_nml_Text.text = self.freeConfig.m_mLevelName
  end
  local payReward_list = utils.changeCSArrayToLuaTable(self.PayConfig.m_PayReward) or {}
  if payReward_list and payReward_list[1] then
    local childCount = self.m_item_pos02.transform.childCount
    if childCount <= 0 then
      local obj = GameObject.Instantiate(self.c_item_advanced, self.m_item_pos02.transform)
    end
    local widget = self.m_item_pos02.transform:GetChild(0).gameObject
    widget:SetActive(true)
    local payReward = payReward_list[1]
    local payWidget = self:createCommonItem(widget)
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = payReward[1],
      iNum = payReward[2]
    }, {
      is_have_get = self.payGot
    })
    payWidget:SetItemInfo(processItemData)
    payWidget:SetItemIconClickCB(handler(self, self.OnItemIconClickedPay))
    payWidget:SetActive(true)
    self.m_txt_nml_Text.text = self.PayConfig.m_mLevelName
  end
  self.m_mask_advanced:SetActive(not self.is_Purchased)
end

function GoodsChapterLevelItemNew:OnItemIconClickedFree(itemID, itemNum)
  if self.is_unlock and not self.freeGot then
    MallGoodsChapterManager:RqsGetBaseStoreChapterReward(self.iStoreId, self.freeConfig.m_GoodsID, self.freeConfig.m_Level, false)
  else
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end
end

function GoodsChapterLevelItemNew:OnItemIconClickedPay(itemID, itemNum)
  if self.is_unlock and not self.payGot and self.is_Purchased then
    MallGoodsChapterManager:RqsGetBaseStoreChapterReward(self.iStoreId, self.PayConfig.m_GoodsID, self.PayConfig.m_Level, false)
  else
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end
end

function GoodsChapterLevelItemNew:OnBtnBuyUp()
  if self.is_unlock and not self.freeGot then
    MallGoodsChapterManager:RqsGetBaseStoreChapterReward(self.iStoreId, self.freeConfig.m_GoodsID, self.freeConfig.m_Level, false)
  end
end

function GoodsChapterLevelItemNew:OnBtnBuyDown()
  if self.is_unlock and not self.payGot and self.is_Purchased then
    MallGoodsChapterManager:RqsGetBaseStoreChapterReward(self.iStoreId, self.PayConfig.m_GoodsID, self.PayConfig.m_Level, false)
  end
end

return GoodsChapterLevelItemNew
