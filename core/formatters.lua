local _, addon = ...

addon.formatters = {}

-- for time < 3 seconds this will render "9.8"
-- for time > 3 seconds this will render "10"
-- for time > 59 seconds this will render nothing
addon.formatters.Countdown = C_StringUtil.CreateNumericRuleFormatter()
addon.formatters.Countdown:SetBreakpoints({
	{
		threshold = 0,
		format = '%0.1f',
	},
	{
		threshold = 3.01,
		format = '%d',
	},
	{
		threshold = 59,
		format = '',
	},
})
