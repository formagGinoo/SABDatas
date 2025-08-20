local Form_Activity105_PV = class("Form_Activity105_PV", require("UI/UIFrames/Form_Activity105_PVUI"))
local scale = 0.6

function Form_Activity105_PV:SetInitParam(param)
end

function Form_Activity105_PV:AfterInit()
  self.super.AfterInit(self)
  self.mPrefabHelper = self.m_itemNode:GetComponent("PrefabHelper")
end

function Form_Activity105_PV:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:FreshUI()
end

function Form_Activity105_PV:OnInactive()
  self.super.OnInactive(self)
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_Activity105_PV:OnDestroy()
  self.super.OnDestroy(self)
  self.activity = nil
end

function Form_Activity105_PV:InitData()
  local tParam = self.m_csui.m_param
  if not tParam then
    self:CloseForm()
    log.error("Form_Activity105_PV InitData error! tParam is nil")
    return
  end
  local iActivityID = tParam.activityId
  local activity = ActivityManager:GetActivityByID(iActivityID)
  if not activity then
    self:CloseForm()
    log.error("Form_Activity105_PV InitData error! activity is nil")
    return
  end
  local timeline = activity:GetClientConfig().sTimelineName
  if not timeline or timeline == "" then
    self:CloseForm()
    log.error("Form_Activity105_PV InitData error! timeline is nil")
    return
  end
  self.sTimeline = timeline
  self.iActivityID = iActivityID
  self.activity = activity
  self.m_csui.m_param = nil
end

function Form_Activity105_PV:FreshUI()
  if not self.activity then
    self:CloseForm()
    return
  end
  local bIsRewarded = self.activity:GetbIsRewarded()
  local rewardList = self.activity:GetCommonConfig().vReward
  utils.ShowPrefabHelper(self.mPrefabHelper, function(go, index, data)
    go.transform.localScale = Vector3.one * scale
    local rewardData = ResourceUtil:GetProcessRewardData({
      iID = data.iID,
      iNum = data.iNum
    })
    local commonItem = self:createCommonItem(go)
    commonItem:SetItemInfo(rewardData)
    commonItem:SetItemHaveGetActive(bIsRewarded)
    commonItem:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnRewardItemClick(itemID, itemNum, itemCom)
    end)
  end, rewardList)
  self.m_z_txt_reward_tip:SetActive(not bIsRewarded)
end

function Form_Activity105_PV:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_Activity105_PV:OnBtnplayClicked()
  CS.UI.UILuaHelper.PlayTimeline(self.sTimeline, true, "", function()
    if self.activity then
      local bIsRewarded = self.activity:GetbIsRewarded()
      if bIsRewarded then
        return
      end
      self.activity:RequestGetReward(function()
        self:FreshUI()
      end)
    end
    CS.UI.UILuaHelper.BlackTopOut(1, 0)
  end)
end

function Form_Activity105_PV:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_Activity105_PV:IsOpenGuassianBlur()
end

local fullscreen = true
ActiveLuaUI("Form_Activity105_PV", Form_Activity105_PV)
return Form_Activity105_PV
