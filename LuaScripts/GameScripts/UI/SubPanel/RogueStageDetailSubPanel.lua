local UISubPanelBase = require("UI/Common/UISubPanelBase")
local RogueStageDetailSubPanel = class("RogueStageDetailSubPanel", UISubPanelBase)
local MonsterIns = ConfigManager:GetConfigInsByName("Monster")
local ipairs = _ENV.ipairs
local EnterAnimStr = "Roguestagedetail_in"
local OutAnimStr = "Roguestagedetail_out"

function RogueStageDetailSubPanel:OnInit()
  self.m_curLevelID = nil
  self.m_levelNameStr = nil
  if self.m_initData then
    self.m_bgClkBack = self.m_initData.bgBackFun
  end
  UILuaHelper.SetActive(self.m_btn_detail_bg, self.m_bgClkBack ~= nil)
  self.m_curBattleWorldCfg = nil
  local initEnemyGridData = {
    itemClkBackFun = handler(self, self.OnEnemyIconClk)
  }
  self.m_enemy_listInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_enemy_list_InfinityGrid, "Monster/UIMonsterSmallItem", initEnemyGridData)
  self.m_enemyList = {}
  self.m_rogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_text_color_list = {}
  for i = 1, 5 do
    self.m_text_color_list[#self.m_text_color_list + 1] = self["m_z_txt_num" .. i .. "_Text"]:GetComponent("MultiColorChange")
  end
end

function RogueStageDetailSubPanel:OnFreshData()
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_curLevelID = self.m_panelData.levelID
  self.m_stageData = self.m_levelRogueStageHelper:GetStageInfoById(self.m_curLevelID)
  self.m_levelCfg = self.m_levelRogueStageHelper:GetStageConfigById(self.m_curLevelID)
  self.m_monsterIdList = self.m_levelRogueStageHelper:GetStageMonsterById(self.m_curLevelID)
  self:FreshLevelInfo()
  self:FreshEnterBattleBtnState()
  GlobalManagerIns:TriggerWwiseBGMState(17)
end

function RogueStageDetailSubPanel:AddEventListeners()
end

function RogueStageDetailSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function RogueStageDetailSubPanel:OnDestroy()
  RogueStageDetailSubPanel.super.OnDestroy(self)
end

function RogueStageDetailSubPanel:FreshLevelInfo()
  self.m_curBattleWorldCfg = nil
  if self.m_levelCfg and self.m_stageData then
    self.m_levelNameStr = self.m_levelCfg.m_mStagename
    local mapID = self.m_stageData.iDailyLevel
    self.m_curBattleWorldCfg = ConfigManager:GetBattleWorldCfgById(mapID)
    self.m_txt_level_name_Text.text = self.m_levelNameStr or ""
    local tips = self.m_levelRogueStageHelper:GetStageRecommendTips(self.m_monsterIdList)
    self.m_txt_recommend_Text.text = tips
    local myKeyLv = self.m_rogueStageHelper:GetDailyRewardLevel()
    local gear = self.m_rogueStageHelper:GetStageGearShowDataByStageId(self.m_stageData.iStageId)
    local maxGear = self.m_rogueStageHelper:GetStageRewardMaxGear(self.m_stageData.iStageId)
    local gearMin, gearMax = self.m_rogueStageHelper:GetRogueStageGearRangeById(self.m_stageData.iStageId)
    for i = 1, 5 do
      self["m_pnl_point" .. i]:SetActive(i <= maxGear)
      self["m_point_finish" .. i]:SetActive(i <= gear)
      self["m_point_now" .. i]:SetActive(i == gear)
      self["m_point_slider" .. i .. "_Image"].fillAmount = i < gear and 1 or 0
      local keyLv = gearMin + i - 1
      if not utils.isNull(self.m_text_color_list[i]) then
        local index = myKeyLv >= keyLv and 0 or 1
        self.m_text_color_list[i]:SetColorByIndex(index)
      end
      if gearMin then
        self["m_z_txt_num" .. i .. "_Text"].text = keyLv
      end
    end
  end
  self:FreshEnemyList()
end

function RogueStageDetailSubPanel:FreshEnemyList()
  if not self.m_curBattleWorldCfg or table.getn(self.m_monsterIdList) == 0 then
    self.m_enemy_listInfinityGrid:ShowItemList({})
    return
  end
  self.m_enemyList = {}
  for i, monsterID in ipairs(self.m_monsterIdList) do
    local monsterCfg = MonsterIns:GetValue_ByMonsterID(monsterID)
    self.m_enemyList[#self.m_enemyList + 1] = {monsterCfg = monsterCfg}
  end
  self.m_enemy_listInfinityGrid:ShowItemList(self.m_enemyList)
  if 0 < table.getn(self.m_enemyList) then
    self.m_enemy_listInfinityGrid:LocateTo(0)
  end
end

function RogueStageDetailSubPanel:FreshEnterBattleBtnState()
  local unlock, pass, name = self.m_levelRogueStageHelper:IsLevelUnLock(self.m_curLevelID)
  UILuaHelper.SetActive(self.m_pnl_lock, not unlock)
  UILuaHelper.SetActive(self.m_btn_battle, unlock)
  local str = ""
  if not pass then
    str = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100708), name)
  else
    str = ConfigManager:GetCommonTextById(100709)
  end
  self.m_txt_lock_Text.text = str
  local heroModify = self.m_levelRogueStageHelper:GetHeroModifyEffectByStageId(self.m_curLevelID)
  if not heroModify or heroModify == 0 then
    self.m_pnl_levellock:SetActive(false)
  else
    self.m_pnl_levellock:SetActive(true)
    self.m_txt_levellock_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100074), heroModify)
  end
end

function RogueStageDetailSubPanel:CheckShowAnimIn()
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, EnterAnimStr)
end

function RogueStageDetailSubPanel:CheckShowAnimOut(endFun)
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, OutAnimStr)
  if endFun then
    endFun()
  end
end

function RogueStageDetailSubPanel:OnBtndetailbgClicked()
  self:CheckShowAnimOut(function()
    if self.m_bgClkBack then
      self.m_bgClkBack()
    end
  end)
end

function RogueStageDetailSubPanel:OnBtnbattleClicked()
  if not self.m_curLevelID then
    return
  end
  RogueStageManager:SetDailyRedPointFlag()
  BattleFlowManager:StartEnterBattle(RogueStageManager.BattleType, self.m_curLevelID)
end

function RogueStageDetailSubPanel:OnBtnsearchClicked()
  if not self.m_curLevelID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ROGUEREWARD, {
    levelID = self.m_curLevelID
  })
end

function RogueStageDetailSubPanel:OnEnemyIconClk(monsterID)
  if not monsterID then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
    battleWorldID = self.m_curBattleWorldCfg.m_MapID,
    stageStr = self.m_levelNameStr,
    monsterList = self.m_enemyList
  })
end

function RogueStageDetailSubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return RogueStageDetailSubPanel
