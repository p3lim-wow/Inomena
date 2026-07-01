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

-- for time < 10 seconds this will render "9.8"
-- for time > 10 seconds this will render nothing
addon.formatters.Buff = C_StringUtil.CreateNumericRuleFormatter()
addon.formatters.Buff:SetBreakpoints({
	{
		threshold = 0,
		format = ''
	},
	{
		threshold = 0.01,
		format = '%0.1f'
	},
	{
		threshold = 9.99,
		format = ''
	}
})

-- time suffixed with shorthands for hours, minutes or seconds,
-- colored when it reaches expiration
addon.formatters.Enchant = C_StringUtil.CreateNumericRuleFormatter()
addon.formatters.Enchant:SetBreakpoints({
	{
		threshold = 0,
		format = '|cffff0000%0.1fs|r',
		components = {
			{
				step = 0.1,
				rounding = Enum.NumericRuleFormatRounding.Up
			}
		}
	},
	{
		threshold = 10,
		format = '|cffffff00%ds|r',
		components = {
			{
				step = 1,
				rounding = Enum.NumericRuleFormatRounding.Up
			}
		}
	},
	{
		threshold = 60,
		format = "%dm",
		components = {
			{
				div = 60,
				step = 1,
				rounding = Enum.NumericRuleFormatRounding.Nearest
			}
		}
	},
	{
		threshold = 3600,
		format = "%dh",
		components = {
			{
				div = 3600,
				step = 1,
				rounding = Enum.NumericRuleFormatRounding.Nearest
			}
		}
	}
})
