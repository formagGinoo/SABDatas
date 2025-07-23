local UIItemBase = require("UI/Common/UIItemBase")
local UIBattlePassTaskItem = class("UIBattlePassTaskItem", UIItemBase)

function UIBattlePassTaskItem:OnInit()
end

function UIBattlePassTaskItem:OnFreshData()
  local data = self.m_itemData
  local iQuestId = data.iQuestId
  local stActivity = data.activity
  local taskCfg = data.questCfg
  self.m_taskCfg = taskCfg
  self.m_txt_content_Text.text = taskCfg.m_mTaskName
  self.m_txt_point_Text.text = taskCfg.m_Score
  local questStatus = stActivity:GetQuestStatus(iQuestId)
  if questStatus == nil then
    self.m_btn_receive:SetActive(false)
    self.m_img_complete:SetActive(true)
    self.m_btn_go:SetActive(false)
    self:SetTaskProgress(taskCfg.m_ObjectiveCount, taskCfg.m_ObjectiveCount)
  else
    local iState = questStatus.iState
    if iState == MTTDProto.QuestState_Doing then
      self.m_btn_receive:SetActive(false)
      self.m_img_complete:SetActive(false)
      self.m_btn_go:SetActive(true)
      self:SetTaskProgress(questStatus.vCondStep[1], taskCfg.m_ObjectiveCount)
    elseif iState == MTTDProto.QuestState_Finish then
      self.m_btn_receive:SetActive(true)
      self.m_img_complete:SetActive(false)
      self.m_btn_go:SetActive(false)
      self:SetTaskProgress(questStatus.vCondStep[1], taskCfg.m_ObjectiveCount)
    elseif iState == MTTDProto.QuestState_Over then
      self.m_btn_go:SetActive(false)
      self.m_btn_receive:SetActive(false)
      self.m_img_complete:SetActive(true)
      self:SetTaskProgress(taskCfg.m_ObjectiveCount, taskCfg.m_ObjectiveCount)
    end
  end
end

function UIBattlePassTaskItem:SetTaskProgress(iProgress, iTotal)
  self.m_txt_contentnum_Text.text = iProgress .. "/" .. iTotal
end

function UIBattlePassTaskItem:OnBtngoClicked()
  QuickOpenFuncUtil:OpenFunc(self.m_taskCfg.m_Jump)
  if self.m_taskCfg.m_Jump == 18 then
    self:broadcastEvent("eGameEvent_Activity_BattlePass_CloseMain")
  end
end

function UIBattlePassTaskItem:OnBtnreceiveClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(40)
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_taskCfg, self.m_itemIndex, self)
  end
end

function UIBattlePassTaskItem:RefreshItemFx(delay)
  self.m_itemRootObj:SetActive(false)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(delay)
  sequence:OnComplete(function()
    self.m_itemRootObj:SetActive(true)
    UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "pnl_task_list_item_in")
  end)
  sequence:SetAutoKill(true)
end

function UIBattlePassTaskItem:PlayTaskComplateAnim()
  if self.m_img_complete.activeSelf then
    UILuaHelper.PlayAnimationByName(self.m_img_complete, "BattlePassTask_get")
  end
end

return UIBattlePassTaskItem
