local Form_Activity110_Warmup_Victory = class("Form_Activity110_Warmup_Victory", require("UI/UIFrames/Form_Activity110_Warmup_VictoryUI"))
local levelTb = ConfigManager:GetConfigInsByName("MiniGameFlopLevelInfo")
local clueInfoTb = ConfigManager:GetConfigInsByName("MiniGameFlopClueInfo")

function Form_Activity110_Warmup_Victory:SetInitParam(param)
end

function Form_Activity110_Warmup_Victory:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity110_Warmup_Victory:OnActive()
  self.super.OnActive(self)
  self.Param = self.m_csui.m_param
  self.levelCfg = levelTb:GetValue_ByLevelID(self.Param.LevelId)
  self.activityId = self.Param.activityId
  self.step = self.Param.step
  self.gameWin = self.Param.gameWin
  self.isGetClue = self.Param.isGetClue
  self.isGetedClue = self.Param.isGetedClue
  self.vReward = self.Param.vReward
  if self.gameWin then
    GlobalManagerIns:TriggerWwiseBGMState(378)
    UILuaHelper.SetActive(self.m_pnl_win, true)
    UILuaHelper.SetActive(self.m_pnl_deft, false)
    if self.step <= self.levelCfg.m_Steps then
      UILuaHelper.SetActive(self.m_icon_win2, false)
      UILuaHelper.SetActive(self.m_icon_win3, true)
    else
      UILuaHelper.SetActive(self.m_icon_win2, true)
      UILuaHelper.SetActive(self.m_icon_win3, false)
    end
    self.m_txt_condition2_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100906), self.levelCfg.m_Steps)
    if self.isGetClue and not self.isGetedClue then
      UILuaHelper.SetActive(self.m_pnl_handbook, true)
      self.m_txt_step_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100902), self.step, self.levelCfg.m_Steps)
      local clueCfg = clueInfoTb:GetValue_ByClueID(self.levelCfg.m_Clue)
      UILuaHelper.SetAtlasSprite(self.m_icon_handbook_Image, clueCfg.m_Pic)
    else
      UILuaHelper.SetActive(self.m_pnl_handbook, false)
    end
    self.m_Grid = self:CreateInfinityGrid(self.m_reward_view1_InfinityGrid, "ActivityMinigame110/Activity110_DetailItem")
    local data = {}
    for _, v in pairs(utils.changeCSArrayToLuaTable(self.levelCfg.m_FirstRewards)) do
      local ishave = table.size(self.vReward) == 0
      table.insert(data, {rewardData = v, is_have_get = ishave})
    end
    self.m_Grid:ShowItemList(data)
  else
    GlobalManagerIns:TriggerWwiseBGMState(379)
    UILuaHelper.SetActive(self.m_pnl_win, false)
    UILuaHelper.SetActive(self.m_pnl_deft, true)
  end
end

function Form_Activity110_Warmup_Victory:OnBtncloseClicked()
  self:CloseForm()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITY110_WARMUP_MAIN)
end

function Form_Activity110_Warmup_Victory:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity110_Warmup_Victory:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity110_Warmup_Victory:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity110_Warmup_Victory", Form_Activity110_Warmup_Victory)
return Form_Activity110_Warmup_Victory
