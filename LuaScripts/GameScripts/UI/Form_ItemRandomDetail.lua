local Form_ItemRandomDetail = class("Form_ItemRandomDetail", require("UI/UIFrames/Form_ItemRandomDetailUI"))

function Form_ItemRandomDetail:SetInitParam(param)
end

function Form_ItemRandomDetail:AfterInit()
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_random_reward_list_InfinityGrid, "Bag/UIRandomDetailItem")
end

function Form_ItemRandomDetail:OnActive()
  local tParam = self.m_csui.m_param
  self.m_iRandomPoolID = tParam.iRandomPoolID
  self.m_stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(self.m_iRandomPoolID)
  if self.m_stRandomPoolData == nil then
    return
  end
  local vRandomItemInfo = ItemManager:GetItemRandomPoolContentById(self.m_iRandomPoolID)
  if ActivityManager:IsInCensorOpen() then
    local temp = utils.changeCSArrayToLuaTable(self.m_stRandomPoolData.m_CensorRandompoolContent)
    vRandomItemInfo = 0 < #temp and ItemManager:GetItemRandomPoolContentById(self.m_iRandomPoolID, true) or vRandomItemInfo
  end
  self:RefreshRandomRewardList(vRandomItemInfo)
end

function Form_ItemRandomDetail:RefreshRandomRewardList(itemArr)
  local dataList = itemArr or {}
  self.m_rewardListInfinityGrid:ShowItemList(dataList)
  self.m_rewardListInfinityGrid:LocateTo(0)
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
