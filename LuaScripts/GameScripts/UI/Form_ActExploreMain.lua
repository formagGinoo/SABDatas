local Form_ActExploreMain = class("Form_ActExploreMain", require("UI/UIFrames/Form_ActExploreMainUI"))

function Form_ActExploreMain:SetInitParam(param)
end

function Form_ActExploreMain:AfterInit()
  self.super.AfterInit(self)
  self.content_node = self.m_csui.m_uiGameObject.transform:Find("content_node").gameObject
  local iconRoot = self.m_pnl_icons.transform
  local childCount = iconRoot.childCount
  self.icons = {}
  for i = 0, childCount - 1 do
    local child = iconRoot:GetChild(i)
    self.icons[child.name] = child.gameObject
    child.gameObject:SetActive(false)
  end
  self.m_pnl_icons:SetActive(true)
  self.bindIcons = {}
  local button = self.m_pnl_click:GetComponent("ButtonExtensions")
  if button then
    button.Clicked = handler(self, self.OnPnlClick)
    button.BeginDrag = handler(self, self.OnStartDrag)
    button.Drag = handler(self, self.OnScreenDrag)
    button.EndDrag = handler(self, self.OnScreenEndDrag)
  end
  self.interactiveFollow = {}
  self.interactiveFollow[1] = self.m_pnl_talk:AddComponent(typeof(CS.UIFollow))
  self.interactiveFollow[2] = self.m_pnl_get:AddComponent(typeof(CS.UIFollow))
  self.interactiveFollow[3] = self.m_pnl_check:AddComponent(typeof(CS.UIFollow))
  self.m_pnl_anounce:SetActive(false)
  self.interactiveTexts = {}
  self.m_Stick:SetActive(false)
  self:RefreshAmountUI()
  self.bIsShow = false
  self.m_pnl_event:SetActive(self.bIsShow)
  self.m_pnl_tipsnew:SetActive(false)
  self:addEventListener("eGameEvent_ActExploreUIReady", handler(self, self.OnUIReady))
  self:SetVisable(false)
end

function Form_ActExploreMain:SetWorld(world)
  self.world = world
  if self.m_Stick then
    local joyStick = self.m_Stick:GetComponent(typeof(CS.FloatingJoyStick))
    joyStick.OnValueChange:RemoveAllListeners()
    joyStick.TransformCamera = CS.UnityEngine.Camera.main
    joyStick.OnValueChange:AddListener(handler(self.world, self.world.OnMoveInput))
  end
end

function Form_ActExploreMain:OnUIReady()
  self:SetVisable(true)
  if self.world ~= nil and self.world.newPickableAdd then
    self.world.newPickableAdd = nil
    self.time1 = TimeService:SetTimer(1, 1, function()
      self.m_pnl_tipsnew:SetActive(true)
      CS.UI.UILuaHelper.PlayAnimationByName(self.m_pnl_tipsnew, nil)
    end)
    self.time2 = TimeService:SetTimer(3, 1, function()
      self.m_pnl_tipsnew:SetActive(false)
    end)
  end
end

function Form_ActExploreMain:SetPickupAmount(amount, count)
  self.pickUpTip = tostring(count) .. "/" .. tostring(amount)
  self:RefreshAmountUI()
end

function Form_ActExploreMain:RefreshAmountUI()
  if self.m_txt_collectnum then
    self.m_txt_collectnum_Text.text = self.pickUpTip or ""
  end
end

function Form_ActExploreMain:OnActive()
  self.super.OnActive(self)
  self.dialogueShowEndHandler = self:addEventListener("eGameEvent_DialogueShowEnd", handler(self, self.OnDialogueShowEnd))
end

function Form_ActExploreMain:OnPnlClick(pointerEventData)
  if self.world ~= nil then
    local isHit, hitPoint = CS.UI.UILuaHelper.RayCastScreenPointToPlane(pointerEventData.position, CS.UnityEngine.Vector3.up, 0)
    if isHit then
      self.world:OnMoveTo(hitPoint)
    end
  end
end

function Form_ActExploreMain:OnDialogueShowEnd()
  self:SetVisable(true)
end

function Form_ActExploreMain:SetVisable(visable)
  if self.content_node then
    self.content_node:SetActive(visable)
  end
  self:broadcastEvent("eGameEvent_ActExploreUIVisuable", visable)
end

function Form_ActExploreMain:OnInactive()
  self.super.OnInactive(self)
  if self.dialogueShowEndHandler ~= nil then
    self:removeEventListener("eGameEvent_DialogueShowEnd", self.dialogueShowEndHandler)
    self.dialogueShowEndHandler = nil
  end
end

function Form_ActExploreMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.time1 then
    TimeService:KillTimer(self.time1)
    self.time1 = nil
  end
  if self.time2 then
    TimeService:KillTimer(self.time2)
    self.time2 = nil
  end
end

function Form_ActExploreMain:ShowInteractive(gameObject, id, type)
  self.interactiveId = id
  for k, v in pairs(self.interactiveFollow) do
    if type == k then
      v.gameObject:SetActive(true)
      v.Target = gameObject.transform
    else
      v.gameObject:SetActive(false)
      v.Target = nil
    end
  end
