local Form_Activity101Lamia_Defeat = class("Form_Activity101Lamia_Defeat", require("UI/UIFrames/Form_Activity101Lamia_DefeatUI"))
local BattleResultIndexIns = ConfigManager:GetConfigInsByName("BattleResultIndex")
local BattleDefeatPromptIns = ConfigManager:GetConfigInsByName("BattleDefeatPrompt")

function Form_Activity101Lamia_Defeat:SetInitParam(param)
end

function Form_Activity101Lamia_Defeat:AfterInit()
  self.super.AfterInit(self)
  self.m_activityID = nil
  self.m_levelID = nil
  self.m_levelType = nil
  self.m_finishErrorCode = nil
  self.m_waitTimer = nil
end

function Form_Activity101Lamia_Defeat:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_Activity101Lamia_Defeat:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_Activity101Lamia_Defeat:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity101Lamia_Defeat:AddEventListeners()
end

function Form_Activity101Lamia_Defeat:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Activity101Lamia_Defeat:OnGetGachaData(windowId)
  BattleFlowManager:HandleBattleJump2System(UIDefines.ID_FORM_GACHAMAIN, {windowId = windowId, isPlayAudio = true})
end

function Form_Activity101Lamia_Defeat:ClearData()
end

function Form_Activity101Lamia_Defeat:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_activityID = tParam.activityID
  self.m_levelID = tParam.levelID
  self.m_finishErrorCode = tParam.finishErrorCode
  self.m_csui.m_param = nil
end

function Form_Activity101Lamia_Defeat:FreshUI()
  self:RefreshFailTxt()
end

function Form_Activity101Lamia_Defeat:RefreshFailTxt()
  local helper = LevelHeroLamiaActivityManager:GetLevelHelper()
  local cfg = helper:GetLevelCfgByID(self.m_levelID)
  local m_mapID = cfg.m_MapID
  if m_mapID then
    local battleWorldConfigCfg = ConfigManager:GetConfigInsByName("BattleWorldConfig"):GetValue_ByMapID(m_mapID)
    if battleWorldConfigCfg:GetError() then
      UILuaHelper.SetActive(self.m_configdefeat_txt, false)
    else
      local tempTable = utils.changeCSArrayToLuaTable(battleWorldConfigCfg.m_DefeatPromptID)
      if #tempTable == 1 then
        local data = BattleDefeatPromptIns:GetValue_ByDefeatPromptID(tempTable[1])
        self.m_defeat_des_Text.text = data.m_mDefeatPrompt
      else
        local defeatText = self:GetDefeatPrompt(tempTable)
        if defeatText then
          self.m_defeat_des_Text.text = defeatText
        else
          UILuaHelper.SetActive(self.m_configdefeat_txt, false)
        end
      end
    end
  end
  local failResultId = BattleGlobalManager:GetFailResultID()
  UILuaHelper.SetActive(self.m_pnl_defeat_tips, false)
  if failResultId then
    local battleResultIndexCfg = BattleResultIndexIns:GetValue_ByID(failResultId)
    if battleResultIndexCfg:GetError() then
      return
    end
    if battleResultIndexCfg.m_IsShowConditonReason and battleResultIndexCfg.m_IsShowConditonReason == 1 and battleResultIndexCfg.m_mConditonReason ~= "" then
      UILuaHelper.SetActive(self.m_pnl_defeat_tips, true)
      local tempTxt = battleResultIndexCfg.m_mConditonReason
      if ChannelManager:IsChinaChannel() then
        tempTxt = tempTxt:gsub("<#F11E1D>", "<#B2452B>")
      end
      self.m_txt_defeat_tips_Text.text = tempTxt or ""
    end
  end
end

function Form_Activity101Lamia_Defeat:GetDefeatPrompt(cfgIdList)
  local battleDefeatCfg = ConfigManager:GetConfigInsByName("BattleDefeatPrompt"):GetAll()
  local tempTextTable = {}
  if #cfgIdList == 0 then
    for _, defeatCfg in pairs(battleDefeatCfg) do
      if defeatCfg.m_IsDefault == 1 then
        tempTextTable[#tempTextTable + 1] = defeatCfg
      end
    end
  else
    for _, defeatCfg in pairs(battleDefeatCfg) do
      for _, defeatCfg2 in pairs(cfgIdList) do
        if defeatCfg2 == defeatCfg.m_DefeatPromptID then
          tempTextTable[#tempTextTable + 1] = defeatCfg
        end
      end
    end
  end
  local limit = 1
  local upper = #tempTextTable
  local randomId = -1
  if limit <= upper then
    randomId = math.random(limit, upper)
  end
  if tempTextTable[randomId] then
    return tempTextTable[randomId].m_mDefeatPrompt
  end
end

function Form_Activity101Lamia_Defeat:OnBtnBgCloseClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_Activity101Lamia_Defeat:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 30005)
end

function Form_Activity101Lamia_Defeat:OnBtnRoleClicked()
  CS.BattleGameManager.Instance:HeroUpgrade()
  BattleFlowManager:HandleBattleJump2System(UIDefines.ID_FORM_HEROLIST)
end

function Form_Activity101Lamia_Defeat:OnBtnShopClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Shop)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  BattleFlowManager:HandleBattleJump2System(UIDefines.ID_FORM_SHOP)
end

function Form_Activity101Lamia_Defeat:OnBtnDrawCardClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Gacha)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  GachaManager:GetGachaData()
end

function Form_Activity101Lamia_Defeat:OnBtnFormationClicked()
  StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 30005)
end

function Form_Activity101Lamia_Defeat:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_Activity101Lamia_Defeat:OnBtnRestartClicked()
  BattleFlowManager:ReStartBattle(true)
end

function Form_Activity101Lamia_Defeat:OnBtnRestart2Clicked()
  BattleFlowManager:ReStartBattle(true)
end

function Form_Activity101Lamia_Defeat:OnBtnRestartRoundClicked()
  BattleFlowManager:ReStartBattle(false)
end

function Form_Activity101Lamia_Defeat:OnBtnQuitClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_Form_BattleDefeat)
  BattleFlowManager:ExitBattle()
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_Defeat", Form_Activity101Lamia_Defeat)
return Form_Activity101Lamia_Defeat
