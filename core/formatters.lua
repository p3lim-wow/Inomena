local _, addon = ...

addon.formatters = {}

-- for time < 10 seconds this will render one decimal point
-- for time > 10 seconds this will render no decimal points
-- for time > 60 seconds this will render nothing
addon.formatters.Cooldown = C_StringUtil.CreateNumericRuleFormatter()
addon.formatters.Cooldown:SetBreakpoints({
	{threshold = 0,  format = '%0.1f', step = 0.1, rounding = Enum.NumericRuleFormatRounding.Down},
	{threshold = 10, format = '%d'},
	{threshold = 60, format = ''},
})

-- for time < 10 seconds this will render one decimal point
-- for time > 10 seconds this will render nothing
addon.formatters.Buff = C_StringUtil.CreateNumericRuleFormatter()
addon.formatters.Buff:SetBreakpoints({
	{threshold = 0,  format = '%0.1f', step = 0.1, rounding = Enum.NumericRuleFormatRounding.Down},
	{threshold = 10, format = ''},
})
