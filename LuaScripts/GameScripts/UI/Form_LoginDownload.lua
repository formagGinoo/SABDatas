local Form_LoginDownload = class("Form_LoginDownload", require("UI/UIFrames/Form_LoginDownloadUI"))

function Form_LoginDownload:SetInitParam(param)
end

function Form_LoginDownload:AfterInit()
  self.super.AfterInit(self)
  self.m_compDisplayUGUI = self.m_Video:GetComponent(typeof(CS.RenderHeads.Media.AVProVideo.DisplayUGUI))
end

function Form_LoginDownload:OnActive()
  self.super.OnActive(self)
  local stDownloadInfo = self.m_csui.m_param
  if stDownloadInfo.bShow == false then
    self.m_bar_bg_01:SetActive(false)
    self.m_z_txt_detail:SetActive(false)
    self.m_txt_percentage:SetActive(false)
    self.m_txt_download_total:SetActive(false)
    self.m_bFadeOut = true
    self:CloseForm()
    return
  end
  self.m_compDisplayUGUI.CurrentMediaPlayer = CS.VideoManager.GlobalVideoPlayer
  CS.UI.UILuaHelper.PlayFromAddRes("UI_LoginDownload", "", false, handler(self, self.OnVideoPlayFinish), CS.UnityEngine.ScaleMode.ScaleToFit, true, true)
  local lCurBytes = stDownloadInfo.lCurBytes
  local lTotalBytes = stDownloadInfo.lTotalBytes
  self.m_bar_bg_01:SetActive(true)
  self.m_bar_Image.fillAmount = lCurBytes / lTotalBytes
  self.m_z_txt_detail:SetActive(true)
  self.m_z_txt_detail_Text.text = CS.ConfFact.LangFormat4DataInit("LoginDownloadUIDetail")
  self.m_txt_percentage:SetActive(true)
  self.m_txt_percentage_Text.text = math.floor(lCurBytes / lTotalBytes * 100) .. "%"
  self.m_txt_download_total:SetActive(true)
  self.m_txt_download_total_Text.text = DownloadManager:GetDownloadProgressStr(lCurBytes, lTotalBytes)
  self.m_bFadeOut = false
  self.m_iHandlerIDShowDownloadProgress = self:addEventListener("eGameEvent_Login_ShowDownloadProgressBig", handler(self, self.OnEventShowDownloadProgress))
end

function Form_LoginDownload:OnInactive()
  self.super.OnInactive(self)
  self.m_compDisplayUGUI.CurrentMediaPlayer = null
  VideoManager:Stop()
  self:removeEventListener("eGameEvent_Login_ShowDownloadProgressBig", self.m_iHandlerIDShowDownloadProgress)
  local bHQ = CS.MUF.Resource.ResourceManager.GetHQ2D()
  CS.VideoManager.Instance:PlayFromAddResReal("UI_Login_Main", "", false, nil, CS.UnityEngine.ScaleMode.ScaleAndCrop, false, true, false, false, bHQ)
  local obj = CS.UnityEngine.GameObject.Find("Form_Viedo"):GetComponent("Canvas")
  obj.sortingOrder = 2000
end

function Form_LoginDownload:OnUpdate(dt)
end

function Form_LoginDownload:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LoginDownload:OnVideoPlayFinish()
end

function Form_LoginDownload:OnEventShowDownloadProgress(stDownloadInfo)
  if self.m_bFadeOut then
    return
  end
  if stDownloadInfo.bShow then
    local lCurBytes = stDownloadInfo.lCurBytes
    local lTotalBytes = stDownloadInfo.lTotalBytes
    self.m_bar_bg_01:SetActive(true)
    self.m_bar_Image.fillAmount = lCurBytes / lTotalBytes
    self.m_z_txt_detail:SetActive(true)
    self.m_txt_percentage:SetActive(true)
    self.m_txt_percentage_Text.text = math.floor(lCurBytes / lTotalBytes * 100) .. "%"
    self.m_txt_download_total:SetActive(true)
    self.m_txt_download_total_Text.text = DownloadManager:GetDownloadProgressStr(lCurBytes, lTotalBytes)
  else
    self.m_bar_bg_01:SetActive(false)
    self.m_z_txt_detail:SetActive(false)
    self.m_txt_percentage:SetActive(false)
    self.m_txt_download_total:SetActive(false)
    self.m_bFadeOut = true
    self:CloseForm()
  end
end

local fullscreen = true
ActiveLuaUI("Form_LoginDownload", Form_LoginDownload)
return Form_LoginDownload
