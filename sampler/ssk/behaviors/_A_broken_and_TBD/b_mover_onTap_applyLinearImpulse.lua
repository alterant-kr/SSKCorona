
-- =============================================================
-- b_mover_onTap_applyLinearImpulse.lua 
-- Mover Behavior - onTap event apply Linear Impulse to Object
-- Behavior Type: Instance
-- =============================================================
--
-- =============================================================
--local debugLevel = 1 -- Comment out to get global debugLevel from main.cs
local dp = ssk.debugprinter.newPrinter( debugLevel )
local dprint = dp.print

public = {}
public._behaviorName = "mover_onTap_applyLinearImpulse"

function public:onAttach( obj, params )
	dprint(1,"Attached Behavior: " .. self._behaviorName)

	local behaviorInstance = {}
	behaviorInstance._behaviorName = self._behaviorName
	behaviorInstance.params = params
	behaviorInstance.moveObj        = obj

	local function touch( event )
		local target    = event.target
		local numTaps   = event.numTaps
		
		local moveObj   = behaviorInstance.moveObj
		
		local impulseX  = behaviorInstance.params.impulseX or 0
		local impulseY  = behaviorInstance.params.impulseY or 0

		if(numTaps == 1) then
			moveObj:applyLinearImpulse( impulseX, impulseY, moveObj.x, moveObj.y )
		end

		return true
	end

	Runtime:addEventListener( "tap", onTap )		

	function behaviorInstance:onDetach( obj )
		dprint(1,"Detached behavior:" .. self._behaviorName)
		Runtime:removeEventListener( "tap", onTap )		
	end
	return behaviorInstance
end

ssk.behaviors:registerBehavior( public._behaviorName, public )

return public
