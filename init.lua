--- ```
--- hs.loadSpoon("ClockAndWeather"):start({
--- 	latitude = 123.456,
--- 	longitude = 123.456,
--- 	url_append = "models=some_weather_model",
--- })
--- ```

local obj={}
obj.__index = obj

obj.name = "ClockAndWeather"
obj.version = "0.0"
obj.author = "dssste"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

local weather_names = {
	[0] = "clear-sky",
	[1] = "mainly-clear",
	[2] = "partly-cloudy",
	[3] = "overcast",
	[45] = "fog",
	[48] = "rime",
	[51] = "drizzle-light",
	[53] = "drizzle-moderate",
	[55] = "drizzle-dense",
	[56] = "freezing-drizzle-light",
	[57] = "freezing-drizzle-dense",
	[61] = "rain-slight",
	[63] = "rain-moderate",
	[65] = "rain-heavy",
	[66] = "freezing-rain-light",
	[67] = "freezing-rain-heavy",
	[71] = "snow-fall-slight",
	[73] = "snow-fall-moderate",
	[75] = "snow-fall-heavy",
	[77] = "snow-grains",
	[80] = "rain-showers-slight",
	[81] = "rain-showers-moderate",
	[82] = "rain-showers-violent",
	[85] = "snow-showers-slight",
	[86] = "snow-showers-heavy",
	[95] = "thunderstorm-slight-or-moderate",
	[96] = "thunderstorm-slight-hail",
	[99] = "thunderstorm-heavy-hail",
}

local weather_icons = {
	[0] = "☀️", -- clear sky
	[1] = "🌤", -- mainly clear
	[2] = "⛅", -- partly cloudy
	[3] = "☁️", -- overcast
	[45] = "🌫", -- fog
	[48] = "🌫❄️", -- depositing rime fog
	[51] = "🌦", -- drizzle: light
	[53] = "🌧", -- drizzle moderate
	[55] = "🌧", -- drizzle dense
	[56] = "🌧❄️", -- freezing drizzle: light
	[57] = "🌧❄️", -- freezing drizzle: dense
	[61] = "🌧", -- rain: slight
	[63] = "🌧", -- rain: moderate
	[65] = "🌧🌊", -- rain: heavy
	[66] = "🌧❄️", -- freezing rain: light
	[67] = "🌧❄️", -- freezing rain: heavy
	[71] = "🌨", -- snow fall: slight
	[73] = "🌨", -- snow fall: moderate
	[75] = "🌨❄️", -- snow fall: heavy
	[77] = "🌨❄️", -- snow grains
	[80] = "🌦", -- rain showers: slight
	[81] = "🌦", -- rain showers: moderate
	[82] = "🌧🌊", -- rain showers: violent
	[85] = "🌨", -- snow showers slight
	[86] = "🌨❄️", -- snow showers heavy
	[95] = "⛈", -- thunderstorm: slight or moderate
	[96] = "⛈❄️", -- thunderstorm with slight hail
	[99] = "⛈❄️🌨", -- thunderstorm with heavy hail
}

function obj:update_canvas()
	local mainScreen = hs.screen.primaryScreen()
	self.canvas:frame(mainScreen:localToAbsolute({
		x = mainScreen:fullFrame().w - self.width,
		y = 0,
		w = self.width,
		h = self.height,
	}))
end

function obj:update_weather()
	local url = "https://api.open-meteo.com/v1/forecast?latitude=" .. self.latitude .. "&longitude=" .. self.longitude .. "&current=temperature_2m,is_day,precipitation,weather_code,wind_speed_10m&timezone=auto&forecast_days=1&" .. self.url_append
	hs.http.asyncGet(url, nil, function(status, response)
		if status == 400 then
			print("Error: " .. response)
			self.weather = "..."
			return
		end
		local weatherData = hs.json.decode(response)
		local values = weatherData.current
		local units = weatherData.current_units
		self.weather = weather_icons[values.weather_code] .. " " .. string.format("%.f", values.temperature_2m) .. units.temperature_2m
	end)
end

function obj:update_clock_text()
	self.canvas[2].text = os.date(self.format) .. self.weather
end

function obj:start(config)
	self.format = "%a / %b %d / %Y / %I:%M %p / "
	self.textSize = 14
	self.width = 620
	self.height = 24

	self.weather = "..."
	self.latitude = config.latitude
	self.longitude = config.longitude
	self.url_append = config.url_append
	if self.longitude ~= nil and self.latitude ~= nil then
		if self.url_append == nil then
			self.url_append = ""
		end
		self:update_weather()
		self.weather_timer = hs.timer.doEvery(900, function() self:update_weather() end)
	end

	if not self.canvas then self.canvas = hs.canvas.new({x=0, y=0, w=0, h=0}) end
	self.canvas[1] = {
		type = "rectangle",
		action = "fill",
		fillColor = {red=0.095, green=0.095, blue=0.095},
	}
	self.canvas[2] = {
		type = "text",
		textFont = "Inconsolata LGC Nerd Font Mono",
		textSize = self.textSize,
		textColor = {hex="#ffffff"},
		textAlignment = "right",
		frame = {
			x = -self.textSize,
			y = 0,
			w = "100%",
			h = "100%",
		}
	}
	self:update_canvas()
	self._screen_watcher = hs.screen.watcher.new(function()
		self:update_canvas()
	end)
	self._screen_watcher:start()
	self._init_done = true
	self:update_clock_text()
	self.canvas:show()
	self.tick_timer = hs.timer.doEvery(1, function() self:update_clock_text() end)
end

function obj:_ui_test()
	if self.tick_timer then
		self.tick_timer:stop()
		self.tick_timer = nil
	end
	if self.weather_timer then
		self.weather_timer:stop()
		self.weather_timer = nil
	end
	self.weather = weather_icons[1] .. " " .. string.format("%.f", 25.3) .. "°C"
	self.canvas[2].text = os.date(self.format, 198234) .. self.weather
end

return obj
