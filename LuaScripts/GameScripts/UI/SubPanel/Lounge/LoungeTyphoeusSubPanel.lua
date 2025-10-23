local UISubPanelBase = require("UI/Common/UISubPanelBase")
local LoungeFavorability = require("UI/SubPanel/Lounge/LoungeFavorability")
local LoungeCharacterTyphoeus = require("UI/SubPanel/Lounge/LoungeCharacterBase")
local LoungeTyphoeusSubPanel = class("LoungeTyphoeusSubPanel", UISubPanelBase)

function LoungeTyphoeusSubPanel:OnInit()
  self._buttonEx = self.m_btn_contract:GetComponent("ButtonExtensions")
  if self._buttonEx then
    self._buttonEx.Down = handler(self, self.onBitePressDown)
    self._buttonEx.Up = handler(self, self.onBitePressUp)
  end
  self._biteFX = self.m_fx_bite:GetComponent("SkeletonGraphic")
  
  function self._animationCallback(entry)
    self:onFxAnimationComplete(entry.Animation.name)
  end
  
  self._biteFX.AnimationState:Complete("+", self._animationCallback)
  self._favorability = LoungeFavorability.new(100)
  self:setFavorabilityUI(0, false)
end

function LoungeTyphoeusSubPanel:onFxAnimationComplete(animationName)
  if animationName == "bite_climax" then
    self:hideBiteFx()
  end
end

function LoungeTyphoeusSubPanel:showBiteFx()
  if self._biteFX then
    UILuaHelper.SetActive(self._biteFX, true)
    self._biteFX.AnimationState:SetAnimation(0, "bite_focus", false)
    self._biteFX.AnimationState:AddAnimation(0, "bite_idle_01", true, 0)
  end
end

function LoungeTyphoeusSubPanel:showBite()
  if self._biteFX then
    self._biteFX.AnimationState:SetAnimation(0, "bite_climax", false)
  end
  GlobalManagerIns:TriggerWwiseBGMState(397)
end

function LoungeTyphoeusSubPanel:hideBiteFx()
  if self._biteFX then
    UILuaHelper.SetActive(self._biteFX, false)
  end
end

function LoungeTyphoeusSubPanel:updateCharacterOrder(parentCanvas)
  local orderInLayer = parentCanvas.sortingOrder - 1
  self._renderer.sortingOrder = orderInLayer
end

function LoungeTyphoeusSubPanel:OnActive()
  self:ShowTargetTextByStr(0)
  self.m_curLoungeHeroId = LoungeManager.m_curLoungeHeroId
  local rootTrans = self.m_parentLua.m_csui.m_uiGameObject.transform
  self.parentCanvas = rootTrans:GetComponent("Canvas")
  self:hideBiteFx()
  self:showBiteButton(false)
  self:SetupRaycaster(self.parentCanvas)
  self:AddEventListeners()
  GlobalManagerIns:TriggerWwiseBGMState(439)
  self:LoadHero()
end

function LoungeTyphoeusSubPanel:OnInactive()
  if self._guidePointTimer then
    TimeService:KillTimer(self._guidePointTimer)
    self._guidePointTimer = nil
  end
  self:KillTimer()
  self:HideTargetPanel()
  GlobalManagerIns:TriggerWwiseBGMState(386)
  self:RemoveEventListeners()
  self:RemoveRaycaster()
  self:UnloadHero()
end

function LoungeTyphoeusSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Lounge_Upgrade_Inactive", handler(self, self.resumeTargetShow))
end

function LoungeTyphoeusSubPanel:RemoveEventListeners()
  self:clearEventListener()
end

function LoungeTyphoeusSubPanel:resumeTargetShow()
  if self.pausedTargetInfo then
    self:ShowTargetTextByStr(self.pausedTargetInfo.targetId, self.pausedTargetInfo.popup)
    self.pausedTargetInfo = nil
  end
end

function LoungeTyphoeusSubPanel:RefreshUI()
end

function LoungeTyphoeusSubPanel:OnDestroy()
  self._beatSfx = nil
  if self._biteFX then
    self._biteFX.AnimationState:Complete("-", self._animationCallback)
  end
  self._character = nil
  self._buttonEx = nil
  self:UnloadHero()
  self:KillTimer()
  self.super.OnDestroy(self)
