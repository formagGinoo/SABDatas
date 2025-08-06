local Form_PickUpWindow_new = class("Form_PickUpWindow_new", require("UI/UIFrames/Form_PickUpWindow_newUI"))

function Form_PickUpWindow_new:SetInitParam(param)
end

function Form_PickUpWindow_new:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnCommonItemClk)
  }
  self.m_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_choosereward_InfinityGrid, "PickUp/PickUpChooseItem", initGridData)
end

function Form_PickUpWindow_new:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:FreshUI()
end

function Form_PickUpWindow_new:OnInactive()
  self.super.OnInactive(self)
end

function Form_PickUpWindow_new:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PickUpWindow_new:InitData()
  self.giftCfg = self.m_csui.m_param.giftCfg
  self.giftInfo = self.m_csui.m_param.giftInfo
  self.activity = self.m_csui.m_param.activity
  self.mOriGridRewardIndex = self.giftInfo and table.copy(self.giftInfo.mGridRewardIndex) or {}
  self.m_isSoldOut = self.giftInfo and self.giftInfo.iBoughtNum >= self.giftCfg.iBuyLimit
end

function Form_PickUpWindow_new:FreshUI()
  local giftCfg = self.giftCfg
  local giftInfo = self.giftInfo
  local tempList = {}
  for i, v in ipairs(giftCfg.stGrids.mGridCfg) do
    if i ~= 1 then
      table.insert(tempList, {
        cfg = v,
        chooseIdx = giftInfo and giftInfo.mGridRewardIndex[i] or nil
      })
    else
      self.m_txt_giftnum_Text.text = v[1].iNum
    end
  end
  self.m_InfinityGrid:ShowItemList(tempList)
  self.m_btn_save:SetActive(not self.m_isSoldOut)
end

function Form_PickUpWindow_new:OnCommonItemClk(index, chooseIdx)
  if self.m_isSoldOut then
    return
  end
  index = index + 1
  local giftInfo = self.giftInfo or {}
  local mGridRewardIndex = giftInfo.mGridRewardIndex or {}
  mGridRewardIndex[index] = chooseIdx - 1
  giftInfo.mGridRewardIndex = mGridRewardIndex
  self.giftInfo = giftInfo
  self:FreshUI()
end

function Form_PickUpWindow_new:OnBtnCloseClicked()
  local flag = table.deepcompare(self.giftInfo.mGridRewardIndex, self.mOriGridRewardIndex)
  if not flag then
    utils.CheckAndPushCommonTips({
      tipsID = 1236,
      func1 = function()
        self:CloseForm()
        self.giftInfo.mGridRewardIndex = self.mOriGridRewardIndex
      end
    })
    return
  end
  self:CloseForm()
  self.giftInfo.mGridRewardIndex = self.mOriGridRewardIndex
end

function Form_PickUpWindow_new:OnBtnReturnClicked()
  local flag = table.deepcompare(self.giftInfo.mGridRewardIndex, self.mOriGridRewardIndex)
  if not flag then
    utils.CheckAndPushCommonTips({
      tipsID = 1236,
      func1 = function()
        self:CloseForm()
        self.giftInfo.mGridRewardIndex = self.mOriGridRewardIndex
      end
    })
    return
  end
  self:CloseForm()
  self.giftInfo.mGridRewardIndex = self.mOriGridRewardIndex
end

function Form_PickUpWindow_new:OnBtnsaveClicked()
  if self.giftInfo then
    local isSoldOut = self.giftInfo and self.giftInfo.iBoughtNum >= self.giftCfg.iBuyLimit
    if isSoldOut then
      return
    end
    local count = 0
    for _, v in pairs(self.giftInfo.mGridRewardIndex) do
      count = count + 1
    end
    if 0 < count then
      self.activity:RqsSetReward(self.giftCfg.iGiftId, self.giftInfo.mGridRewardIndex)
    end
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(52005))
    self:CloseForm()
  end
end

function Form_PickUpWindow_new:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PickUpWindow_new", Form_PickUpWindow_new)
return Form_PickUpWindow_new
