local Form_LoginAnnouncementUpgrade = class("Form_LoginAnnouncementUpgrade", require("UI/UIFrames/Form_LoginAnnouncementUpgradeUI"))

function Form_LoginAnnouncementUpgrade:SetInitParam(param)
end

function Form_LoginAnnouncementUpgrade:AfterInit()
  self.m_panelUpgradeContent = {}
  self.m_panelUpgradeContentTemplate:SetActive(false)
  self.m_iUpgradeTitleHeight = self.m_textTitleTemplate:GetComponent("RectTransform").sizeDelta.y
  self.m_iUpgradeContentAnchorY = self.m_textContentTemplate:GetComponent("RectTransform").anchoredPosition.y
end

function Form_LoginAnnouncementUpgrade:OnActive()
  self.m_vUpgradeInfo = UserDataManager:GetBulletinUpgradeInfo()
  if self.m_vUpgradeInfo == nil or #self.m_vUpgradeInfo == 0 then
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_LOGINANNOUNCEMENTUPGRADE)
    return
  end
  self:ResetUpgrade()
end

function Form_LoginAnnouncementUpgrade:ResetUpgrade()
  local iUpgradeCount = #self.m_vUpgradeInfo
  self.m_textTitle_Text.text = self.m_vUpgradeInfo[iUpgradeCount].sTitle
  local panelUpgradeContentParent = self.m_scrollViewContent:GetComponent("ScrollRect").content
  for i = 1, iUpgradeCount do
    local contentOne = self.m_vUpgradeInfo[i]
    local panelUpgradeContent = self.m_panelUpgradeContent[i]
    if panelUpgradeContent == nil then
      panelUpgradeContent = CS.UnityEngine.GameObject.Instantiate(self.m_panelUpgradeContentTemplate, panelUpgradeContentParent)
      self.m_panelUpgradeContent[i] = panelUpgradeContent
    end
    panelUpgradeContent:SetActive(true)
    local bShowTitle = false
    local textUpgradeTitle = panelUpgradeContent.transform:Find("m_textTitleTemplate").gameObject
    if contentOne.sTitle and contentOne.sTitle ~= "" then
      textUpgradeTitle:SetActive(true)
      bShowTitle = true
      textUpgradeTitle:GetComponent(T_TextMeshProUGUI).text = contentOne.sTitle
    else
      textUpgradeTitle:SetActive(false)
    end
    local textUpgradeContent = panelUpgradeContent.transform:Find("m_textContentTemplate").gameObject
    if contentOne.sContent and contentOne.sContent ~= "" then
      textUpgradeContent:SetActive(true)
      textUpgradeContent:GetComponent(T_TextMeshProUGUI).text = contentOne.sContent
    else
      textUpgradeContent:SetActive(false)
    end
  end
  for i = iUpgradeCount + 1, #self.m_panelUpgradeContent do
    self.m_panelUpgradeContent[i]:SetActive(false)
  end
end

function Form_LoginAnnouncementUpgrade:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_LoginAnnouncementUpgrade", Form_LoginAnnouncementUpgrade)
return Form_LoginAnnouncementUpgrade
