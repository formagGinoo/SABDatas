local UISubPanelBase = require("UI/SubPanel/LevelDetailLamiaSubPanel")
local LevelDetailDalcaroSubPanel = class("LevelDetailDalcaroSubPanel", UISubPanelBase)
local EnterAnimStr = "Dalcaro_dialoguedetial_in"
local OutAnimStr = "Dalcaro_dialoguedetial_out"

function LevelDetailDalcaroSubPanel:ConfirmJumpShop()
  if self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel then
    return
  end
  local costItemNameStr = self:GetCostItemNameStr()
  StackTop:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_COMMONTIPS, {
    tipsID = 3001,
    bLockBack = true,
    fContentCB = function(sContent)
      return string.CS_Format(sContent, costItemNameStr)
    end,
    func1 = function()
      local jumpIns = ConfigManager:GetConfigInsByName("Jump")
      local jump_item = jumpIns:GetValue_ByJumpID(self.m_mainInfoCfg.m_ShopJumpID)
      local windowId = jump_item.m_WindowID
      local shop_list = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Activity)
      local shop_id
      for i, v in ipairs(shop_list) do
        if v.m_WindowID == windowId then
          shop_id = v.m_ShopID
        end
      end
      local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
        id = self.m_activityID,
        shop_id = shop_id
      })
      if is_corved and not TimeUtil:IsInTime(t1, t2) then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
        return
      end
      ShopManager:ReqGetShopData(shop_id)
    end
  })
end

function LevelDetailDalcaroSubPanel:OnBtnbattleClicked()
  if not self.m_curLevelID then
    return
  end
  if not self.m_levelCfg then
    return
  end
  local heroModify = self.m_levelCfg.m_HeroModify
  if heroModify == 0 then
    local power = HeroManager:GetTopFiveHeroPower()
    if power < self.m_levelCfg.m_RecoEfficencyType then
      StackTop:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_COMMONTIPS, {
        tipsID = 1226,
        func1 = function()
          BattleFlowManager:StartEnterBattle(self.m_levelType, self.m_activityID, self.m_curLevelID)
        end
      })
      return
    end
  end
  BattleFlowManager:StartEnterBattle(self.m_levelType, self.m_activityID, self.m_curLevelID)
end

function LevelDetailDalcaroSubPanel:OnBtnbuffheroClicked()
  if not self.m_curLevelID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function LevelDetailDalcaroSubPanel:OnBtnchallengebuffheroClicked()
  if not self.m_curLevelID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_CHALLENGEHERO, {
    activityID = self.m_activityID
  })
end

function LevelDetailDalcaroSubPanel:OnBtnquickClicked()
  if not self.m_curLevelID then
    return
  end
  local isHaveEnough, totalTimes = self:IsHaveEnoughTimes()
  if isHaveEnough ~= true then
    return
  end
  local isChallenge = self.m_actSubType == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if totalTimes <= 1 or isChallenge then
    LevelHeroLamiaActivityManager:ReqLamiaStageSweep(self.m_activityID, self.m_curLevelID, 1)
  else
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_DIALOGUEFASTPASS, {
      activityID = self.m_activityID,
      subActivityID = self.m_subActivityID,
      levelID = self.m_curLevelID
    })
  end
end

function LevelDetailDalcaroSubPanel:CheckShowAnimOut(endFun)
  if self.m_detailOutTimer ~= nil then
    return
  end
  local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_level_panel_detail, OutAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, OutAnimStr)
  if endFun then
    endFun()
  end
  self.m_detailOutTimer = TimeService:SetTimer(detailAnimLen, 1, function()
    self.m_detailOutTimer = nil
  end)
end

return LevelDetailDalcaroSubPanel
