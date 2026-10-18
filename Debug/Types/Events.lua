---@alias AE_EventCallback fun(frame: Frame, event: string, ...: any)
---@alias AE_EventBucketStateByCallback table<AE_EventCallback, AE_EventBucketPending>

---@class AE_EventPackedVarargs
---@field n number

---@class AE_EventHandlerEntry
---@field fn AE_EventCallback
---@field runsImmediately boolean

---@class AE_EventBucketPending
---@field timer { Cancel: fun(self) }?
---@field event string
---@field packedVarargs AE_EventPackedVarargs

---@class AE_EventRuntime
---@field pendingByCallback AE_EventBucketStateByCallback

---@class AE_Events
---@field handlers table<string, AE_EventHandlerEntry[]>
---@field frame Frame
---@field runtime AE_EventRuntime