end

function LoungeTyphoeusSubPanel:SetupRaycaster(canvas)
  if canvas.worldCamera then
    self._raycaster = canvas.worldCamera.gameObject:AddComponent(typeof(CS.UnityEngine.EventSystems.Physics2DRaycaster))
  end
end

function LoungeTyphoeusSubPanel:RemoveRaycaster()
  if self._raycaster then
    CS.UnityEngine.Object.Destroy(self._raycaster)
    self._raycaster = nil
  end
end

function LoungeTyphoeusSubPanel:showSubtitle(param1, param2)
  local voices = string.split(param2, ";")
  if voices and 1 < #voices then
    local voice = voices[1]
    if ChannelManager:IsChinaChannel() then
      voice = voices[2] or ""
    end
    self:ShowPlotTextByStr(param1, voice)
    return
  else
    self:ShowPlotTextByStr(param1, param2)
  end
end

function LoungeTyphoeusSubPanel:showBiteButton(show)
  if show then
    UILuaHelper.SetActive(self.m_pnl_right, true)
  else
    UILuaHelper.SetActive(self.m_pnl_right, false)
  end
end

function LoungeTyphoeusSubPanel:biteStart()
  self:showBiteFx()
end

function LoungeTyphoeusSubPanel:bite()
  self:showBite()
end

function LoungeTyphoeusSubPanel:biteEnd()
  self:hideBiteFx()
end

function LoungeTyphoeusSubPanel:showTarget(targetId, popup)
  self:showTarget(targetId, popup)
end

function LoungeTyphoeusSubPanel:setGuidePoints(guidePoints)
  self._guidePoints = guidePoints
end

function LoungeTyphoeusSubPanel:onBitePressDown()
  if self._luaCharacter and self._luaCharacter.bitePressed then
    self._luaCharacter:bitePressed()
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "Lounge_Common_ScreenShakes")
  GlobalManagerIns:TriggerWwiseBGMState(396)
end

function LoungeTyphoeusSubPanel:onBitePressUp()
  if self._luaCharacter and self._luaCharacter.biteReleased then
    self._luaCharacter:biteReleased()
  end
  if self.m_parentLua then
    UILuaHelper.StopAnimation(self.m_rootObj, "Lounge_Common_ScreenShakes")
    UILuaHelper.ResetAnimationByName(self.m_rootObj, "Lounge_Common_ScreenShakes")
  end
  GlobalManagerIns:TriggerWwiseBGMState(398)
end

function LoungeTyphoeusSubPanel:IsFullScreen()
  return true
end

function LoungeTyphoeusSubPanel:LoadHero()
  local cfg = LoungeManager:GetLoungeCharCfgById(self.m_curLoungeHeroId)
  if cfg then
    local spineName = cfg.m_SpineName
    self._heroResourceName = spineName
    if spineName and spineName ~= "" then
      do
        local function callBack(gameObject)
          self._heroPath = spineName
          
          self:OnHeroLoaded(gameObject)
        end
        
        ResourceUtil:CreateUIPrefab(spineName, self.m_root_hero, callBack)
      end
    end
  end
end

function LoungeTyphoeusSubPanel:OnHeroLoaded(heroGameObject)
  self:UnloadHero()
  self._heroObject = heroGameObject
  UILuaHelper.SetActive(self._heroObject, true)
  self._character = self.m_root_hero:GetComponentInChildren(typeof(CS.Plugins.Common.LoungeCharacter))
  self._character:Initialize()
  self._renderer = self._character:GetComponent("Renderer")
  self:updateCharacterOrder(self.parentCanvas)
  self._luaCharacter = LoungeCharacterTyphoeus.new()
  self._luaCharacter:init(self.m_curLoungeHeroId, self._character, self)
  self:restoreState()
  self:resetGuidePointTimer()
end

function LoungeTyphoeusSubPanel:UnloadHero()
  self._character = nil
  if self._luaCharacter then
    self._luaCharacter:dispose()
    self._luaCharacter = nil
  end
  if self._heroObject then
    ResourceUtil:DestroyAndUnloadUIPrefab(self._heroObject, self._heroPath)
    self._heroObject = nil
  end
end

