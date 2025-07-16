local Form_HuntingNightBuffChoose = class("Form_HuntingNightBuffChoose", require("UI/UIFrames/Form_HuntingNightBuffChooseUI"))
local SKILL_NUM = 2

function Form_HuntingNightBuffChoose:SetInitParam(param)
end

function Form_HuntingNightBuffChoose:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnBuffItemClk)
  }
  self.m_buffInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_buff_list_InfinityGrid, "HuntingRaid/UHuntingRaidBuffItem", initGridData)
  self.m_buffInfinityGrid:RegisterButtonCallback("c_item_buff", handler(self, self.OnSkillItemClk))
end

function Form_HuntingNightBuffChoose:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_bossId = tParam.bossId
  self.m_selSkillIndex = nil
  self.m_chooseBuffList = {}
  self:RefreshUI()
  self:AddEventListeners()
  GlobalManagerIns:TriggerWwiseBGMState(283)
end

function Form_HuntingNightBuffChoose:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_HuntingNightBuffChoose:AddEventListeners()
  self:addEventListener("eGameEvent_Hunting_ChooseBuff", handler(self, self.OnSaveBuffCB))
end

function Form_HuntingNightBuffChoose:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HuntingNightBuffChoose:OnSaveBuffCB()
  self:CloseForm()
end

function Form_HuntingNightBuffChoose:GenerateData()
  local skillList = {}
  local cfg = HuntingRaidManager:GetHuntingRaidBossCfgById(self.m_bossId)
  local chooseBuffList = HuntingRaidManager:GetBossBuffById(self.m_bossId)
  if cfg then
    local buffPool = utils.changeCSArrayToLuaTable(cfg.m_BuffPool)
    for i, effectId in ipairs(buffPool) do
      local des = HuntingRaidManager:GetSkillEffectDesByEffectId(effectId)
      local effectCfg = HuntingRaidManager:GetBattleGlobalEffectCfgById(effectId)
      skillList[#skillList + 1] = {
        index = i,
        skillId = effectId,
        des = des,
        cfg = effectCfg,
        is_choose = table.indexof(chooseBuffList, effectId)
      }
    end
  end
  return skillList, table.deepcopy(chooseBuffList)
end

function Form_HuntingNightBuffChoose:RefreshUI()
  self.m_skillList, self.m_chooseBuffList = self:GenerateData()
  self.m_buffInfinityGrid:ShowItemList(self.m_skillList)
  self.m_buffInfinityGrid:LocateTo(0)
  self:RefreshSkillInfo()
end

function Form_HuntingNightBuffChoose:RefreshBuffList()
  for i, v in ipairs(self.m_skillList) do
    if table.indexof(self.m_chooseBuffList, v.skillId) then
      v.is_choose = true
    else
      v.is_choose = nil
    end
  end
  self.m_buffInfinityGrid:ReBindAll()
end

function Form_HuntingNightBuffChoose:RefreshSkillInfo(switchIndex)
  UILuaHelper.SetActive(self.m_z_txt_buffempty, not self.m_selSkillIndex)
  UILuaHelper.SetActive(self.m_pnl_normal, self.m_selSkillIndex)
  if self.m_selSkillIndex and self.m_skillList[self.m_selSkillIndex] then
    local info = self.m_skillList[self.m_selSkillIndex]
    local skillCfg = info.cfg
    if skillCfg then
      self.m_txt_buffname_Text.text = skillCfg.m_mName
    end
    self.m_txt_buffdes_Text.text = tostring(info.des)
  end
  for i = 1, SKILL_NUM do
    UILuaHelper.SetActive(self["m_img_iconskillbuff" .. i], self.m_chooseBuffList[i])
    if self.m_chooseBuffList[i] then
      local effectCfg = HuntingRaidManager:GetBattleGlobalEffectCfgById(self.m_chooseBuffList[i])
      if effectCfg then
        UILuaHelper.SetAtlasSprite(self["m_img_iconskillbuff" .. i .. "_Image"], effectCfg.m_Icon)
      end
    end
    if self.m_selSkillIndex and self.m_skillList[self.m_selSkillIndex] and not table.indexof(self.m_chooseBuffList, self.m_skillList[self.m_selSkillIndex].skillId) then
      UILuaHelper.SetActive(self["m_btn_refresh0" .. i], true)
      UILuaHelper.SetActive(self["m_fx_tips_loop" .. i], true)
    else
      UILuaHelper.SetActive(self["m_btn_refresh0" .. i], false)
      UILuaHelper.SetActive(self["m_fx_tips_loop" .. i], false)
    end
    UILuaHelper.SetActive(self["m_fx_iconskill_switch" .. i], switchIndex == i)
  end
end

function Form_HuntingNightBuffChoose:OnSkillItemClk(idx)
  local index = idx + 1
  if not self.m_skillList[index] or not self.m_skillList[index].skillId then
    return
  end
  if self.m_selSkillIndex then
    self.m_skillList[self.m_selSkillIndex].is_select = false
    self.m_buffInfinityGrid:ReBind(self.m_selSkillIndex)
  end
  self.m_skillList[index].is_select = true
  self.m_buffInfinityGrid:ReBind(index)
  self.m_selSkillIndex = index
  self:RefreshSkillInfo()
  GlobalManagerIns:TriggerWwiseBGMState(284)
end

function Form_HuntingNightBuffChoose:OnBtnrefresh01Clicked()
  local index = 1
  if self.m_selSkillIndex and self.m_skillList[self.m_selSkillIndex] then
    local chooseSkillId = self.m_skillList[self.m_selSkillIndex].skillId
    self.m_chooseBuffList[index] = chooseSkillId
    self:RefreshSkillInfo(index)
    self:RefreshBuffList()
  end
  GlobalManagerIns:TriggerWwiseBGMState(285)
end

function Form_HuntingNightBuffChoose:OnBtnrefresh02Clicked()
  local index = 2
  if self.m_selSkillIndex and self.m_skillList[self.m_selSkillIndex] then
    local chooseSkillId = self.m_skillList[self.m_selSkillIndex].skillId
    if not self.m_chooseBuffList[1] then
      self.m_chooseBuffList[1] = chooseSkillId
    else
      self.m_chooseBuffList[index] = chooseSkillId
    end
    self:RefreshSkillInfo(index)
    self:RefreshBuffList()
  end
  GlobalManagerIns:TriggerWwiseBGMState(285)
end

function Form_HuntingNightBuffChoose:OnBtnconfirmClicked()
  local chooseBuffList = HuntingRaidManager:GetBossBuffById(self.m_bossId)
  if self.m_bossId and table.getn(self.m_chooseBuffList) > 0 and not self:IsSameTab(self.m_chooseBuffList, chooseBuffList) then
    HuntingRaidManager:ReqHuntingRaidChooseBuffCS(self.m_bossId, self.m_chooseBuffList)
  else
    self:CloseForm()
  end
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 54004)
end

function Form_HuntingNightBuffChoose:IsSameTab(tab1, tab2)
  local same = true
  for i, v in pairs(tab1) do
    if not table.indexof(tab2, v) then
      same = false
    end
  end
  return same
end

function Form_HuntingNightBuffChoose:IsOpenGuassianBlur()
  return true
end

function Form_HuntingNightBuffChoose:OnBtncancelClicked()
  self:CloseForm()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 54005)
end

function Form_HuntingNightBuffChoose:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_HuntingNightBuffChoose", Form_HuntingNightBuffChoose)
return Form_HuntingNightBuffChoose
