local Form_GuildRaidBattleDetial = class("Form_GuildRaidBattleDetial", require("UI/UIFrames/Form_GuildRaidBattleDetialUI"))

function Form_GuildRaidBattleDetial:SetInitParam(param)
end

function Form_GuildRaidBattleDetial:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_GuildRaidBattleDetial:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelID = tParam.levelID
  self.m_heroId = tParam.showHeroID
  self.m_param = tParam
  self.m_curStageCfg = GuildManager:GetGuildBattleLevelCfgByID(self.m_levelID)
  if not self.m_curStageCfg then
    log.error("Form_GuildRaidBattleDetial curStageCfg == nil" .. tostring(self.m_levelID))
    return
  end
  UILuaHelper.SetActive(self.m_btn_MaskSkip, true)
  self.m_waitAnimTimer = TimeService:SetTimer(0.5, 1, function()
    TimeService:KillTimer(self.m_waitAnimTimer)
    self.m_waitAnimTimer = nil
    UILuaHelper.SetActive(self.m_btn_MaskSkip, false)
  end)
  self:RefreshUI()
  self:FreshShowSpine(self.m_heroId)
  self:AddEventListeners()
end

function Form_GuildRaidBattleDetial:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
  self:RemoveAllEventListeners()
end

function Form_GuildRaidBattleDetial:AddEventListeners()
end

function Form_GuildRaidBattleDetial:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildRaidBattleDetial:RefreshUI()
  local cfg = GuildManager:GetGuildBattleBossCfgByID(self.m_param.iBossId)
  if cfg then
    self.m_txt_boss_name_Text.text = tostring(cfg.m_mName)
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_img_role_Image, cfg.m_Background2)
  end
  local curHp, maxHp = self.m_param.iBossHp, GuildManager:GetBossMaxHp(self.m_levelID)
  local hpPercent = string.format("%.2f", curHp / maxHp)
  self.m_boss_slider_Image.fillAmount = hpPercent
  self.m_txt_boss_progress_Text.text = string.format(ConfigManager:GetCommonTextById(20048), curHp, maxHp)
  ResourceUtil:CreateGuildBossIconByName(self.m_boss_head_Image, cfg.m_Avatar)
  self.m_txt_boss_lv_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100074), self.m_curStageCfg.m_BossLevel)
  self.m_img_defeat:SetActive(self.m_param.bKill)
  self.m_txt_damage_Text.text = tostring(self.m_param.iRealDamage)
  if self.m_param.iRealDamage ~= self.m_param.iDamage then
    utils.popUpDirectionsUI({
      tipsID = 1513,
      fContentCB = function(content)
        return string.gsubnumberreplace(content, tostring(self.m_param.iRealDamage))
      end
    })
  end
end

function Form_GuildRaidBattleDetial:FreshShowSpine(showHeroID)
  if not showHeroID then
    return
  end
  local heroCfg = HeroManager:GetHeroConfigByID(showHeroID)
  if not heroCfg then
    return
  end
  local spineStr = heroCfg.m_Spine
  if not spineStr then
    return
  end
  self:LoadHeroSpine(spineStr, "battlewin", self.m_hero_root)
end

function Form_GuildRaidBattleDetial:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
  if not heroSpineAssetName then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end)
  end
end

function Form_GuildRaidBattleDetial:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_GuildRaidBattleDetial:OnBtnMaskSkipClicked()
end

function Form_GuildRaidBattleDetial:IsOpenGuassianBlur()
  return true
end

function Form_GuildRaidBattleDetial:OnBtnBgCloseClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_GuildRaidBattleDetial:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_GuildRaidBattleDetial:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidBattleDetial", Form_GuildRaidBattleDetial)
return Form_GuildRaidBattleDetial
