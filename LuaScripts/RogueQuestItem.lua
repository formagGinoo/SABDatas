local UIItemBase = require("UI/Common/UIItemBase")
local RogueQuestItem = class("RogueQuestItem", UIItemBase)
local rewardMaxCount = 2

function RogueQuestItem:OnInit()
  self.prefabHelper = self.m_ItemsNode:GetComponent("PrefabHelper")
end

function RogueQuestItem:OnFreshData()
  local m_quest = self.m_itemData
  if not m_quest then
    return
  end
  local TaskIns = ConfigManager:GetConfigInsByName("Task")
  local taskCfg = TaskIns:GetValue_ByID(m_quest.iId)
  if taskCfg:GetError() then
    return
  end
  self.m_txt_content_Text.text = TaskManager:GetTaskNameById(nil, taskCfg)
  self.m_txt_number_Text.text = taskCfg.m_Score
  local rewards = utils.changeCSArrayToLuaTable(taskCfg.m_Reward)
  utils.ShowPrefabHelper(self.prefabHelper, function(go, index, reward)
    local item = self:createCommonItem(go)
    local processData = ResourceUtil:GetProcessRewardData({
      iID = tonumber(reward[1]),
      iNum = tonumber(reward[2])
    })
    item:SetItemInfo(processData)
    item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnRewardCommonItemClk(itemID, itemNum, itemCom)
    end)
  end, rewards)
  local iState = m_quest.iState
  if iState == MTTDProto.QuestState_Doing then
    self.m_pnl_uncomplete:SetActive(true)
    self.m_btn_receive:SetActive(false)
    self.m_img_complete:SetActive(false)
    self.m_txt_tasknum_Text.text = m_quest.vCondStep[1] .. "/" .. taskCfg.m_ObjectiveCount
  elseif iState == MTTDProto.QuestState_Finish then
    self.m_pnl_uncomplete:SetActive(false)
    self.m_btn_receive:SetActive(true)
    self.m_img_complete:SetActive(false)
  elseif iState == MTTDProto.QuestState_Over then
    self.m_pnl_uncomplete:SetActive(false)
    self.m_btn_receive:SetActive(false)
    self.m_img_complete:SetActive(true)
  end
end

function RogueQuestItem:OnRewardCommonItemClk(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function RogueQuestItem:OnBtnreceiveClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(40)
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemData, self.m_itemIndex, self)
  end
end

return RogueQuestItem