function LoungeTyphoeusSubPanel:restoreState()
  self:showBiteButton(false)
  self:hideBiteFx()
  if self._luaCharacter then
    self._luaCharacter:restoreState()
  end
end

function LoungeTyphoeusSubPanel:ShowPlotTextByStr(str, voice)
  self.m_parentLua:ShowPlotTextByStr(str, voice)
end

function LoungeTyphoeusSubPanel:ShowPlotPanel()
  if utils.isNull(self.m_pnl_dialogue) then
    return
  end
  if self.m_showPlotTimer then
    TimeService:KillTimer(self.m_showPlotTimer)
    self.m_showPlotTimer = nil
  end
  self.m_showPlotTimer = TimeService:SetTimer(0.1, 1, function()
    self.m_showPlotTimer = nil
    if not utils.isNull(self.m_pnl_dialogue) then
      UILuaHelper.SetActive(self.m_pnl_dialogue, true)
    end
  end)
end

function LoungeTyphoeusSubPanel:canTargetPopup()
  if LoungeManager:GetLoungeHeroRealStatus(self.m_curLoungeHeroId) ~= LoungeManager.LoungeBondStatus.Bond then
    return false
  end
  return true
end

function LoungeTyphoeusSubPanel:showTarget(targetId, popup)
  if not self:canTargetPopup() then
    self.pausedTargetInfo = {targetId = targetId, popup = popup}
    return
  end
  self.pausedTargetInfo = nil
  self:ShowTargetTextByStr(targetId, popup)
end

function LoungeTyphoeusSubPanel:ShowTargetPanel()
  if utils.isNull(self.m_pnl_targettips) then
    return
  end
  if self.m_showTargetTimer then
    TimeService:KillTimer(self.m_showTargetTimer)
    self.m_showTargetTimer = nil
  end
  UILuaHelper.SetActive(self.m_pnl_targettips, false)
  UILuaHelper.SetActive(self.m_pnl_taggetpop, true)
  UILuaHelper.PlayAnimationByName(self.m_ui_panel, "Lounge_m_ui_panel_in")
  self.m_showTargetTimer = TimeService:SetTimer(3, 1, function()
    self.m_showTargetTimer = nil
    if self and not utils.isNull(self.m_pnl_targettips) then
      UILuaHelper.PlayAnimationByName(self.m_ui_panel, "Lounge_m_ui_panel_out")
      UILuaHelper.PlayAnimationByName(self.m_saoguang, "Lounge_m_ui_panel_saoguang")
      UILuaHelper.SetActive(self.m_pnl_taggetpop, false)
      UILuaHelper.SetActive(self.m_pnl_targettips, true)
    end
  end)
end

function LoungeTyphoeusSubPanel:HideTargetPanel()
  if not utils.isNull(self.m_pnl_targettips) then
    UILuaHelper.SetActive(self.m_pnl_targettips, false)
  end
  if not utils.isNull(self.m_pnl_taggetpop) then
    UILuaHelper.SetActive(self.m_pnl_taggetpop, false)
  end
  UILuaHelper.SetActive(self.m_saoguang, false)
end

function LoungeTyphoeusSubPanel:ShowTargetTextByStr(commonTextId, popup)
  self:KillTimer()
  if commonTextId and commonTextId ~= 0 then
    if popup then
      self:ShowTargetPanel()
      self.m_txt_taggetpop_Text.text = ConfigManager:GetCommonTextById(commonTextId)
      self.m_txt_targettips_Text.text = ConfigManager:GetCommonTextById(commonTextId)
    else
      UILuaHelper.SetActive(self.m_pnl_targettips, true)
      UILuaHelper.SetActive(self.m_pnl_taggetpop, false)
      self.m_txt_targettips_Text.text = ConfigManager:GetCommonTextById(commonTextId)
      UILuaHelper.SetActive(self.m_saoguang, true)
      UILuaHelper.PlayAnimationByName(self.m_saoguang, "Lounge_m_ui_panel_saoguang")
      UILuaHelper.StopAnimation(self.m_ui_panel)
      UILuaHelper.SetCanvasGroupAlpha(self.m_pnl_targettips, 1.0)
    end
  else
    self:HideTargetPanel()
  end
end

