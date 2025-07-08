local BackButton = class("BackButton")

function BackButton:ctor(goRoot, fBackCB, sTitle, fBackHomeCB, explainID, explainCB)
  self.m_goRoot = goRoot
  self.m_fBackCB = fBackCB
  self.m_fBackHomeCB = fBackHomeCB
  self.m_explainID = explainID
  self.m_explainCB = explainCB
  UILuaHelper.BindViewObjectsManual(self, self.m_goRoot, "BackButton")
  self.m_txt_back_name_Text = self.m_goRoot.transform:Find("pnl_list/m_btn_back/txt_back_name"):GetComponent(T_TextMeshProUGUI)
  if sTitle then
    self.m_txt_back_name_Text.text = sTitle
  end
end

function BackButton:OnUpdate(dt)
end

function BackButton:SetBackHomeActive(isActive)
  UILuaHelper.SetActive(self.m_btn_home, isActive)
end

function BackButton:SetExplainID(newExplainID)
  self.m_explainID = newExplainID
end

function BackButton:OnBtnbackClicked()
  if self.m_fBackCB ~= nil then
    self.m_fBackCB()
  else
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    StackFlow:Pop()
  end
end

function BackButton:OnBtnhomeClicked()
  if self.m_fBackHomeCB ~= nil then
    self.m_fBackHomeCB()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    GameSceneManager:CheckChangeSceneToMainCity(nil, true)
  end
end

function BackButton:OnBtnsymbolClicked()
  if self.m_explainCB then
    self.m_explainCB()
  elseif self.m_explainID then
    utils.popUpDirectionsUI({
      tipsID = self.m_explainID
    })
  end
end

function BackButton:OnDestroy()
  UILuaHelper.UnbindViewObjectsManual(self, self.m_goRoot, "BackButton")
end

return BackButton
