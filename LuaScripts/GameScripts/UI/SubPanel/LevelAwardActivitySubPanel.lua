local UISubPanelBase = require("UI/Common/UISubPanelBase")
local LevelAwardActivitySubPanel = class("LevelAwardActivitySubPanel", UISubPanelBase)
local iMaxCount = 8

function LevelAwardActivitySubPanel:OnInit()
  self.mComponents = {}
  for i = 1, iMaxCount do
    local trans = self["m_activity_levelitem" .. i].transform
    if not utils.isNull(trans) then
      self.mComponents[i] = {
        obj_normal = trans:Find("c_normal_bk").gameObject,
        obj_canGet = trans:Find("c_get_bk").gameObject,
        obj_got = trans:Find("c_item_got").gameObject,
        btn = trans:GetComponent("Button"),
        desc_Text = trans:Find("c_item_text"):GetComponent("TMPPro"),
        num_Text = trans:Find("c_item_num"):GetComponent("TMPPro"),
        icon_Image = trans:Find("c_item_icon"):GetComponent("Image"),
        MultiColorChange = trans:Find("c_item_text"):GetComponent("MultiColorChange")
      }
    end
  end
end

function LevelAwardActivitySubPanel:OnFreshData()
  self:RemoveAllEventListeners()
  self:AddEventListeners()
  self:RefreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(275)
end

function LevelAwardActivitySubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_LevelAwardUpdate", handler(self, self.OnLevelAwardUpdate))
end

function LevelAwardActivitySubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function LevelAwardActivitySubPanel:OnInactive()
  self:RemoveAllEventListeners()
end

function LevelAwardActivitySubPanel:OnLevelAwardUpdate(stParam)
  self.m_parentLua:RefreshTableButtonList()
  if stParam == nil then
    return
  end
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  if stParam.iId ~= nil then
    for k, v in ipairs(self.mComponents) do
      local questInfo = self.m_stActivity:GetQuestList()[k]
      if questInfo.iId == stParam.iId then
        self:RefreshRewardItem(v, questInfo, k)
        break
      end
    end
  end
end

function LevelAwardActivitySubPanel:killRemainTimer()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function LevelAwardActivitySubPanel:RefreshUI()
  self.m_stActivity = self.m_panelData.activity
  if self.m_stActivity == nil then
    return
  end
  local endTime = self.m_stActivity:getActivityEndTime()
  if endTime == 0 then
    if self.timer then
      TimeService:KillTimer(self.timer)
      self.timer = nil
    end
    self.m_pnl_time:SetActive(false)
  else
    self.m_pnl_time:SetActive(true)
    local remainTimes = self.m_stActivity:getActivityRemainTime()
    if remainTimes <= 0 then
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
      return
    end
    self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatCNStr(remainTimes)
    if self.timer then
      TimeService:KillTimer(self.timer)
      self.timer = nil
    end
    self.timer = TimeService:SetTimer(1, remainTimes, function()
      remainTimes = remainTimes - 1
      self.m_txtRemainTime_Text.text = TimeUtil:SecondsToFormatCNStr(remainTimes)
      if remainTimes <= 0 then
        TimeService:KillTimer(self.timer)
        StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
        return
      end
    end)
  end
  local questList = self.m_stActivity:GetQuestList()
  for i, v in ipairs(questList) do
    local item = self.mComponents[i]
    if item then
      self:RefreshRewardItem(item, v)
    end
  end
end

function LevelAwardActivitySubPanel:RefreshRewardItem(item, questInfo)
  item.desc_Text.text = questInfo.sName
  item.num_Text.text = questInfo.vReward[1].iNum
  UILuaHelper.SetAtlasSprite(item.icon_Image, ItemManager:GetItemIconPathByID(questInfo.vReward[1].iID))
  local questState = self.m_stActivity:GetQuestState(questInfo.iId)
  if questState then
    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(function()
      if questState.iState == TaskManager.TaskState.Finish then
        self.m_stActivity:RequestGetReward(questInfo.iId)
      elseif questState.iState == TaskManager.TaskState.Doing then
        local data = questInfo.sObjectiveData
        local level_id = string.split(data, ";")[2]
        local cfgIns = ConfigManager:GetConfigInsByName("MainLevel")
        local cfg = cfgIns:GetValue_ByLevelID(level_id)
        local str = string.gsubNumberReplace(ConfigManager:GetCommonTextById(200115), cfg.m_ChapterIndex)
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, str)
      end
    end)
    if questState.iState == TaskManager.TaskState.Finish then
      item.obj_canGet:SetActive(true)
      item.obj_got:SetActive(false)
      item.obj_normal:SetActive(false)
      item.MultiColorChange:SetColorByIndex(1)
    elseif questState.iState == TaskManager.TaskState.Doing then
      item.obj_canGet:SetActive(false)
      item.obj_got:SetActive(false)
      item.obj_normal:SetActive(true)
    elseif questState.iState == TaskManager.TaskState.Completed then
      item.obj_canGet:SetActive(false)
      item.obj_got:SetActive(true)
      item.obj_normal:SetActive(true)
      item.MultiColorChange:SetColorByIndex(2)
    end
  else
    item.obj_canGet:SetActive(false)
    item.obj_got:SetActive(false)
  end
end

return LevelAwardActivitySubPanel
