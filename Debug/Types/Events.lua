---@alias AE_EventCallback fun(frame: Frame, event: string, ...: any)
---@alias AE_EventBucketStateByName table<string, AE_EventBucketPending>

---@class AE_EventPackedVarargs
---@field n number
---@field [integer] any

---@class AE_EventHandlerEntry
---@field fn AE_EventCallback
---@field runsImmediately boolean

---@class AE_EventBucketPending
---@field timer { Cancel: fun(self) }?
---@field packedVarargs AE_EventPackedVarargs

---@class AE_EventRuntime
---@field pendingByEventName AE_EventBucketStateByName

---@class AE_Events
---@field handlers table<string, AE_EventHandlerEntry[]>
---@field frame Frame
---@field runtime AE_EventRuntime
