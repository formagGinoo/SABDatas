local UIItemBase = require("UI/Common/UIItemBase")
local UIActSignItem = class("UIActSignItem", UIItemBase)
local ColorEnum = {
  yellow = Color(1.0, 0.9372549019607843, 0.803921568627451)
}
local FrameHeightEnum = {
  NormalOne = Vector2.New(132, 133),
  NormalTwo = Vector2.New(132, 244),
  SpecialOne = Vector2.New(195, 189),
  SpecialTwo = Vector2.New(195, 310)
}
local FrameHeightEnum2 = {
  NormalOne = Vector2.New(132, 133),
  NormalTwo = Vector2.New(132, 244)
}

function UIActSignItem:OnInit()
  self.m_txt_day_Text = self.m_itemTemplateCache:TMPPro("c_txt_day1")
  self.m_txt_day_MCC = self.m_itemTemplateCache:GameObject("c_txt_day1"):GetComponent("MultiColorChange")
  local day_str = self.m_itemIndex > 9 and self.m_itemIndex or "0" .. self.m_itemIndex
  self.m_txt_day_Text.text = day_str
  self.m_next_get = self.m_itemTemplateCache:GameObject("c_img_got_day_tag")
  self.reward_parent_trans = self.m_pnl_item_reward.transform
  self.reward_item_cache = {}
  table.insert(self.reward_item_cache, {
    common_item_go = self.m_itemTemplateCache:GameObject("c_reward1"),
    is_got_go = self.m_itemTemplateCache:GameObject("c_img_got")
  })
  local m_PrefabHelper = self.m_pnl_item_reward:GetComponent("PrefabHelper")
  local config = self.m_itemData.config
  self.reward_array = utils.changeCSArrayToLuaTable(config.m_Reward)
  m_PrefabHelper:RegisterCallback(handler(self, self.OnInitRewardItem))
  m_PrefabHelper:CheckAndCreateObjs(#self.reward_array)
  local m_img_bg_normal = self.m_itemTemplateCache:GameObject("c_img_bg_normal")
  local m_img_bg_special = self.m_itemTemplateCache:GameObject("c_img_bg_special")
  m_img_bg_normal:SetActive(config.m_UIType == 0)
  m_img_bg_special:SetActive(config.m_UIType == 1)
  if self.m_img_bk_finish then
    m_img_bg_normal:GetComponent("RectTransform").sizeDelta = #self.reward_array == 1 and FrameHeightEnum2.NormalOne or FrameHeightEnum2.NormalTwo
  else
    m_img_bg_normal:GetComponent("RectTransform").sizeDelta = #self.reward_array == 1 and FrameHeightEnum.NormalOne or FrameHeightEnum.NormalTwo
  end
  m_img_bg_special:GetComponent("RectTransform").sizeDelta = #self.reward_array == 1 and FrameHeightEnum.SpecialOne or FrameHeightEnum.SpecialTwo
end

function UIActSignItem:OnInitRewardItem(go, index)
  index = index + 1
  local data = self.reward_array[index]
  go.transform.localScale = Vector3.one
  local item = self.reward_item_cache[index]
  if not item then
    local transform = go.transform
    self.reward_item_cache[index] = {
      common_item_go = transform:Find("c_reward1").gameObject,
      is_got_go = transform:Find("c_img_got").gameObject
    }
    item = self.reward_item_cache[index]
  end
  local server_data = self.m_itemData.server_data
  local is_got = server_data.iAwardedMaxDays >= self.m_itemIndex
  if not self.m_img_bk_finish then
    item.is_got_go:SetActive(is_got)
  else
    item.is_got_go:SetActive(false)
  end
  if self.m_img_bk_finish then
    self.m_img_bk_finish:SetActive(is_got)
  end
  local reward_item = self:createCommonItem(item.common_item_go)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = data[1],
    iNum = data[2]
  })
  reward_item:SetItemInfo(processData)
  reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
  self.m_task_red_dot:SetActive(false)
  self.m_task_red_one:SetActive(false)
end

function UIActSignItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  local server_data = self.m_itemData.server_data
  local is_got = server_data.iAwardedMaxDays >= self.m_itemIndex
  for _, item in ipairs(self.reward_item_cache) do
    if not self.m_img_bk_finish then
      item.is_got_go:SetActive(is_got)
    else
      item.is_got_go:SetActive(false)
    end
  end
  self.m_btn_touch:SetActive(not is_got and server_data.iLoginDays >= self.m_itemIndex)
  if is_got then
    self.m_txt_day_MCC:SetColorByIndex(0)
  else
    local idx = server_data.iLoginDays >= self.m_itemIndex and 1 or 0
    self.m_txt_day_MCC:SetColorByIndex(idx)
  end
  local is_next_day = server_data.iLoginDays + 1 == self.m_itemIndex
  self.m_next_get:SetActive(is_next_day)
  local red_go = #self.reward_array == 1 and self.m_task_red_one or self.m_task_red_dot
  self:RegisterOrUpdateRedDotItem(red_go, RedDotDefine.ModuleType.HeroActSignItemCanRec, {
    self.m_itemIndex,
    server_data.iLoginDays,
    is_got
  })
  if self.m_img_bk_finish then
    self.m_img_bk_finish:SetActive(is_got)
  end
end

function UIActSignItem:OnBtntouchClicked()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex, self.m_itemRootObj)
  end
end

function UIActSignItem:OnChooseItem(flag)
end

return UIActSignItem
