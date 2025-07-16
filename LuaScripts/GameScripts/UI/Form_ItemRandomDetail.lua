local Form_ItemRandomDetail = class("Form_ItemRandomDetail", require("UI/UIFrames/Form_ItemRandomDetailUI"))

function Form_ItemRandomDetail:SetInitParam(param)
end

function Form_ItemRandomDetail:AfterInit()
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_random_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
end

function Form_ItemRandomDetail:OnActive()
  local tParam = self.m_csui.m_param
  self.m_iRandomPoolID = tParam.iRandomPoolID
  self.m_stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(self.m_iRandomPoolID)
  self.m_random_item_list = {}
  if self.m_stRandomPoolData == nil then
    return
  end
  local vRandomItemInfo = utils.changeCSArrayToLuaTable(self.m_stRandomPoolData.m_RandompoolContent)
  if ActivityManager:IsInCensorOpen() then
    local temp = utils.changeCSArrayToLuaTable(self.m_stRandomPoolData.m_CensorRandompoolContent)
    vRandomItemInfo = 0 < #temp and temp or vRandomItemInfo
  end
  self:RefreshRandomRewardList(vRandomItemInfo)
end

function Form_ItemRandomDetail:RefreshRandomRewardList(itemArr)
  local dataList = {}
  for i, v in ipairs(itemArr) do
    local vItemInfoStr = itemArr[i]
    local iGetItemID = tonumber(vItemInfoStr[1])
    local iGetItemNum = tonumber(vItemInfoStr[2])
    local processData = ResourceUtil:GetProcessRewardData({iID = iGetItemID, iNum = iGetItemNum})
    dataList[#dataList + 1] = processData
  end
  self.m_random_item_list = dataList
  self.m_rewardListInfinityGrid:ShowItemList(dataList)
  self.m_rewardListInfinityGrid:LocateTo(0)
end

function Form_ItemRandomDetail:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
end

function Form_ItemRandomDetail:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEMRANDOMDETAIL)
end

function Form_ItemRandomDetail:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ITEMRANDOMDETAIL)
end

function Form_ItemRandomDetail:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_ItemRandomDetail", Form_ItemRandomDetail)
return Form_ItemRandomDetail
