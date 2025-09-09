local Form_LoginInstallPop = class("Form_LoginInstallPop", require("UI/UIFrames/Form_LoginInstallPopUI"))

function Form_LoginInstallPop:SetInitParam(param)
end

function Form_LoginInstallPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_LoginInstallPop:OnActive()
  self.super.OnActive(self)
  local param = self.m_csui.m_param
  self.m_onDownloadComplete = param.onDownloadComplete
  self.m_onBeginDownload = param.onBeginDownload
  self:RefreshUI()
end

function Form_LoginInstallPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_LoginInstallPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LoginInstallPop:RefreshUI()
  local downloadSize = CS.MUF.Download.DownloadResource.Instance:GetDownloadSize()
  self.m_install_size_Text.text = DownloadManager:GetDownloadSizeStr(downloadSize)
end

function Form_LoginInstallPop:OnBtncancelClicked()
  self:CloseForm()
end

function Form_LoginInstallPop:OnBtnacceptClicked()
  if self.m_onBeginDownload then
    self.m_onBeginDownload()
  end
  CS.MUF.Download.DownloadResource.Instance:VerifyResourceMD5(function(completed, totalcount, list, filesize)
    self.m_onDownloadComplete(completed, totalcount, list, filesize)
  end)
  self:CloseForm()
end

function Form_LoginInstallPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LoginInstallPop", Form_LoginInstallPop)
return Form_LoginInstallPop
