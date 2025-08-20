local UIItemBase = require("UI/Common/UIItemBase")
local UIAct103SignItem = class("UIAct103SignItem", UIItemBase)

function UIAct103SignItem:OnInit()
  self.m_txt_day_Text = self.m_itemTemplateCache:TMPPro("c_txt_day")
  self.m_txt_day_MCC = self.m_itemTemplateCache:GameObject("c_txt_day"):GetComponent("MultiColorChange")
  self.m_z_txt_got_day = self.m_itemTemplateCache:GameObject("c_txt_got_day")
  if not utils.isNull(self.m_pnl_item_reward) then
    self.reward_parent_trans = self.m_pnl_item_reward.transform
  end
  self.reward_item_cache = {}
  table.insert(self.reward_item_cache, {
    common_item_go = self.m_itemTemplateCache:GameObject("c_reward1")
  })
  local m_PrefabHelper = self.m_pnl_item_reward:GetComponent("PrefabHelper")
  self.m_PrefabHelper = m_PrefabHelper
end

function UIAct103SignItem:OnInitRewardItem(go, index)
  index = index + 1
  local data = self.reward_array[index]
  go.transform.localScale = Vector3.one * 0.82
  local item = self.reward_item_cache[index]
  if not item then
    self.reward_item_cache[index] = {common_item_go = go}
    item = self.reward_item_cache[index]
  end
  local server_data = self.m_itemData.server_data
  local is_got = server_data.iAwardedMaxDays >= self.m_itemIndex
  local reward_item = self:createCommonItem(item.common_item_go)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = data[1],
    iNum = data[2]
  })
  reward_item:SetItemInfo(processData)
  reward_item:SetItemHaveGetActive(is_got)
  self.reward_item_cache[index].reward_item = reward_item
  reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
end

function UIAct103SignItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  local day_str = self.m_itemIndex > 9 and self.m_itemIndex or "0" .. self.m_itemIndex
  self.m_txt_day_Text.text = day_str
  local server_data = self.m_itemData.server_data
  local is_got = server_data.iAwardedMaxDays >= self.m_itemIndex
  local config = self.m_itemData.config
  self.reward_array = utils.changeCSArrayToLuaTable(config.m_Reward)
  if not utils.isNull(self.m_PrefabHelper) then
    self.m_PrefabHelper:RegisterCallback(handler(self, self.OnInitRewardItem))
    self.m_PrefabHelper:CheckAndCreateObjs(#self.reward_array)
  end
  if not utils.isNull(self.m_img_bg_normal) then
    self.m_img_bg_normal:SetActive(not is_got)
  end
  if not utils.isNull(self.m_img_bg_completed) then
    self.m_img_bg_completed:SetActive(is_got)
  end
  if not utils.isNull(self.m_img_line02) then
    self.m_img_line02:SetActive(is_got)
  end
  if not utils.isNull(self.m_btn_touch) then
    self.m_btn_touch:SetActive(not is_got and server_data.iLoginDays >= self.m_itemIndex)
  end
  local idx = (not (not (server_data.iLoginDays >= self.m_itemIndex) or is_got) or is_got) and 0 or 1
  if not utils.isNull(self.m_txt_day_MCC) then
    self.m_txt_day_MCC:SetColorByIndex(idx)
  end
  local is_next_day = server_data.iLoginDays + 1 <= self.m_itemIndex
  if not utils.isNull(self.m_z_txt_got_day) then
    self.m_z_txt_got_day:SetActive(is_next_day)
  end
  local red_go = self.m_img_bg_availablelight
  self:RegisterOrUpdateRedDotItem(red_go, RedDotDefine.ModuleType.HeroActSignItemCanRec, {
    self.m_itemIndex,
    server_data.iLoginDays,
    is_got
  })
end

function UIAct103SignItem:OnBtntouchClicked()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex, self.m_itemRootObj)
  end
end

function UIAct103SignItem:OnChooseItem(flag)
end

return UIAct103SignItem
