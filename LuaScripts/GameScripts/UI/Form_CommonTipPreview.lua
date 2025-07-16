local Form_CommonTipPreview = class("Form_CommonTipPreview", require("UI/UIFrames/Form_CommonTipPreviewUI"))

function Form_CommonTipPreview:SetInitParam(param)
end

function Form_CommonTipPreview:AfterInit()
  self.super.AfterInit(self)
  local initGiftGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_itemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initGiftGridData)
end

function Form_CommonTipPreview:OnActive()
  self.super.OnActive(self)
  self:InitView()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(35)
end

function Form_CommonTipPreview:OnInactive()
  self.super.OnInactive(self)
end

function Form_CommonTipPreview:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CommonTipPreview:InitView()
  local tParam = self.m_csui.m_param
  local vReward = tParam.vReward
  local vCustomData = tParam.vCustomData or {}
  local vItemData = {}
  local vRewardLua = vReward
  if type(vReward) == "userdata" then
    vRewardLua = utils.changeCSArrayToLuaTable(vReward)
  end
  for k, v in ipairs(vRewardLua) do
    local processData = ResourceUtil:GetProcessRewardData(v, vCustomData[k])
    vItemData[#vItemData + 1] = processData
  end
  if tParam.sContent then
    self.m_word:SetActive(true)
    self.m_word_Text.text = tParam.sContent
  else
    self.m_word:SetActive(false)
  end
  self.m_itemInfinityGrid:ShowItemList(vItemData)
end

function Form_CommonTipPreview:OnBtnYesClicked()
  self:CloseForm()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(37)
end

function Form_CommonTipPreview:IsFullScreen()
  return false
end

function Form_CommonTipPreview:IsOpenGuassianBlur()
  return true
end

function Form_CommonTipPreview:OnItemClk(itemIndex, itemRootObj, itemIcon)
  utils.openItemDetailPop({
    iID = itemIcon.m_iItemID,
    iNum = 1
  })
end

local fullscreen = true
ActiveLuaUI("Form_CommonTipPreview", Form_CommonTipPreview)
return Form_CommonTipPreview
