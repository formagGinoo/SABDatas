local Form_DownloadTips = class("Form_DownloadTips", require("UI/UIFrames/Form_DownloadTipsUI"))

function Form_DownloadTips:SetInitParam(param)
end

function Form_DownloadTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_DownloadTips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_iBatchID = tParam.iBatchID
  self.m_txt_download_total_Text.text = ""
  self.m_txt_download_percentage_Text.text = ""
  self.m_bar_Image.fillAmount = 0
  self.m_closeOnly = tParam.bCloseOnly
  if tParam.iTipsID then
    self.m_txt_detail_Text.text = ConfigManager:GetCommonTextById(tParam.iTipsID)
  else
    self.m_txt_detail_Text.text = ConfigManager:GetCommonTextById(100030)
  end
  if tParam.iButtonID then
    self.m_txt_download_Text.text = ConfigManager:GetCommonTextById(tParam.iButtonID)
  else
    self.m_txt_download_Text.text = ConfigManager:GetCommonTextById(100031)
  end
  self.m_btn_download:SetActive(false)
  self.m_lCurBytesPre = -1
  self.m_iHandlerIDProgress = self:addEventListener("eGameEvent_ResourceDownload_Progress", handler(self, self.OnEventProgress))
  self.m_iHandlerIDUpdateBatchID = self:addEventListener("eGameEvent_ResourceDownload_UpdateBatchID", handler(self, self.OnEventUpdateBatchID))
  local stDownloadResourceWithUIConfig = DownloadManager:GetDownloadResourceWithUIConfig(self.m_iBatchID)
  if stDownloadResourceWithUIConfig == nil then
    self:CloseForm()
  end
end

function Form_DownloadTips:OnInactive()
  self.super.OnInactive(self)
  self:RemoveEventListeners()
  DownloadManager:HideShowDownloadResourceUI()
end

function Form_DownloadTips:RemoveEventListeners()
  if self.m_iHandlerIDProgress then
    self:removeEventListener("eGameEvent_ResourceDownload_Progress", self.m_iHandlerIDProgress)
    self.m_iHandlerIDProgress = nil
  end
  if self.m_iHandlerIDUpdateBatchID then
    self:removeEventListener("eGameEvent_ResourceDownload_UpdateBatchID", self.m_iHandlerIDUpdateBatchID)
    self.m_iHandlerIDUpdateBatchID = nil
  end
end

function Form_DownloadTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_DownloadTips:OnEventProgress(tInfo)
  if tInfo.iBatchID ~= self.m_iBatchID then
    return
  end
  if tInfo.bComplete then
    self:CloseForm()
  elseif tInfo.lCurBytes > self.m_lCurBytesPre then
    local lCurBytes = tInfo.lCurBytes
    local lTotalBytes = tInfo.lTotalBytes
    if lCurBytes > lTotalBytes then
      lCurBytes = lTotalBytes
    end
    self.m_lCurBytesPre = lCurBytes
    self.m_txt_download_total_Text.text = DownloadManager:GetDownloadProgressStr(lCurBytes, lTotalBytes)
    self.m_txt_download_percentage_Text.text = math.floor(lCurBytes / lTotalBytes * 100) .. "%"
    self.m_bar_Image.fillAmount = lCurBytes / lTotalBytes
  end
end

function Form_DownloadTips:OnEventUpdateBatchID(tInfo)
  if tInfo.iBatchIDPre ~= self.m_iBatchID then
    return
  end
  self.m_lCurBytesPre = -1
  self.m_iBatchID = tInfo.iBatchID
end

function Form_DownloadTips:OnBtndownloadClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  if not self.m_closeOnly then
    self:broadcastEvent("eGameEvent_ResourceDownload_UIManualClosed", {
      iBatchID = self.m_iBatchID
    })
  end
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_DownloadTips", Form_DownloadTips)
return Form_DownloadTips
