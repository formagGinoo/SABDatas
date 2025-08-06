local Form_LoginAnnouncement = class("Form_LoginAnnouncement", require("UI/UIFrames/Form_LoginAnnouncementUI"))

function Form_LoginAnnouncement:SetInitParam(param)
end

function Form_LoginAnnouncement:AfterInit()
  self.m_panelBulletinContent = {}
  self.m_panelBulletinContentTemplate:SetActive(false)
  self.m_iBulletinTitleHeight = self.m_textTitleTemplate:GetComponent("RectTransform").sizeDelta.y
  self.m_iBulletinContentAnchorY = self.m_textContentTemplate:GetComponent("RectTransform").anchoredPosition.y
end

function Form_LoginAnnouncement:OnActive()
  self.m_stBulletinInfo = self.m_csui.m_param.stBulletinInfo
  self.m_fCloseCB = self.m_csui.m_param.fCloseCB
  self:ResetBulletin()
  local iNotPopup = CS.UnityEngine.PlayerPrefs.GetInt("BulletinNotPopup", 0)
  self.m_toggleNotPopup_Toggle.isOn = iNotPopup == 1
end

function Form_LoginAnnouncement:ResetBulletin()
  self.m_textTitle_Text.text = self.m_stBulletinInfo.sTitle
  local iBulletinCount = 0
  if self.m_stBulletinInfo.vContent then
    local panelBulletinContentParent = self.m_scrollViewContent:GetComponent("ScrollRect").content
    iBulletinCount = #self.m_stBulletinInfo.vContent
    for i = iBulletinCount, 1, -1 do
      local contentOne = self.m_stBulletinInfo.vContent[i]
      local panelBulletinContent = self.m_panelBulletinContent[i]
      if panelBulletinContent == nil then
        panelBulletinContent = CS.UnityEngine.GameObject.Instantiate(self.m_panelBulletinContentTemplate, panelBulletinContentParent)
        self.m_panelBulletinContent[i] = panelBulletinContent
      end
      panelBulletinContent:SetActive(true)
      local bShowTitle = false
      local textBulletinTitle = panelBulletinContent.transform:Find("m_textTitleTemplate").gameObject
      if contentOne.sTitle and contentOne.sTitle ~= "" then
        textBulletinTitle:SetActive(true)
        bShowTitle = true
        textBulletinTitle:GetComponent(T_Text).text = contentOne.sTitle
      else
        textBulletinTitle:SetActive(false)
      end
      local textBulletinContent = panelBulletinContent.transform:Find("m_textContentTemplate").gameObject
      if contentOne.sContent and contentOne.sContent ~= "" then
        textBulletinContent:SetActive(true)
        textBulletinContent:GetComponent(T_Text).text = contentOne.sContent
      else
        textBulletinContent:SetActive(false)
      end
    end
  end
  for i = iBulletinCount + 1, #self.m_panelBulletinContent do
    self.m_panelBulletinContent[i]:SetActive(false)
  end
end

function Form_LoginAnnouncement:CloseUI()
  if self.m_toggleNotPopup_Toggle.isOn then
    CS.UnityEngine.PlayerPrefs.SetInt("BulletinNotPopup", 1)
    CS.UnityEngine.PlayerPrefs.SetInt("BulletinNextPopupTime" .. self.m_stBulletinInfo.iBulletinId, TimeUtil:GetServerNextCommonResetTime())
    CS.UnityEngine.PlayerPrefs.Save()
  else
    CS.UnityEngine.PlayerPrefs.SetInt("BulletinNotPopup", 0)
    CS.UnityEngine.PlayerPrefs.Save()
  end
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_LOGINANNOUNCEMENT)
  if self.m_fCloseCB then
    self.m_fCloseCB()
  end
end

function Form_LoginAnnouncement:OnBtnCloseClicked()
  self:CloseUI()
end

function Form_LoginAnnouncement:OnBtnReturnClicked()
  self:CloseUI()
end

function Form_LoginAnnouncement:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_LoginAnnouncement", Form_LoginAnnouncement)
return Form_LoginAnnouncement
