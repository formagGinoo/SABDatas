local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivitySignSixPuzzleSubPanel = class("ActivitySignSixPuzzleSubPanel", UISubPanelBase)
local SignMaxNum = 6

function ActivitySignSixPuzzleSubPanel:OnInit()
  self.m_vPanelItemConfig = {}
  for i = 1, SignMaxNum do
    self.m_vPanelItemConfig[i] = {}
    self.m_vPanelItemConfig[i].rewardItemUnlock = self["m_img_bggetreward" .. i]
    self.m_vPanelItemConfig[i].rewardItemIcon = self["m_img_reward" .. i]:GetComponent(T_Image)
    self.m_vPanelItemConfig[i].rewardNum = self["m_txt_rewardnum" .. i]:GetComponent(T_TextMeshProUGUI)
    self.m_vPanelItemConfig[i].rewardFinish = self["m_img_done" .. i]
    self.m_vPanelItemConfig[i].rewardBtn = self["m_pnl_item" .. i]:GetComponent(T_Button)
    self.m_vPanelItemConfig[i].rewardItemBtn = self["m_btn_reward_piece" .. i]:GetComponent(T_Button)
  end
  local m_PrefabHelper = self.m_reward:GetComponent("PrefabHelper")
  self.m_PrefabHelper = m_PrefabHelper
  self.m_exRewardList = {}
end

function ActivitySignSixPuzzleSubPanel:AddEventListeners()
  self.m_iHandlerIDUpdateSign = self:addEventListener("eGameEvent_Activity_Sign_UpdateSign", handler(self, self.OnEventUpdateSign))
  self.m_iHandlerIDReload = self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
end

function ActivitySignSixPuzzleSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function ActivitySignSixPuzzleSubPanel:OnFreshData()
  self:FreshActData()
  self:RemoveAllEventListeners()
  self:AddEventListeners()
  self:RefreshUI()
end

function ActivitySignSixPuzzleSubPanel:FreshActData()
  self.m_activityId = self.m_panelData.activity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(self.m_activityId)
  if not self.m_stActivity then
    return
  end
end

