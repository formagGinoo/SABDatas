local Form_PopupLevel = class("Form_PopupLevel", require("UI/UIFrames/Form_PopupLevelUI"))
local NoDragLimitNum = 6

function Form_PopupLevel:SetInitParam(param)
end

function Form_PopupLevel:AfterInit()
  self.super.AfterInit(self)
  self.m_rewardItemWidgets = {}
  self.m_baseRewardItemObj = self.m_reward_base.transform:Find("c_common_item").gameObject
end

function Form_PopupLevel:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(27)
  self:FreshUI()
end

function Form_PopupLevel:OnInactive()
  self.super.OnInactive(self)
end

function Form_PopupLevel:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PopupLevel:FreshUI()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_txt_lv_num_before_Text.text = tParam.lastLevel
  self.m_txt_lv_num_after_Text.text = tParam.curLevel
  local rewardItems = tParam.rewardItem
  self:FreshShowRewardList(rewardItems)
end

function Form_PopupLevel:FreshShowRewardList(rewardItems)
  if not rewardItems then
    return
  end
  local dataLen = #rewardItems
  local parentTrans = self.m_reward_parent
  if dataLen > NoDragLimitNum then
    parentTrans = self.m_reward_content
  end
  local childCount = #self.m_rewardItemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local widget = self.m_rewardItemWidgets[i]
      local processItemData = ResourceUtil:GetProcessRewardData(rewardItems[i])
      widget:SetItemInfo(processItemData)
      widget:SetParent(parentTrans)
      widget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemRootObj = GameObject.Instantiate(self.m_baseRewardItemObj, parentTrans.transform).gameObject
      local widget = self:createCommonItem(itemRootObj)
      self.m_rewardItemWidgets[#self.m_rewardItemWidgets + 1] = widget
      local processItemData = ResourceUtil:GetProcessRewardData(rewardItems[i])
      widget:SetItemInfo(processItemData)
      widget:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
      widget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      self.m_rewardItemWidgets[i]:SetActive(false)
    end
  end
end

function Form_PopupLevel:OnBtnbgClicked()
  self:CloseForm()
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_PopupLevel:OnItemIconClicked(itemID, itemNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_PopupLevel:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_PopupLevel", Form_PopupLevel)
return Form_PopupLevel
