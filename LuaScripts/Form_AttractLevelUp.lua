local Form_AttractLevelUp = class("Form_AttractLevelUp", require("UI/UIFrames/Form_AttractLevelUpUI"))
local AttractAddCfgIns = ConfigManager:GetConfigInsByName("AttractAdd")
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local HeroTagCfg = {Attract = 1}
local ShowTabHeroPos = {
  [HeroTagCfg.Attract] = {
    isMaskAndGray = false,
    position = {
      -300,
      0,
      0
    },
    scale = {
      1,
      1,
      1
    },
    posTime = 0.01,
    scaleTime = 0.1,
    posTween = nil,
    scaleTween = nil
  }
}

function Form_AttractLevelUp:SetInitParam(param)
end

function Form_AttractLevelUp:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_AttractLevelUp:OnActive()
  self.super.OnActive(self)
  self:InitView()
end

function Form_AttractLevelUp:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
  if self.callback then
    self.callback()
    self.callback = nil
  end
end

function Form_AttractLevelUp:InitView()
  local tParam = self.m_csui.m_param
  self.m_curShowHeroData = tParam.curShowHeroData
  self.m_oldRank = tParam.iOldRank
  self.m_newRank = not tParam.iNewRank and self.m_curShowHeroData and self.m_curShowHeroData.serverData.iAttractRank
  self.callback = tParam.callback
  self.m_csui.m_param = nil
  self.m_txt_lv_after_num_Text.text = self.m_newRank
  self.m_delayTime = 0.2
  self.m_cachedEffect = {}
  self:FreshAttrInfo()
  self:FreshHeroSpine()
end

function Form_AttractLevelUp:FreshAttrInfo()
  local iAttractAddTemplate = self.m_curShowHeroData.characterCfg.m_AttractAddTemplate
  local iPropertyID = AttractAddCfgIns:GetValue_ByAttractAddTemplateIDAndRankID(iAttractAddTemplate, self.m_oldRank).m_PropertyID
  local oldAttrInfoList = AttractManager:GetBaseAttr(iPropertyID)
  iPropertyID = AttractAddCfgIns:GetValue_ByAttractAddTemplateIDAndRankID(iAttractAddTemplate, self.m_newRank).m_PropertyID
  local newAttrInfoList = AttractManager:GetBaseAttr(iPropertyID)
  local scrollData = {}
  for k, v in ipairs(newAttrInfoList) do
    scrollData[#scrollData + 1] = {
      title = v.cfg.m_mCNName,
      newAttr = v,
      oldAttr = oldAttrInfoList[k]
    }
  end
  self.m_numOfAttr = #scrollData
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_attr_scrollView
    local params = {
      show_data = scrollData,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateAttrCell(index, cell_object, cell_data)
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(scrollData)
  end
end

local CellDelayTime = 0.1

function Form_AttractLevelUp:updateAttrCell(index, cell_object, cell_data)
  if not self.m_cachedEffect["attr_" .. index] and self.m_delayTime > 0 then
    self.m_cachedEffect["attr_" .. index] = true
    local delayTime = 0
    if 4 < index then
      delayTime = 0
    else
      delayTime = self.m_delayTime
    end
    self.m_delayTime = self.m_delayTime + CellDelayTime
    if delayTime == 0 then
      cell_object:SetActive(true)
      UILuaHelper.PlayAnimationByName(cell_object, "img_bg_ability_in")
      if index == 4 and index < self.m_numOfAttr then
        TimeService:SetTimer(CellDelayTime, 1, function()
          self.m_unlock_scroll_view.m_scroll_rect.content:DOLocalMoveY(1, (self.m_numOfAttr - 4) * CellDelayTime)
        end)
      end
    else
      TimeService:SetTimer(delayTime, 1, function()
        cell_object:SetActive(true)
        UILuaHelper.PlayAnimationByName(cell_object, "img_bg_ability_in")
        if index == 4 and index < self.m_numOfAttr then
          TimeService:SetTimer(CellDelayTime, 1, function()
            self.m_unlock_scroll_view.m_scroll_rect.content:DOLocalMoveY(1, (self.m_numOfAttr - 4) * CellDelayTime)
          end)
        end
      end)
      cell_object:SetActive(false)
    end
  else
    cell_object:SetActive(true)
  end
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_Ability", cell_data.title)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_before_num", cell_data.oldAttr and cell_data.oldAttr.num or 0)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_after_num", cell_data.newAttr.num)
end

function Form_AttractLevelUp:FreshHeroSpine()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  if heroCfg.m_HeroID == 0 then
    return
  end
  self:ShowHeroSpine(heroCfg.m_Spine)
end

function Form_AttractLevelUp:ShowHeroSpine(heroSpinePathStr)
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.HeroDetail
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_hero_root, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    self:OnLoadSpineBack()
  end)
end

function Form_AttractLevelUp:CheckRecycleSpine(isNeedResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isNeedResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_AttractLevelUp:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  self.m_spineDitherExtension = self.m_curHeroSpineObj.spineTrans:GetComponent("SpineDitherExtension")
  if self.m_dragEndTimer then
    local leftTime = TimeService:GetTimerLeftTime(self.m_dragEndTimer)
    if leftTime and 0 < leftTime then
      self.m_spineDitherExtension:SetToDither(1.0, 0.0, leftTime)
    else
      self.m_spineDitherExtension:StopToDither(true)
    end
  else
    self.m_spineDitherExtension:StopToDither(true)
  end
  self:FreshShowSpineMaskAndGray()
end

function Form_AttractLevelUp:FreshShowSpineMaskAndGray()
  local tempTabSpinCfg = ShowTabHeroPos[HeroTagCfg.Attract]
  if not tempTabSpinCfg then
    return
  end
  local isMaskAndGray = tempTabSpinCfg.isMaskAndGray
  if self.m_spineDitherExtension and not UILuaHelper.IsNull(self.m_spineDitherExtension) and isMaskAndGray ~= nil then
    self.m_spineDitherExtension:SetSpineMaskAndGray(isMaskAndGray)
    if self.m_curHeroSpineObj then
      local spineObj = self.m_curHeroSpineObj.spineObj
      if spineObj then
        if isMaskAndGray then
          UILuaHelper.SetSpineTimeScale(spineObj, 0)
        else
          UILuaHelper.SetSpineTimeScale(spineObj, 1)
        end
      end
    end
  end
end

function Form_AttractLevelUp:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_AttractLevelUp:IsFullScreen()
  return false
end

function Form_AttractLevelUp:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_AttractLevelUp", Form_AttractLevelUp)
return Form_AttractLevelUp
