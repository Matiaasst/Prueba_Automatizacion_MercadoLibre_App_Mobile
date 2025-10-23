# frozen_string_literal: true
require 'selenium-webdriver'
require 'json'
require 'net/http'
require 'uri'

APPIUM_HOST = '127.0.0.1'
APPIUM_PORT = 4723
CANDIDATE_PATHS = ['', '/wd/hub', '/v1', '/appium']  # intenta varias rutas

def pick_server_url
  CANDIDATE_PATHS.each do |base|
    url = "http://#{APPIUM_HOST}:#{APPIUM_PORT}#{base}"
    begin
      res = Net::HTTP.get_response(URI("#{url}/status"))
      return url if res.is_a?(Net::HTTPSuccess)
    rescue
      # probar siguiente
    end
  end
  "http://#{APPIUM_HOST}:#{APPIUM_PORT}"
end

def create_driver
  server_url = pick_server_url

  caps = Selenium::WebDriver::Remote::Capabilities.new
  caps['platformName']                             = 'Android'
  caps['appium:automationName']                    = 'UiAutomator2'
  caps['appium:deviceName']                        = 'Android'
  #caps['appium:udid']                              = 'R5CW30XHH5N'
  caps['appium:appPackage']                        = 'com.mercadolibre'
  #caps['appium:appActivity']                       = 'com.mercadolibre.ui.splash.SplashActivity'
  caps['appium:appWaitActivity']                   = 'com.mercadolibre.*'
  caps['appium:appWaitForLaunch']                  = true
  caps['appium:appWaitForLaunchTimeout']           = 30000
  caps['appium:noReset']                           = true
  caps['appium:fullReset']                         = false
  caps['appium:autoGrantPermissions']              = true
  caps['appium:newCommandTimeout']                 = 300
  caps['appium:adbExecTimeout']                    = 60000
  caps['appium:uiautomator2ServerLaunchTimeout']   = 60000
  caps['appium:uiautomator2ServerInstallTimeout']  = 60000

  http = Selenium::WebDriver::Remote::Http::Default.new
  http.read_timeout = 120

  puts "➡️  Conectando a Appium en: #{server_url}"
  Selenium::WebDriver.for(:remote, url: server_url, capabilities: caps, http_client: http)
end

Before do
  @driver = create_driver
end

After do
  @driver&.quit
end
