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

-- render time with different precision and suffix
addon.formatters.Buff = C_StringUtil.CreateNumericRuleFormatter()
addon.formatters.Buff:SetBreakpoints({
	{threshold = 0,        format = '%0.1f', step = 0.1, rounding = Enum.NumericRuleFormatRounding.Down},
	{threshold = 10,       format = '%d'},
	{threshold = 60,       format = '%0.0fm', components = {{div = 60}}},
	{threshold = 3600,     format = '%0.0fh', components = {{div = 3600}}},
	{threshold = 86400,    format = '%0.0fd', components = {{div = 86400}}},
	{threshold = 31536000, format = '%0.0fy', components = {{div = 31536000}}},
})
