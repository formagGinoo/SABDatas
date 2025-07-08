local Form_BattleDefeat = class("Form_BattleDefeat", require("UI/UIFrames/Form_BattleDefeatUI"))
local BattleFlowManager = _ENV.BattleFlowManager
local BattleResultIndexIns = ConfigManager:GetConfigInsByName("BattleResultIndex")
local BattleDefeatPromptIns = ConfigManager:GetConfigInsByName("BattleDefeatPrompt")

function Form_BattleDefeat:SetInitParam(param)
end

function Form_BattleDefeat:AfterInit()
  self.super.AfterInit(self)
  self.m_levelType = nil
  self.m_levelID = nil
end

function Form_BattleDefeat:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(10)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_BattleDefeat:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_BattleDefeat:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattleDefeat:AddEventListeners()
end

function Form_BattleDefeat:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattleDefeat:ClearData()
end

function Form_BattleDefeat:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_levelID = tParam.levelID
  self.m_areaId = tParam.areaId
  self.m_mapID = tParam.mapID
  self.m_isExplore = false
  local mapData = ConfigManager:GetBattleWorldCfgById(self.m_mapID)
  if not mapData:GetError() and mapData.m_StageType == 1 then
    self.m_isExplore = true
  end
  self.m_csui.m_param = nil
end

function Form_BattleDefeat:FreshUI()
  if self.m_levelType == nil or self.m_levelType == 0 then
    return
  end
  self.m_btn_Restart:SetActive(false)
  self.m_pnl_btn_group:SetActive(false)
  if self.m_levelType > 0 then
    local waveRebattle = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("WaveRebattle").m_Value)
    local mapData = ConfigManager:GetBattleWorldCfgById(self.m_mapID)
    self.m_btn_Restart:SetActive(true)
  end
  self:RefreshFailTxt()
end

function Form_BattleDefeat:RefreshFailTxt()
  if self.m_mapID then
    local battleWorldConfigCfg = ConfigManager:GetConfigInsByName("BattleWorldConfig"):GetValue_ByMapID(self.m_mapID)
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

function Form_BattleDefeat:GetDefeatPrompt(cfgIdList)
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

function Form_BattleDefeat:GetGuideConditionIsOpen(conditionType, conditionParam)
  local ret = false
  if conditionType == 15 and self.m_levelType == tonumber(conditionParam) then
    ret = true
  end
  return ret
end

function Form_BattleDefeat:OnBtnBgCloseClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_Form_BattleDefeat)
  BattleFlowManager:ExitBattle()
end

function Form_BattleDefeat:OnBtnRoleClicked()
  if not UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.GuideDefeatJump, true) then
    return
  end
  CS.BattleGameManager.Instance:HeroUpgrade()
  BattleFlowManager:HandleBattleJump2System(UIDefines.ID_FORM_HEROLIST)
end

function Form_BattleDefeat:OnBtnShopClicked()
  if not UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.GuideDefeatJump, true) then
    return
  end
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Shop)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  BattleFlowManager:HandleBattleJump2System(UIDefines.ID_FORM_SHOP)
end

function Form_BattleDefeat:OnBtnDrawCardClicked()
  if not UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.GuideDefeatJump, true) then
    return
  end
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Gacha)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  BattleFlowManager:HandleBattleJump2System(UIDefines.ID_FORM_GACHAMAIN)
end

function Form_BattleDefeat:OnBtnFormationClicked()
  StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 30005)
end

function Form_BattleDefeat:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_BattleDefeat:OnBtnRestartClicked()
  BattleFlowManager:ReStartBattle(true)
end

function Form_BattleDefeat:OnBtnRestart2Clicked()
  BattleFlowManager:ReStartBattle(true)
end

function Form_BattleDefeat:OnBtnRestartRoundClicked()
  BattleFlowManager:ReStartBattle(false)
end

function Form_BattleDefeat:OnBtnQuitClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_Form_BattleDefeat)
  BattleFlowManager:ExitBattle()
end

ActiveLuaUI("Form_BattleDefeat", Form_BattleDefeat)
return Form_BattleDefeat
