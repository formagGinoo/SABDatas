local UISubPanelBase = require("UI/Common/UISubPanelBase")
local CastleStarUnlockSubPanel = class("CastleStarUnlockSubPanel", UISubPanelBase)
local LineType = {
  long = 1,
  middle = 2,
  short = 3
}

function CastleStarUnlockSubPanel:OnInit()
  self.m_vStarList = {}
  for i = 1, 10 do
    if self["m_btn_details" .. i] == nil then
      break
    end
    local uiPrefabTrans = self["m_btn_details" .. i].transform:Find("ui_castlestar")
    self.m_vStarList[i] = {
      root = uiPrefabTrans.gameObject,
      btn = self["m_btn_details" .. i .. "_Image"],
      starRoot = uiPrefabTrans:Find("c_pnl_stargroup").gameObject,
      dotRoot = uiPrefabTrans:Find("c_pnl_dotgroup").gameObject,
      dotActive = uiPrefabTrans:Find("c_pnl_dotgroup/c_Img_stardotlight").gameObject,
      dotGrey = uiPrefabTrans:Find("c_pnl_dotgroup/c_Img_stardotgrey").gameObject,
      normal = uiPrefabTrans:Find("c_pnl_stargroup/c_img_starnormal").gameObject,
      active = uiPrefabTrans:Find("c_pnl_stargroup/c_img_starlight").gameObject,
      grey = uiPrefabTrans:Find("c_pnl_stargroup/c_img_stargrey").gameObject,
      select = uiPrefabTrans:Find("c_pnl_stargroup/c_img_starselect").gameObject,
      starUnlockEffect = uiPrefabTrans:Find("c_pnl_stargroup/c_img_starlight/m_castlestarmap_unlock").gameObject
    }
  end
  self.m_vLineList = {}
  for i = 1, 9 do
    if self["m_Img_line" .. i] == nil then
      break
    end
    local lineInfo = {}
    local root = self["m_Img_line" .. i]
    lineInfo.root = root
    local rootTrans = self["m_Img_line" .. i].transform
    local lineTrans
    if rootTrans:Find("ui_castlelinelong") ~= nil then
      lineTrans = rootTrans:Find("ui_castlelinelong")
      lineInfo.lineType = LineType.long
      lineInfo.animGrow = "castlelinelong_grow"
      lineInfo.animLoop = "castlelinelong_loop"
      lineInfo.animLength = 0.3
      lineInfo.effectNode = lineTrans:Find("m_castle_starmap_line_2").gameObject
    elseif rootTrans:Find("ui_castlelinemid") ~= nil then
      lineTrans = rootTrans:Find("ui_castlelinemid")
      lineInfo.lineType = LineType.middle
      lineInfo.animGrow = "castlelinemid_grow"
      lineInfo.animLoop = "castlelinemid_loop"
      lineInfo.animLength = 0.3
      lineInfo.effectNode = lineTrans:Find("m_castle_starmap_line_mid").gameObject
    elseif rootTrans:Find("ui_castlelineshort") ~= nil then
      lineTrans = rootTrans:Find("ui_castlelineshort")
      lineInfo.lineType = LineType.short
      lineInfo.animGrow = "castlelineshort_grow"
      lineInfo.animLoop = "castlelineshort_loop"
      lineInfo.animLength = 0.3
      lineInfo.effectNode = lineTrans:Find("m_castle_starmap_line_short").gameObject
    end
    lineInfo.lineRoot = lineTrans.gameObject
    lineInfo.activeLine = lineTrans:Find("c_Img_line/c_Img_linelight").gameObject
    self.m_vLineList[#self.m_vLineList + 1] = lineInfo
  end
  self.m_gray1 = self.m_img_bg_Image.material
  self.m_gray2 = self.m_img_bg1_Image.material
end

function CastleStarUnlockSubPanel:OnFreshData()
  local panelData = self.m_panelData
  self.m_iConstellationID = panelData.iConstellationID
  self.m_iStarID = panelData.iStarID
  local vStarList = StargazingManager:GetAvailableStarList(self.m_iConstellationID)
  self.m_iLastUnlockStarIndex = -1
  for k, v in ipairs(self.m_vStarList) do
    v.starRoot:SetActive(false)
    v.dotRoot:SetActive(true)
    v.starUnlockEffect:SetActive(false)
    v.btn.raycastTarget = false
  end
  for k, v in ipairs(vStarList) do
    local starInfo = StargazingManager:GetStarInfo(self.m_iConstellationID, v)
    if starInfo then
      local starPnl = self.m_vStarList[starInfo.m_Position]
      if starPnl then
        starPnl.btn.raycastTarget = true
        self:FreshStarInfoDetail(starInfo, starPnl)
        self.m_lastStarID = starInfo.m_StarID
        self.m_lastStarPos = starInfo.m_Position
      end
    end
  end
  if self.m_iLastUnlockStarIndex == self.m_lastStarPos then
    self.m_iLastUnlockStarIndex = #self.m_vStarList
  end
  for k, v in ipairs(self.m_vStarList) do
    local pnlLine
    if 1 < k then
      pnlLine = self.m_vLineList[k - 1]
    end
    if k <= self.m_iLastUnlockStarIndex then
      v.dotActive:SetActive(true)
      v.dotGrey:SetActive(false)
      if pnlLine then
        self:FreshLineInfoDetail(pnlLine, true)
      end
    else
      v.dotActive:SetActive(false)
      v.dotGrey:SetActive(true)
      if pnlLine then
        self:FreshLineInfoDetail(pnlLine, false)
      end
    end
  end
  if not StargazingManager:IsConstellationUnlock(self.m_iConstellationID) then
    return
  end
  self.m_img_bg_Image.material = nil
  self.m_img_bg1_Image.material = nil
  self:FreshStarInfo(self.m_iStarID)
end

function CastleStarUnlockSubPanel:FreshStarInfo(iStarID)
  if iStarID == nil then
    if self.m_prevStarIndex ~= nil then
      self.m_vStarList[self.m_prevStarIndex].select:SetActive(false)
    end
    return
  end
  local starIndex = 1
  for k, v in ipairs(self.m_vStarList) do
    if v.iStarID == iStarID then
      starIndex = k
      break
    end
  end
  local starInfo = StargazingManager:GetStarInfo(self.m_iConstellationID, iStarID)
  if starInfo then
    local starPnl = self.m_vStarList[starInfo.m_Position]
    if starPnl then
      self:FreshStarInfoDetail(starInfo, starPnl)
    end
    self:SelectStar(starIndex)
  end
end

function CastleStarUnlockSubPanel:FreshLineInfoDetail(lineInfo, bActivate)
  if bActivate then
    lineInfo.activeLine:SetActive(true)
  else
    lineInfo.activeLine:SetActive(false)
  end
end

function CastleStarUnlockSubPanel:FreshStarInfoDetail(starInfo, starPnl)
  local starID = starInfo.m_StarID
  starPnl.dotRoot:SetActive(false)
  starPnl.starRoot:SetActive(true)
  starPnl.iStarID = starID
  if StargazingManager:IsStarUnAvailable(self.m_iConstellationID, starID) then
    starPnl.normal:SetActive(false)
    starPnl.active:SetActive(false)
    starPnl.grey:SetActive(true)
    starPnl.select:SetActive(false)
  elseif StargazingManager:IsStarUnlock(self.m_iConstellationID, starID) then
    starPnl.normal:SetActive(false)
    starPnl.active:SetActive(true)
    starPnl.grey:SetActive(false)
    starPnl.select:SetActive(false)
    self.m_iLastUnlockStarIndex = starInfo.m_Position
  elseif StargazingManager:IsStarUnlock(self.m_iConstellationID, starInfo.m_FrontStar) then
    starPnl.normal:SetActive(true)
    starPnl.active:SetActive(false)
    starPnl.grey:SetActive(false)
    starPnl.select:SetActive(false)
  else
    starPnl.normal:SetActive(false)
    starPnl.active:SetActive(false)
    starPnl.grey:SetActive(true)
    starPnl.select:SetActive(false)
  end
end

function CastleStarUnlockSubPanel:SelectStar(iStarIndex)
  if self.m_prevStarIndex ~= nil and self.m_vStarList[self.m_prevStarIndex] then
    UILuaHelper.SetActive(self.m_vStarList[self.m_prevStarIndex].select, false)
  end
  if self.m_vStarList[iStarIndex] then
    UILuaHelper.SetActive(self.m_vStarList[iStarIndex].select, true)
  end
  self.m_prevStarIndex = iStarIndex
end

function CastleStarUnlockSubPanel:OnBtndetailsClicked(index)
  local iStarID = self.m_vStarList[index].iStarID
  if iStarID == nil or StargazingManager:IsStarUnAvailable(self.m_iConstellationID, iStarID) then
    return
  end
  self:broadcastEvent("eGameEvent_Stargazing_ChangeStar", self.m_vStarList[index].iStarID)
end

function CastleStarUnlockSubPanel:PlayStarUnlockAnimation(iUnlockStarID, callback)
  if iUnlockStarID ~= nil then
    local starIndex = -1
    local isFullUnlock = false
    if iUnlockStarID == self.m_lastStarID then
      isFullUnlock = true
    end
    for k, v in ipairs(self.m_vStarList) do
      if v.iStarID == iUnlockStarID then
        starIndex = k
        break
      end
    end
    if starIndex ~= -1 then
      do
        local vWait2AnimList = {}
        local count = starIndex
        if isFullUnlock then
          count = #self.m_vStarList
        end
        for i = 1, count do
          if isFullUnlock then
            local pnlLine = self.m_vLineList[i]
            if pnlLine and pnlLine.activeLine.activeSelf == false then
              vWait2AnimList[#vWait2AnimList + 1] = {item = pnlLine, iType = 1}
            end
          elseif 1 < i then
            local pnlLine = self.m_vLineList[i - 1]
            if pnlLine and pnlLine.activeLine.activeSelf == false then
              vWait2AnimList[#vWait2AnimList + 1] = {item = pnlLine, iType = 1}
            end
          end
          local pnlStar = self.m_vStarList[i]
          if pnlStar.iStarID == nil and pnlStar.dotActive.activeSelf == false then
            vWait2AnimList[#vWait2AnimList + 1] = {item = pnlStar, iType = 2}
          end
        end
        local seq = Tweening.DOTween.Sequence()
        seq:AppendInterval(0.5)
        seq:AppendCallback(function()
          for k, v in ipairs(vWait2AnimList) do
            if v.iType == 1 then
              local lineInfo = v.item
              lineInfo.effectNode:SetActive(true)
              UILuaHelper.PlayAnimationByName(lineInfo.lineRoot, lineInfo.animGrow)
              self:FreshLineInfoDetail(lineInfo, true)
            elseif v.iType == 2 then
              local starInfo = v.item
              starInfo.dotActive:SetActive(true)
              starInfo.dotGrey:SetActive(false)
            end
          end
          local pnlItem = self.m_vStarList[starIndex]
          UILuaHelper.PlayAnimationByName(pnlItem.active, "castlestar_unlock")
          CS.GlobalManager.Instance:TriggerWwiseBGMState(136)
          pnlItem.normal:SetActive(false)
          pnlItem.active:SetActive(true)
          pnlItem.grey:SetActive(false)
          pnlItem.select:SetActive(false)
          pnlItem.starUnlockEffect:SetActive(true)
        end)
        seq:AppendInterval(1.0)
        seq:OnComplete(function()
          if callback then
            callback()
          end
        end)
      end
    end
  end
end

function CastleStarUnlockSubPanel:PlayConstellaUnlockAnimation()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "castle_starmap_unlock_common")
  CS.GlobalManager.Instance:TriggerWwiseBGMState(141)
  self.m_img_bg_Image.material = nil
  self.m_img_bg1_Image.material = nil
end

function CastleStarUnlockSubPanel:OnBtndetails1Clicked()
  self:OnBtndetailsClicked(1)
end

function CastleStarUnlockSubPanel:OnBtndetails2Clicked()
  self:OnBtndetailsClicked(2)
end

function CastleStarUnlockSubPanel:OnBtndetails3Clicked()
  self:OnBtndetailsClicked(3)
end

function CastleStarUnlockSubPanel:OnBtndetails4Clicked()
  self:OnBtndetailsClicked(4)
end

function CastleStarUnlockSubPanel:OnBtndetails5Clicked()
  self:OnBtndetailsClicked(5)
end

function CastleStarUnlockSubPanel:OnBtndetails6Clicked()
  self:OnBtndetailsClicked(6)
end

function CastleStarUnlockSubPanel:OnBtndetails7Clicked()
  self:OnBtndetailsClicked(7)
end

function CastleStarUnlockSubPanel:OnBtndetails8Clicked()
  self:OnBtndetailsClicked(8)
end

function CastleStarUnlockSubPanel:OnBtndetail9Clicked()
  self:OnBtndetailsClicked(9)
end

function CastleStarUnlockSubPanel:OnBtndetails10Clicked()
  self:OnBtndetailsClicked(10)
end

return CastleStarUnlockSubPanel