function LoungeTyphoeusSubPanel:KillTimer()
  if self.m_showTargetTimer then
    TimeService:KillTimer(self.m_showTargetTimer)
    self.m_showTargetTimer = nil
  end
end

function LoungeTyphoeusSubPanel:ResetGame()
  self:hideBiteFx()
  self:showBiteButton(false)
  if self._luaCharacter then
    self._luaCharacter:reset()
  end
  self:updateBeatSfx(0)
end

function LoungeTyphoeusSubPanel:ShowGuide()
  if self._guidePoints == nil or #self._guidePoints == 0 then
    return
  end
  self:resetGuidePointTimer()
  StackPopup:Push(UIDefines.ID_FORM_LOUNGEGUIDE_TYPHOEUS, self._guidePoints)
end

function LoungeTyphoeusSubPanel:updateBeatSfx(percent)
  local state = math.floor(percent * 2)
  if self._beatSfx ~= state then
    self:playBeatSfx(state)
    self._beatSfx = state
  end
end

function LoungeTyphoeusSubPanel:playBeatSfx(state)
  if state == 0 then
    UILuaHelper.StartPlaySFX("Play_ui_restroom_20730_heartbeat_s", nil, nil, nil)
  elseif state == 1 then
    UILuaHelper.StartPlaySFX("Play_ui_restroom_20730_heartbeat_m", nil, nil, nil)
  elseif state == 2 then
    UILuaHelper.StartPlaySFX("Play_ui_restroom_20730_heartbeat_f", nil, nil, nil)
  end
end

function LoungeTyphoeusSubPanel:setFavorabilityUI(percent, playEffect)
  if playEffect then
    local particleSystem = self.m_img_heart2:GetComponent("ParticleSystem")
    particleSystem:Stop()
    particleSystem:Play()
    UILuaHelper.StartPlaySFX("Play_ui_restroom_20730_affinityup", nil, nil, nil)
    DOTweenModuleUI.DOFillAmount(self.m_img_progress1_Image, percent, 0.2)
  else
    self.m_img_progress1_Image.fillAmount = percent
  end
  if percent < 0.5 then
    UILuaHelper.SetActive(self.m_img_bg_heartgrey, true)
    UILuaHelper.SetActive(self.m_img_bg_heartlight, false)
    UILuaHelper.SetActive(self.m_img_bg_heartfullgrey, true)
    UILuaHelper.SetActive(self.m_img_bg_heartfull, false)
    self:setBeatSpeed(1.0)
  end
  if 0.5 <= percent then
    UILuaHelper.SetActive(self.m_img_bg_heartgrey, false)
    UILuaHelper.SetActive(self.m_img_bg_heartlight, true)
    self:setBeatSpeed(2.0)
  end
  if 1 <= percent then
    UILuaHelper.SetActive(self.m_img_bg_heartfullgrey, false)
    UILuaHelper.SetActive(self.m_img_bg_heartfull, true)
    self:setBeatSpeed(3.0)
  end
  if playEffect then
    self:updateBeatSfx(percent)
  end
end

function LoungeTyphoeusSubPanel:setBeatSpeed(speed)
  local particleSystem = self.m_img_heart_beat:GetComponent("ParticleSystem")
  if particleSystem then
    particleSystem.main.simulationSpeed = speed
  end
  self.m_img_bg_heart2_Image.material:SetVector("_MaintexUVSpeed", CS.UnityEngine.Vector4(-0.1 * speed, 0, 0, 0))
  self.m_img_bg_heart2_Image.material:SetFloat("_Masktex02USpeed", -0.2 * speed)
  self.m_img_bg_heart3_Image.material:SetVector("_MaintexUVSpeed", CS.UnityEngine.Vector4(-0.1 * speed, 0, 0, 0))
  self.m_img_bg_heart3_Image.material:SetFloat("_Masktex02USpeed", -0.2 * speed)
end

function LoungeTyphoeusSubPanel:resetGuidePointTimer()
  if self._guidePointTimer then
    TimeService:KillTimer(self._guidePointTimer)
    self._guidePointTimer = nil
  end
  self._guidePointTimer = TimeService:SetTimer(20, 1, function()
    self:ShowGuide()
  end)
end

return LoungeTyphoeusSubPanel
