local Form_GachaShow = class("Form_GachaShow", require("UI/UIFrames/Form_GachaShowUI"))
local GACHA_SUMMON_1_TIME = "Gacha_Summon_1_time"
local GACHA_SUMMON_1_TIME_MAN = "Gacha_Summon_1_time_man"
local GACHA_VIDEO_END = "Gacha_Video_End"
local GACHA_VIDEO_END_MAN = "Gacha_Video_End_man"
local GACHA_SUMMON_10_TIMES = "Gacha_Summon_10_times"
local GACHA_VIDEO_02_1 = {
  [2] = "Gacha_Video_02_1_time_R",
  [3] = "Gacha_Video_02_1_time_SR",
  [4] = "Gacha_Video_02_1_time_SSR"
}
local GACHA_VIDEO_02_10 = {
  [2] = "Gacha_Video_02_10_times_R",
  [3] = "Gacha_Video_02_10_times_SR",
  [4] = "Gacha_Video_02_10_times_SSR"
}

function Form_GachaShow:SetInitParam(param)
end

function Form_GachaShow:AfterInit()
  self.super.AfterInit(self)
end

function Form_GachaShow:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.isSkipVideo = false
  self.m_playIndex = 1
  self.m_heroDataList = tParam.heroDataList or {}
  self.m_newHeroList = {}
  self.m_param = tParam.param or {}
  self.m_ShowSSRVideoFlag = true
  self.m_videoStr = self:GetVideo02PlayName()
  self.m_videoVoice = table.getn(self.m_heroDataList) == 1 and "Gacha_Video_02_1_time" or "Gacha_Video_02_10_times"
  self.m_videoVoiceID = table.getn(self.m_heroDataList) == 1 and 85 or 86
  self:CheckNewHero()
  self:GachaVideo()
  local haveSSR = self:IsHaveSSRHero(self.m_heroDataList)
  local bgmId = haveSSR == true and 54 or 53
  GlobalManagerIns:TriggerWwiseBGMState(bgmId)
end

function Form_GachaShow:GetVideo02PlayName()
  local quality = self:GetGachaHeroMaxQuality()
  local videoNameList = table.getn(self.m_heroDataList) == 1 and GACHA_VIDEO_02_1 or GACHA_VIDEO_02_10
  return videoNameList[quality] or ""
end

function Form_GachaShow:GetGachaHeroMaxQuality()
  local quality = GlobalConfig.QUALITY_COMMON_ENUM.R
  for i, v in ipairs(self.m_heroDataList) do
    if v.heroId then
      local cfg = HeroManager:GetHeroConfigByID(v.heroId)
      if quality < cfg.m_Quality then
        quality = cfg.m_Quality
      end
    end
  end
  return quality
end

function Form_GachaShow:GachaVideo()
  if GachaManager:IsShippedALl() then
    self:GachaVideoQuality()
  else
    CS.UI.UILuaHelper.PlayFromAddRes(self.m_videoStr, "", true, handler(self, self.GachaVideoQuality), CS.UnityEngine.ScaleMode.ScaleToFit, false)
    GlobalManagerIns:TriggerWwiseBGMState(self.m_videoVoiceID)
  end
end

function Form_GachaShow:CheckNewHero()
  if self.m_csui.m_param.param and self.m_csui.m_param.param.vRealItem then
    local vRealItem = self.m_csui.m_param.param.vRealItem
    for i, v in ipairs(self.m_heroDataList) do
      if (not vRealItem[i] or vRealItem[i].iID == 0) and v.quality >= GlobalConfig.QUALITY_COMMON_ENUM.SR then
        self.m_newHeroList[i] = v
      end
    end
  end
end

function Form_GachaShow:GachaVideoQuality()
  CS.GlobalManager.Instance:StopWwiseVoice(self.m_videoVoice)
  if GachaManager:IsShippedALl() then
    GachaManager:SetFirstGachaState(GachaManager.FirstGachaStr)
    self:PlayHeroVideo()
    return
  end
  self:GachaVideoSummon()
end

