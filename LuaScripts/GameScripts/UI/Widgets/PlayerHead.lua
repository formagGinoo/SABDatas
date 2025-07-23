local PlayerHead = class("PlayerHead")

function PlayerHead:ctor(goRoot)
  self.m_objRoot = goRoot
  self.m_goRootTrans = goRoot.transform
  self.m_headID = nil
  self.m_headFrameID = nil
  self.m_headFrameExpireTime = nil
  self.m_playerHeadClickBackFun = nil
  self.m_isNotClk = false
  self.m_headFrameEftStr = nil
  self.m_headFrameEftObj = nil
  self:InitComponents()
end

function PlayerHead:InitComponents()
  if not self.m_goRootTrans then
    return
  end
  local imgHeadTrans = self.m_goRootTrans:Find("pnl_head_mask/c_img_head")
  if imgHeadTrans then
    self.m_img_head = imgHeadTrans:GetComponent("CircleImage")
  end
  local imgHeadFrameTrans = self.m_goRootTrans:Find("c_img_head_circle")
  if imgHeadFrameTrans then
    self.m_img_head_frame_trans = imgHeadFrameTrans
    self.m_img_head_frame = imgHeadFrameTrans:GetComponent(T_Image)
  end
  local lvNode = self.m_goRootTrans:Find("bg_lv")
  if lvNode then
    self.m_lvNode = lvNode
  end
  local txtLvTrans = self.m_goRootTrans:Find("bg_lv/c_txt_lv")
  if txtLvTrans then
    self.m_txt_lv = txtLvTrans:GetComponent(T_TextMeshProUGUI)
  end
  local btnNode = self.m_goRootTrans:Find("btn_head")
  if btnNode then
    self.m_btnPlayerHead = btnNode:GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(self, self.m_btnPlayerHead, function()
      self:OnPlayerHeadClick()
    end)
    self.m_playerHeadClickBackFun = nil
  end
  self.m_stRoleId = nil
end

function PlayerHead:SetPlayerHeadInfo(params)
  if not params or not params.iHeadId then
    log.error("SetPlayerHeadInfo error params is null")
    return
  end
  self.m_headID = params.iHeadId
  self.m_headFrameID = params.iHeadFrameId
  self.m_headFrameExpireTime = params.iHeadFrameExpireTime or 0
  self.m_stRoleId = params.stRoleId
  self:FreshHeadShow()
  self:FreshHeadFrameShow()
  self:FreshLvNode(params.iLevel)
end

function PlayerHead:SetPlayerHeadClickBackFun(clickBackFun)
  if not clickBackFun then
    return
  end
  self.m_playerHeadClickBackFun = clickBackFun
end

function PlayerHead:SetStopClkStatus(isNotClk)
  self.m_isNotClk = isNotClk
end

function PlayerHead:GetHeadID()
  local tempHeadID = self.m_headID
  if tempHeadID == nil or tempHeadID == 0 then
    tempHeadID = RoleManager:GetDefaultHeadID()
  end
  return tempHeadID
end

function PlayerHead:FreshLvNode(lv)
  if not self.m_lvNode then
    return
  end
  UILuaHelper.SetActive(self.m_lvNode, lv ~= nil)
  if lv and self.m_txt_lv then
    self.m_txt_lv.text = lv
  end
end

function PlayerHead:FreshHeadShow()
  if not self.m_img_head then
    return
  end
  local headID = self:GetHeadID()
  local roleHeadCfg = RoleManager:GetPlayerHeadCfg(headID)
  if not roleHeadCfg then
    return
  end
  UILuaHelper.SetBaseImageAtlasSprite(self.m_img_head, roleHeadCfg.m_HeadPic)
end

function PlayerHead:FreshHeadFrameShow()
  if not self.m_img_head_frame then
    return
  end
  local headFrameID = RoleManager:GetHeadFrameIDByIDAndExpireTime(self.m_headFrameID, self.m_headFrameExpireTime)
  local roleHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(headFrameID)
  if not roleHeadFrameCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_head_frame, roleHeadFrameCfg.m_HeadFramePic, function()
    if not UILuaHelper.IsNull(self.m_img_head_frame) then
      UILuaHelper.SetNativeSize(self.m_img_head_frame)
    end
  end)
  if roleHeadFrameCfg.m_HeadFrameEft and roleHeadFrameCfg.m_HeadFrameEft ~= "" then
    utils.TryLoadUIPrefabInParent(self.m_img_head_frame_trans, roleHeadFrameCfg.m_HeadFrameEft, function(nameStr, gameObject)
      self.m_headFrameEftStr = nameStr
      self.m_headFrameEftObj = gameObject
      self:FreshShowLeftHeadFrameChild()
    end)
  else
    UILuaHelper.SetActiveChildren(self.m_img_head_frame_trans, false)
  end
end

function PlayerHead:FreshShowLeftHeadFrameChild()
  local headFrameID = RoleManager:GetHeadFrameIDByIDAndExpireTime(self.m_headFrameID, self.m_headFrameExpireTime)
  local playerHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(headFrameID)
  if not playerHeadFrameCfg then
    return
  end
  UILuaHelper.SetActiveChildren(self.m_img_head_frame_trans, false)
  if playerHeadFrameCfg.m_HeadFrameEft then
    local subNode = self.m_img_head_frame_trans:Find(playerHeadFrameCfg.m_HeadFrameEft)
    if subNode then
      UILuaHelper.SetActive(subNode, true)
    end
  end
end

function PlayerHead:OnPlayerHeadClick()
  if self.m_isNotClk then
    return
  end
  if self.m_playerHeadClickBackFun then
    self.m_playerHeadClickBackFun()
  elseif self.m_stRoleId then
    local tempStRoleID = self.m_stRoleId
    StackPopup:Push(UIDefines.ID_FORM_PERSONALCARD, {
      zoneID = tempStRoleID.iZoneId,
      otherRoleID = tempStRoleID.iUid
    })
  end
end

function PlayerHead:CheckRecycleFrameEftNode()
  if self.m_headFrameEftStr and self.m_headFrameEftObj then
    utils.RecycleInParentUIPrefab(self.m_headFrameEftStr, self.m_headFrameEftObj)
  end
  self.m_headFrameEftStr = nil
  self.m_headFrameEftObj = nil
end

function PlayerHead:OnDestroy()
  self:CheckRecycleFrameEftNode()
end

return PlayerHead
