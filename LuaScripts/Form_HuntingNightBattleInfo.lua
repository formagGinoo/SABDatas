local Form_HuntingNightBattleInfo = class("Form_HuntingNightBattleInfo", require("UI/UIFrames/Form_HuntingNightBattleInfoUI"))
local SKILL_NUM = 2

function Form_HuntingNightBattleInfo:SetInitParam(param)
end

function Form_HuntingNightBattleInfo:AfterInit()
  self.super.AfterInit(self)
end

function Form_HuntingNightBattleInfo:OnActive()
  self.super.OnActive(self)
  if not self.m_csui.m_param then
    return
  end
  self:AddEventListeners()
  if not self.m_csui.m_param or not self.m_csui.m_param.bossId then
    return
  end
  local stTargetId = self.m_csui.m_param.stTargetId
  self.m_selBossId = self.m_csui.m_param.bossId
  UILuaHelper.SetActive(self.m_scroll_view, false)
  UILuaHelper.SetActive(self.m_common_empty, false)
  HuntingRaidManager:ReqHuntingRaidGetPlayerRecordCS(stTargetId, self.m_selBossId)
end

function Form_HuntingNightBattleInfo:OnInactive()
  self:RemoveAllEventListeners()
end

function Form_HuntingNightBattleInfo:AddEventListeners()
  self:addEventListener("eGameEvent_HuntingRaid_GetPlayerRecord", handler(self, self.RefreshData))
end

function Form_HuntingNightBattleInfo:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HuntingNightBattleInfo:RefreshData(data)
  local mRecord = data.stRecord
  local recordList = {}
  if mRecord then
    local vRecordHero = mRecord.vRecordHero
    local vRecordBuff = mRecord.vRecordBuff or {}
    local forceLevel = self:GetForceLevel()
    local heroList = {}
    for i, v in pairs(vRecordHero) do
      local heroId = v.iHeroId
      local iBreak = v.iBreak
      local iLevel = forceLevel
      if v.iType == MTTDProto.FormHeroType_Trial then
        local cfg = HeroManager:GetCharacterTrialCfgById(v.iHeroId)
        if cfg then
          heroId = cfg.m_SourceID
          iLevel = cfg.m_Level
        end
      end
      heroList[#heroList + 1] = {
        iHeroId = heroId,
        iBreak = iBreak,
        iLevel = iLevel
      }
    end
    recordList[#recordList + 1] = {heroList = heroList, buffList = vRecordBuff}
  end
  self.m_common_empty:SetActive(table.getn(recordList) == 0)
  UILuaHelper.SetActive(self.m_scroll_view, table.getn(recordList) > 0)
  self:refreshLoopScroll(recordList)
  self.m_scroll_view:GetComponent("ScrollRect").normalizedPosition = CS.UnityEngine.Vector2(0, 1)
end

function Form_HuntingNightBattleInfo:GetForceLevel()
  local forceLevel = 0
  local bossCfg = HuntingRaidManager:GetHuntingRaidBossCfgById(self.m_selBossId)
  if bossCfg then
    local curStageCfg = HuntingRaidManager:GetHuntingRaidLevelCfgById(bossCfg.m_LevelID)
    if curStageCfg then
      local heroModify = curStageCfg.m_HeroModify
      if heroModify ~= 0 then
        local heroModifyCfg = LevelManager:GetHeroModifyCfg(heroModify) or {}
        return heroModifyCfg.m_ForceLevel
      end
    end
  end
  return forceLevel
end

function Form_HuntingNightBattleInfo:refreshLoopScroll(recordList)
  local data = recordList
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scroll_view
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_HuntingNightBattleInfo:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local heroList = cell_data.heroList
  local buffList = cell_data.buffList
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  for i = 1, 5 do
    local common_hero_small = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_common_hero_small" .. i)
    local commonHeroItem = self:createHeroIcon(common_hero_small)
    if heroList[i] then
      commonHeroItem:SetHeroData(heroList[i])
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_common_hero_small" .. i, heroList[i])
  end
  for i = 1, SKILL_NUM do
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_skill" .. i, buffList[i])
    if buffList[i] then
      local effectCfg = HuntingRaidManager:GetBattleGlobalEffectCfgById(buffList[i])
      if effectCfg then
        LuaBehaviourUtil.setImg(luaBehaviour, "m_img_iconskillbuff" .. i, effectCfg.m_Icon)
      end
    end
  end
end

function Form_HuntingNightBattleInfo:IsOpenGuassianBlur()
  return true
end

function Form_HuntingNightBattleInfo:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_HuntingNightBattleInfo", Form_HuntingNightBattleInfo)
return Form_HuntingNightBattleInfo