function Form_GachaShow:GachaVideoSummon()
  if GachaManager:IsShippedALl() then
    GachaManager:SetFirstGachaState(GachaManager.FirstGachaStr)
    self:PlayHeroVideo()
    return
  end
  local str = GachaManager:GetFirstGachaState()
  if str ~= GachaManager.FirstGachaStr then
    CS.UI.UILuaHelper.PlayFromAddRes("Gacha_1stTime_Summon", "", true, handler(self, self.PlayHeroVideo), CS.UnityEngine.ScaleMode.ScaleToFit, false)
    GlobalManagerIns:TriggerWwiseBGMState(89)
    GachaManager:SetFirstGachaState(GachaManager.FirstGachaStr)
  else
    local videoStr = GACHA_SUMMON_10_TIMES
    if #self.m_heroDataList > 1 then
      videoStr = GACHA_SUMMON_10_TIMES
    else
      local sex = GachaManager:CheckGachaResultShowSex(self.m_heroDataList)
      videoStr = sex == 1 and GACHA_SUMMON_1_TIME_MAN or GACHA_SUMMON_1_TIME
    end
    CS.UI.UILuaHelper.PlayFromAddRes(videoStr, "", true, handler(self, self.GachaVideoEnd), CS.UnityEngine.ScaleMode.ScaleToFit, false)
    GlobalManagerIns:TriggerWwiseBGMState(87)
  end
end

function Form_GachaShow:GachaVideoEnd()
  CS.GlobalManager.Instance:StopWwiseVoice("Gacha_Summon_10_times")
  if GachaManager:IsShippedALl() then
    GachaManager:SetFirstGachaState(GachaManager.FirstGachaStr)
    self:PlayHeroVideo()
    return
  end
  local sex = GachaManager:CheckGachaResultShowSex(self.m_heroDataList)
  local videoStr = sex == 1 and GACHA_VIDEO_END_MAN or GACHA_VIDEO_END
  CS.UI.UILuaHelper.PlayFromAddRes(videoStr, "", true, handler(self, self.PlayHeroVideo), CS.UnityEngine.ScaleMode.ScaleToFit, false)
  GlobalManagerIns:TriggerWwiseBGMState(112)
end

function Form_GachaShow:IsNewHero(index)
  local newFlag = false
  if self.m_csui.m_param.param and self.m_csui.m_param.param.vRealItem then
    local vRealItem = self.m_csui.m_param.param.vRealItem
    newFlag = vRealItem[index] == nil or vRealItem[index].iID == 0
  end
  return newFlag
end

function Form_GachaShow:ShowHeroDetailUI()
  if self.m_heroDataList[self.m_playIndex - 1] then
    self.m_newHeroList[self.m_playIndex - 1] = nil
    local isWish = GachaManager:CheckIsWishHero(self.m_param.iGachaId, self.m_heroDataList[self.m_playIndex - 1].heroId)
    local bgmId = self:IsSSRHero(self.m_heroDataList[self.m_playIndex - 1].heroId) == true and 51 or 45
    local param = {
      heroID = self.m_heroDataList[self.m_playIndex - 1].heroId,
      isGacha = true,
      isNew = self:IsNewHero(self.m_playIndex - 1),
      bgmId = bgmId,
      wishFlag = isWish,
      closeCallBack = function()
        self:PlayHeroVideo()
      end
    }
    StackPopup:Push(UIDefines.ID_FORM_HEROSHOW, param)
  else
    self:PlayHeroVideo()
  end
end

function Form_GachaShow:IsShowHeroDetail(quality, index)
  local isShow = true
  if GachaManager:IsShippedALl() then
    local isNew = self:IsNewHero(index)
    if quality == GlobalConfig.QUALITY_COMMON_ENUM.SR and isNew or quality > GlobalConfig.QUALITY_COMMON_ENUM.SR then
      isShow = true
    else
      isShow = false
    end
  end
  return isShow
end

