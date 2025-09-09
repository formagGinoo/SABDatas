local Form_ActivityMinigame108_Pop = class("Form_ActivityMinigame108_Pop", require("UI/UIFrames/Form_ActivityMinigame108_PopUI"))

function Form_ActivityMinigame108_Pop:SetInitParam(param)
end

function Form_ActivityMinigame108_Pop:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
end

function Form_ActivityMinigame108_Pop:OnActive()
  self.super.OnActive(self)
  local main_id = self.m_csui.m_param.main_id
  local sub_id = self.m_csui.m_param.sub_id
  local lvconfig = self.m_csui.m_param.data
  local result_list = utils.changeCSArrayToLuaTable(lvconfig.m_ResultGroup) or {}
  local mainProperty = utils.changeCSArrayToLuaTable(lvconfig.m_MainProperty)
  local act_data = HeroActivityManager:GetHeroActData(main_id)
  self.m_txt_plane_name_Text.text = lvconfig.m_mLevelName
  self.m_txt_task1_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20377), result_list[1])
  self.m_txt_task2_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20377), result_list[2])
  self.m_txt_task3_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20377), result_list[3])
  self.m_icon_complete1:SetActive(false)
  self.m_icon_complete2:SetActive(false)
  self.m_icon_complete3:SetActive(false)
  if act_data then
    self.server_gameStat = act_data.server_data.stMiniGame.mGameStat
    self.server_gameScore = act_data.server_data.stMiniGame.mGameScore
  end
  if self.server_gameScore and self.server_gameScore[lvconfig.m_LevelID] then
    self.m_txt_num_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20376), self.server_gameScore[lvconfig.m_LevelID])
    if self.server_gameScore[lvconfig.m_LevelID] <= result_list[1] then
      self.m_icon_complete1:SetActive(true)
      self.m_icon_complete2:SetActive(true)
      self.m_icon_complete3:SetActive(true)
    elseif self.server_gameScore[lvconfig.m_LevelID] <= result_list[2] then
      self.m_icon_complete2:SetActive(true)
      self.m_icon_complete3:SetActive(true)
    elseif self.server_gameScore[lvconfig.m_LevelID] <= result_list[3] then
      self.m_icon_complete3:SetActive(true)
    end
  else
    self.m_txt_num_Text.text = ConfigManager:GetCommonTextById(20383)
  end
  for i = 1, 4 do
    self["m_icon" .. i]:SetActive(false)
  end
  for i = 1, #mainProperty do
    self["m_icon" .. mainProperty[i]]:SetActive(true)
  end
end

function Form_ActivityMinigame108_Pop:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityMinigame108_Pop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityMinigame108_Pop:OnBackClk()
  self:CloseForm()
end

function Form_ActivityMinigame108_Pop:OnBtnsetoutClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITYMINIGAME108ASSEMBLE, self.m_csui.m_param)
end

function Form_ActivityMinigame108_Pop:OnBtnCloseClicked()
  StackFlow:DestroyUI(UIDefines.ID_FORM_ACTIVITYMINIGAME108_POP)
end

local fullscreen = true
ActiveLuaUI("Form_ActivityMinigame108_Pop", Form_ActivityMinigame108_Pop)
return Form_ActivityMinigame108_Pop
