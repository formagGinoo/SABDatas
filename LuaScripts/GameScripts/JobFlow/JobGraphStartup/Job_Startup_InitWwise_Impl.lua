local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local WwiseMusicPlayer = CS.WwiseMusicPlayer.Instance
local Job_Startup_InitWwise_Impl = {}

function Job_Startup_InitWwise_Impl.OnInitWwise(jobNode)
  WwiseMusicPlayer:InitWwise(function(bSucess)
    TimeService:SetTimer(0.1, 1, function()
      WwiseMusicPlayer:LoadBankAsyn("Init.bnk", function(result)
        CS.EventSenderBase.EventSender = CS.EventSenderImpl.Instance
        CS.TimelineExtension.EventBehaviour.TLEventSender = CS.TimelineExtension.TimelineEventSender.Instance
        CS.TimelineExtension.TimelineCharacterShadowBehaviour.TLEventSender = CS.TimelineExtension.TimelineCharacterShadowEventSender.Instance
        EventCenter.AddListener(EventDefine.eGameEvent_PlayMusic, Job_Startup_InitWwise_Impl.PlayMusic)
        EventCenter.AddListener(EventDefine.eGameEvent_StopMusic, Job_Startup_InitWwise_Impl.StopMusic)
        EventCenter.AddListener(EventDefine.eGameEvent_StartAnimation, Job_Startup_InitWwise_Impl.StartAnimation)
        CS.UI.UILuaHelper.StartPlayBGM("Play_Login")
        TimeService:SetTimer(1.0E-4, 1, function()
          jobNode.Status = JobStatus.Success
        end)
      end)
    end)
  end)
end

function Job_Startup_InitWwise_Impl.PlayMusic(bankName, eventName, bgmId)
  if 0 < bgmId then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(bgmId)
    return
  end
  if not string.isnullorempty(bankName) then
    if not string.isnullorempty(eventName) then
      WwiseMusicPlayer:PlaySFX(bankName, eventName)
    end
  elseif not string.isnullorempty(eventName) then
    WwiseMusicPlayer:StartPlay(eventName)
  end
end

function Job_Startup_InitWwise_Impl.StopMusic(eventName, bgmId)
  if 0 < bgmId then
    local conf = CS.CData_BGMStateGroup.GetInstance():GetValue_ByBGMId(bgmId)
    if not conf:GetError() then
      eventName = conf.m_EventName
    end
  end
  if not string.isnullorempty(eventName) then
    WwiseMusicPlayer:TryStop(eventName)
  end
end

function Job_Startup_InitWwise_Impl.StartAnimation(obj, clipName)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUE)
  if form ~= nil and form:IsSpedUp() then
    return
  end
  local cfgInstance = CS.CData_ActionSoundEffects.GetInstance()
  local ele = cfgInstance:GetValue_ByID(clipName)
  if not ele:GetError() then
    CS.UI.UILuaHelper.StartPlaySFX(ele.m_AudioEvent, obj)
  end
end

function Job_Startup_InitWwise_Impl.OnInitWwiseSuccess(jobNode)
end

function Job_Startup_InitWwise_Impl.OnInitWwiseFailed(jobNode)
end

function Job_Startup_InitWwise_Impl.OnInitWwiseTimeOut(jobNode)
end

function Job_Startup_InitWwise_Impl.OnInitWwiseDispose(jobNode)
end

return Job_Startup_InitWwise_Impl