function ActivitySignSixPuzzleSubPanel:OnEventUpdateSign(stParam)
  if stParam.iActivityID ~= self.m_activityId then
    return
  end
  if self.m_rootObj.activeInHierarchy then
    local reward = {}
    local exReward = {}
    if stParam.index and (stParam.index == SignMaxNum or stParam.vReward[2]) then
      reward[#reward + 1] = stParam.vReward[1]
      for i = 2, #stParam.vReward do
        exReward[#exReward + 1] = stParam.vReward[i]
      end
    else
      reward = stParam.vReward
    end
    utils.popUpRewardUI(reward)
    if table.getn(exReward) > 0 then
      utils.popUpRewardUI(exReward)
    end
    self:RefreshUI()
    if self.m_parentLua then
      self.m_parentLua:RefreshTableButtonList()
    end
  end
end

function ActivitySignSixPuzzleSubPanel:OnEventActivityReload()
  if self.m_activityId then
    self.m_stActivity = ActivityManager:GetActivityByID(self.m_activityId)
    if not self.m_stActivity then
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
      return
    end
    self:RefreshUI()
  end
end

function ActivitySignSixPuzzleSubPanel:RefreshUI()
  if not self.m_stActivity then
    return
  end
  self:RefreshSignReward()
  self:RefreshFinallyReward()
end

function ActivitySignSixPuzzleSubPanel:RefreshSignReward()
  if not self.m_stActivity then
    return
  end
  local iSignNum = self.m_stActivity:GetSignNum()
  local bSignToday = self.m_stActivity:IsSignToday()
  local vSignInfoList = self.m_stActivity:GetSignInfoList()
  local iRewardCount = math.min(#vSignInfoList, SignMaxNum)
  for i = 1, iRewardCount do
    local stSignInfo = vSignInfoList[i]
    local stSignInfoReward
    if stSignInfo and stSignInfo.stRewardInfo and #stSignInfo.stRewardInfo > 0 then
      stSignInfoReward = stSignInfo.stRewardInfo[1]
      do
        local isShowReward = false
        local stPanelItemConfig = self.m_vPanelItemConfig[i]
        if i <= iSignNum then
          isShowReward = false
          stPanelItemConfig.rewardFinish:SetActive(true)
        elseif i == iSignNum + 1 and not bSignToday then
          isShowReward = true
          stPanelItemConfig.rewardFinish:SetActive(false)
          stPanelItemConfig.rewardItemUnlock:SetActive(true)
          UILuaHelper.BindButtonClickManual(stPanelItemConfig.rewardBtn, function()
            if self.m_stActivity then
              local bSignToday = self.m_stActivity:IsSignToday()
              if not bSignToday then
                stPanelItemConfig.rewardFinish:SetActive(true)
                UILuaHelper.PlayAnimationByName(stPanelItemConfig.rewardFinish, "m_pnl_puzzle_item_done_in")
                self:KillRewardTimer()
                self.m_getRewardTimer = TimeService:SetTimer(1, 1, function()
                  self.m_stActivity:RequestSign(stSignInfo.iIndex)
                end)
              else
                self:KillRewardTimer()
              end
            end
          end)
        elseif i == iSignNum + 1 and bSignToday then
          isShowReward = true
          stPanelItemConfig.rewardFinish:SetActive(false)
          stPanelItemConfig.rewardItemUnlock:SetActive(false)
        else
          isShowReward = true
          stPanelItemConfig.rewardFinish:SetActive(false)
          stPanelItemConfig.rewardItemUnlock:SetActive(false)
        end
        if isShowReward then
          ResourceUtil:CreatIconById(stPanelItemConfig.rewardItemIcon, stSignInfoReward.iID)
          stPanelItemConfig.rewardNum.text = stSignInfoReward.iNum
          UILuaHelper.BindButtonClickManual(stPanelItemConfig.rewardItemBtn, function()
            utils.openItemDetailPop({
              iID = stSignInfoReward.iID,
              iNum = stSignInfoReward.iNum
            })
          end)
        end
        if i == SignMaxNum and stSignInfo.stRewardInfo[2] then
          self.m_exRewardList = {}
          for i = 2, #stSignInfo.stRewardInfo do
            self.m_exRewardList[#self.m_exRewardList + 1] = stSignInfo.stRewardInfo[i]
          end
        end
      end
    end
  end
end

function ActivitySignSixPuzzleSubPanel:RefreshFinallyReward()
  local iSignNum = self.m_stActivity:GetSignNum()
  self.m_txt_progress_Text.text = iSignNum .. "/" .. SignMaxNum
  if not utils.isNull(self.m_PrefabHelper) and self.m_exRewardList and #self.m_exRewardList > 0 then
    self.m_PrefabHelper:RegisterCallback(handler(self, self.OnInitRewardItem))
    self.m_PrefabHelper:CheckAndCreateObjs(#self.m_exRewardList)
  end
end

function ActivitySignSixPuzzleSubPanel:OnInitRewardItem(go, index)
  index = index + 1
  local data = self.m_exRewardList[index]
  go.transform.localScale = Vector3.one * 0.52
  local reward_item = self:createCommonItem(go)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = data.iID,
    iNum = data.iNum
  })
  reward_item:SetItemInfo(processData)
  reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
  reward_item:SetItemHaveGetActive(self.m_stActivity:isAllTaskFinished())
end

function ActivitySignSixPuzzleSubPanel:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function ActivitySignSixPuzzleSubPanel:KillRewardTimer()
  if self.m_getRewardTimer then
    TimeService:KillTimer(self.m_getRewardTimer)
    self.m_getRewardTimer = nil
  end
end

function ActivitySignSixPuzzleSubPanel:OnInactive()
  self:KillRewardTimer()
  self:RemoveAllEventListeners()
end

return ActivitySignSixPuzzleSubPanel
