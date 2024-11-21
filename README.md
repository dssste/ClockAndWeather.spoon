Shows date time and weather on top of the menu bar.

```lua
hs.loadSpoon("ClockAndWeather"):start({
 	latitude = 123.456,
 	longitude = 123.456,
 	url_append = "models=some_weather_model",
})
```

![](https://github.com/user-attachments/assets/3fa32e9b-c95e-458a-a15c-b06fe1809733)

The weather data is fetched from Open-Meteo every 15 mins. The data may differ from what the OS weather widget displays.

I just make sure not to hard-code sensitive data like latitude and weather model, but if you want to configure anything else, you need to do it by ![changing the script]("https://www.hammerspoon.org/docs/"). By default, it draws a rectangle on the top-right of the primary screen, covering the icons originally displayed on the menu bar.