end

function Form_ActExploreMain:SetInteractiveText(gameObject, id, element)
  if self.interactiveTexts[id] ~= nil then
    return
  end
  local instance = CS.UnityEngine.Object.Instantiate(self.m_pnl_anounce, self.m_pnl_anounce.transform.parent)
  instance:SetActive(true)
  local follow = instance:AddComponent(typeof(CS.UIFollow))
  follow.Target = gameObject.transform
  follow.HeightOffset = element.m_IconHeight
  self.interactiveTexts[id] = instance
  local btn = instance.transform:Find("m_button_announce"):GetComponent(T_Button)
  btn.onClick:AddListener(handler1(self, self.OnTextBtnClick, id))
  local textTitle = instance.transform:Find("pnl_announce/img_mask/img_line1/m_txt_antitle"):GetComponent("TMPPro")
  if textTitle then
    textTitle.text = element.m_mUIText1
  end
  local textContent = instance.transform:Find("pnl_announce/img_mask/img_line1/m_txt_place"):GetComponent("TMPPro")
  if textContent then
    textContent.text = element.m_mUIText2
  end
end

function Form_ActExploreMain:OnTextBtnClick(id)
  if self.world then
    self.world:OnInteractive(id, CS.LogicActExplore.ActExploreInteractType.Icon)
  end
end

function Form_ActExploreMain:OnInteractiveDestroy(id)
  local exist = self.interactiveTexts[id]
  if exist ~= nil then
    self.interactiveTexts[id] = nil
    GameObject.Destroy(exist)
  end
end

function Form_ActExploreMain:SetIcon(gameObject, iconName, heightOffset)
  local instanceID = gameObject:GetInstanceID()
  local exist = self.bindIcons[instanceID]
  if exist ~= nil then
    GameObject.Destroy(exist)
    self.bindIcons[instanceID] = nil
  end
  if iconName == nil or iconName == "" then
    return
  end
  local icon = self.icons[iconName]
  if icon then
    local newIcon = CS.UnityEngine.Object.Instantiate(icon, self.m_pnl_icons.transform)
    newIcon:SetActive(true)
    local follow = newIcon:AddComponent(typeof(CS.UIFollow))
    follow.Target = gameObject.transform
    follow.HeightOffset = heightOffset or 0
    self.bindIcons[instanceID] = newIcon
  end
end

function Form_ActExploreMain:OnBtnInteractiveClicked()
  if self.world and self.interactiveId >= 0 then
    self.world:OnInteractive(self.interactiveId, CS.LogicActExplore.ActExploreInteractType.Button)
  end
end

function Form_ActExploreMain:OnButtongetClicked()
  if self.world and self.interactiveId >= 0 then
    self.world:OnInteractive(self.interactiveId, CS.LogicActExplore.ActExploreInteractType.Button)
  end
end

function Form_ActExploreMain:OnButtontalkClicked()
  if self.world and self.interactiveId >= 0 then
    self.world:OnInteractive(self.interactiveId, CS.LogicActExplore.ActExploreInteractType.Button)
  end
end

function Form_ActExploreMain:OnButtoncheckClicked()
  if self.world and self.interactiveId >= 0 then
    self.world:OnInteractive(self.interactiveId, CS.LogicActExplore.ActExploreInteractType.Button)
  end
end

function Form_ActExploreMain:OnBtnhideClicked()
  self.bIsShow = not self.bIsShow
  self.m_pnl_event:SetActive(self.bIsShow)
  self:broadcastEvent("eGameEvent_ActExploreIconVisuable", not self.bIsShow)
end

function Form_ActExploreMain:OnStartDrag(pointerEventData)
  if self.world ~= nil then
    local isHit, hitPoint = CS.UI.UILuaHelper.RayCastScreenPointToPlane(pointerEventData.position, CS.UnityEngine.Vector3.up, 0)
    if isHit then
      self.startDragPosition = hitPoint
      self.isDragging = false
    end
  end
end

function Form_ActExploreMain:OnScreenDrag(pointerEventData)
  if self.world ~= nil then
    local isHit, hitPoint = CS.UI.UILuaHelper.RayCastScreenPointToPlane(pointerEventData.position, CS.UnityEngine.Vector3.up, 0)
    if isHit then
      local offsetX = hitPoint.x - self.startDragPosition.x
      local offsetZ = hitPoint.z - self.startDragPosition.z
      if not self.isDragging then
        local distance = math.sqrt(offsetX * offsetX + offsetZ * offsetZ)
        if distance < 1 then
          return
        end
        self.isDragging = true
      end
      self.world:OnDragScreen(-offsetX, -offsetZ)
      self.startDragPosition = hitPoint
    end
  end
end

function Form_ActExploreMain:OnScreenEndDrag(pointerEventData)
  if self.world ~= nil and self.startDragPosition ~= nil then
    self.startDragPosition = nil
    self.world:OnDragScreen()
  end
end

function Form_ActExploreMain:IsFullScreen()
  return false
end

ActiveLuaUI("Form_ActExploreMain", Form_ActExploreMain)
return Form_ActExploreMain