function Form_GachaShow:PlayHeroVideo()
  CS.GlobalManager.Instance:StopWwiseVoice("Gacha_1stTime_Summon")
  CS.GlobalManager.Instance:StopWwiseVoice("Gacha_Video_End")
  if self.m_heroDataList[self.m_playIndex] and self.m_heroDataList[self.m_playIndex].heroId then
    local quality = HeroManager:GetHeroQualityById(self.m_heroDataList[self.m_playIndex].heroId)
    local isShow = self:IsShowHeroDetail(quality, self.m_playIndex)
    if isShow then
      local function ShowHeroFun()
        CS.GlobalManager.Instance:StopWwiseVoice("Gacha_SSR_show")
        
        if self.m_heroDataList[self.m_playIndex] and self.m_heroDataList[self.m_playIndex].video ~= "" then
          CS.UI.UILuaHelper.PlayTimeline(self.m_heroDataList[self.m_playIndex].video, false, "", handler(self, self.ShowHeroDetailUI))
          self.m_playIndex = self.m_playIndex + 1
        else
          self.m_playIndex = self.m_playIndex + 1
          self:ShowHeroDetailUI()
        end
      end
      
      if quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
        if GachaManager:IsShippedALl() and self.m_ShowSSRVideoFlag == false then
          ShowHeroFun()
        else
          GachaManager:SetSkippedHeroShow(GachaManager:IsShippedALl())
          self.m_ShowSSRVideoFlag = false
          CS.UI.UILuaHelper.PlayFromAddRes("Gacha_SSR_show", "", true, handler(self, ShowHeroFun), CS.UnityEngine.ScaleMode.ScaleToFit, false)
          GlobalManagerIns:TriggerWwiseBGMState(88)
        end
      else
        ShowHeroFun()
      end
    else
      self.m_playIndex = self.m_playIndex + 1
      self:PlayHeroVideo()
    end
  else
    self:OnTimelinePlayFinish()
  end
end

function Form_GachaShow:IsHaveSSRHero(heroList)
  local flag = false
  if table.getn(heroList) > 0 then
    for i, v in pairs(heroList) do
      if v.heroId then
        local quality = HeroManager:GetHeroQualityById(v.heroId)
        if quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
          flag = true
          return flag
        end
      end
    end
  end
  return flag
end

function Form_GachaShow:IsSSRHero(heroId)
  local flag = false
  if heroId then
    local quality = HeroManager:GetHeroQualityById(heroId)
    if quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
      flag = true
      return flag
    end
  end
  return flag
end

function Form_GachaShow:ShowNewHero()
  local data = self:CheckNextNewHero(self.m_playIndex)
  if data then
    if data.video ~= "" then
      local function showDetailFun()
        self:ShowNewHeroDetailUI(data)
      end
      
      CS.UI.UILuaHelper.PlayTimeline(data.video, false, "", showDetailFun)
    else
      self:ShowNewHeroDetailUI(data)
    end
  else
    self:OnTimelinePlayFinish()
  end
end

function Form_GachaShow:ShowNewHeroDetailUI(data)
  local isWish = GachaManager:CheckIsWishHero(self.m_param.iGachaId, data.heroId)
  local bgmId = self:IsSSRHero(data.heroId) == true and 51 or 45
  StackPopup:Push(UIDefines.ID_FORM_HEROSHOW, {
    heroID = data.heroId,
    isGacha = true,
    isNew = true,
    wishFlag = isWish,
    bgmId = bgmId,
    closeCallBack = function()
      self:ShowNewHero()
    end
  })
end

function Form_GachaShow:CheckNextNewHero(startIndex)
  for i = startIndex, #self.m_heroDataList do
    if self.m_newHeroList[i] then
      self.m_playIndex = i + 1
      return self.m_heroDataList[i]
    end
  end
end

function Form_GachaShow:OnTimelinePlayFinish()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GACHA10)
  if self.m_csui.m_param and self.m_csui.m_param.param then
    StackFlow:Push(UIDefines.ID_FORM_GACHA10, self.m_csui.m_param.param)
  else
    log.error("Form_GachaShow OnTimelinePlayFinish  gacha have unknown error")
  end
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GACHASHOW)
end

function Form_GachaShow:IsFullScreen()
  return true
end

function Form_GachaShow:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GachaShow", Form_GachaShow)
return Form_GachaShow
