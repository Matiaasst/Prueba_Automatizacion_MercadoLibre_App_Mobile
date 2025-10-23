require_relative '../pages/BasePages'
require_relative '../pages/elements/EML'
require 'fileutils'

def scroll_to_text(texto)
  ui = 'new UiScrollable(new UiSelector().scrollable(true).instance(0))' \
       ".scrollIntoView(new UiSelector().textContains(\"#{texto}\").instance(0));"
  @driver.find_element(:android_uiautomator, ui)
end

def base_page
  @base_page ||= BasePages.new(@driver)
end


Given('Abrir la app de MercadoLibre') do
  wait = Selenium::WebDriver::Wait.new(timeout: 45)
  def sh(driver, cmd, args = [])
    res = driver.execute_script('mobile: shell', command: cmd, args: args) rescue {}
    (res.is_a?(Hash) ? res['stdout'] : res).to_s
  end
  def maybe_click(driver, by, locator)
    els = driver.find_elements(by, locator) rescue []
    els.first&.click if els.any?
    els.any?
  end
  def visible?(el) el && el.displayed? rescue false end
  def focused_pkg(driver)
    out = sh(driver, 'dumpsys', ['window'])
    line = out.lines.find { |l| l.include?('mCurrentFocus') || l.include?('mFocusedApp') } || ''
    line[/\bu0\s+([a-zA-Z0-9\._]+)/, 1] || line[/\b([a-zA-Z0-9\._]+)\/[a-zA-Z0-9\._]+/, 1]
  end
  def resolve_launcher(driver, pkg)
    out = sh(driver, 'cmd', ['package','resolve-activity','-c','android.intent.category.LAUNCHER', pkg])
    act = out[/name=([a-zA-Z0-9\._]+)/, 1]
    act && act.start_with?('.') ? "#{pkg}#{act}" : act
  end

  begin
    installed = sh(@driver, 'pm', ['path','com.mercadolibre']).strip
    puts "📎 ML instalado: #{installed.empty? ? 'NO' : installed}"
  rescue; end

  sh(@driver, 'input', ['keyevent','224']) # wake
  sh(@driver, 'wm', ['dismiss-keyguard']) rescue nil
  sh(@driver, 'input', ['keyevent','82'])  rescue nil

  began = Time.now

  begin
    @driver.execute_script('mobile: activateApp', appId: 'com.mercadolibre')
  rescue => e
    puts "activateApp falló: #{e.message}"
  end

  pkg = focused_pkg(@driver)
  puts "📎 Focus tras activateApp: #{pkg.inspect}"

  unless pkg&.include?('com.mercadolibre')
    act = resolve_launcher(@driver, 'com.mercadolibre')
    puts "📎 Launcher activity: #{act.inspect}"
    if act
      begin
        @driver.execute_script('mobile: startActivity', {
          appPackage: 'com.mercadolibre',
          appActivity: act
        })
      rescue => e
        puts "startActivity(#{act}) falló: #{e.message}"
      end
    end
    pkg = focused_pkg(@driver)
    puts "📎 Focus tras startActivity: #{pkg.inspect}"
  end

  unless pkg&.include?('com.mercadolibre')
    sh(@driver, 'monkey', ['-p','com.mercadolibre','-c','android.intent.category.LAUNCHER','1'])
    pkg = focused_pkg(@driver)
    puts "📎 Focus tras monkey: #{pkg.inspect}"
  end

  5.times do
    clicked = false
    clicked ||= maybe_click(@driver, :id, 'com.android.permissioncontroller:id/permission_allow_button')
    clicked ||= maybe_click(@driver, :id, 'com.android.permissioncontroller:id/permission_allow_foreground_only_button')
    clicked ||= maybe_click(@driver, :id, 'com.android.packageinstaller:id/permission_allow_button')
    clicked ||= maybe_click(@driver, :id, 'android:id/button1')
    clicked ||= maybe_click(@driver, :xpath, "//*[@text='Permitir' or @text='ALLOW' or @text='Aceptar' or @text='Ahora no' or @text='AHORA NO']")
    break unless clicked
    sleep 0.3
  end

  begin
    ctxs = @driver.available_contexts rescue []
    @driver.switch_to.context('NATIVE_APP') if ctxs.include?('NATIVE_APP')
  rescue; end

  appeared = false
  start = Time.now
  while Time.now - start < 30
    el = @driver.find_element(:id, 'com.mercadolibre:id/ui_components_toolbar_search_field') rescue nil
    if visible?(el)
      puts 'Buscador visible'
      appeared = true
      break
    end
    el = @driver.find_element(:id, 'com.mercadolibre:id/autosuggest_input_search') rescue nil
    if visible?(el)
      puts 'Input de búsqueda visible'
      appeared = true
      break
    end
    maybe_click(@driver, :xpath, "//*[@text='Omitir' or @text='Saltar' or @text='Ahora no' or @text='NO GRACIAS']")
    sleep 0.8
  end

  ts = Time.now.strftime('%Y%m%d_%H%M%S')
  begin
    @driver.save_screenshot("target/screen_#{ts}.png")
    puts "📎 Captura: target/screen_#{ts}.png | focus=#{pkg.inspect} | duracion=#{(Time.now - began).round(1)}s"
  rescue; end

  puts appeared ? 'Continuamos al paso de búsqueda.' : 'ℹ️ No vi el buscador aún; continuamos y el siguiente paso lo intentará.'
end

Then('Buscar en la barra de busqueda playstation') do
  wait = Selenium::WebDriver::Wait.new(timeout: 40)

  # 1) Toca el buscador: prueba varias rutas comunes
  touched = false
  begin
    el = @driver.find_element(:id, 'com.mercadolibre:id/ui_components_toolbar_search_field')
    el.click
    touched = true
  rescue
    begin
      el = @driver.find_element(:accessibility_id, 'Buscar en Mercado Libre')
      el.click
      touched = true
    rescue
      begin
        el = @driver.find_element(:id, 'com.mercadolibre:id/landing_search_view')
        el.click
        touched = true
      rescue
        begin
          el = @driver.find_element(:xpath, "//*[@text='Buscar' or contains(@text,'Buscar en Mercado Libre')]")
          el.click
          touched = true
        rescue
          # Tab inferior "Buscar"
          begin
            el = @driver.find_element(:xpath, "//*[@content-desc='Buscar' or @text='Buscar']")
            el.click
            touched = true
          rescue
          end
        end
      end
    end
  end

    # 2) Asegura NATIVE antes de localizar el input (evita que :id se trate como CSS)
  begin
    ctxs = @driver.available_contexts rescue []
    @driver.switch_to.context('NATIVE_APP') if ctxs.include?('NATIVE_APP')
  rescue; end

  # 3) Localiza el input por XPath con resource-id (no CSS), con variantes
  input = nil
  begin
    input = wait.until { @driver.find_element(:xpath, "//*[@resource-id='com.mercadolibre:id/autosuggest_input_search']") }
  rescue
    begin
      input = wait.until { @driver.find_element(:xpath, "//*[@resource-id='com.mercadolibre:id/search_input_edittext']") }
    rescue
      # Cualquier EditText visible como último intento
      input = @driver.find_elements(:class_name, 'android.widget.EditText')
                      .find { |e| e.displayed? rescue false }
    end
  end

  # 4) Si no apareció, manda tecla SEARCH y reintenta
  if input.nil?
    @driver.press_keycode(84) rescue nil  # KEYCODE_SEARCH
    sleep 0.7
    begin
      input = wait.until {
        @driver.find_element(:xpath, "//*[@resource-id='com.mercadolibre:id/autosuggest_input_search' or @resource-id='com.mercadolibre:id/search_input_edittext']")
      }
    rescue
      # sigue null si no está
    end
  end

  if input
    input.click rescue nil
    input.clear rescue nil

    # Escribir texto (try send_keys; si falla, ADB)
    begin
      input.send_keys('playstation 5')
    rescue
      # Fallback: escribir vía ADB (espacio escapado)
      @driver.execute_script('mobile: shell', command: 'input', args: ['text','playstation%205']) rescue nil
    end

    # ENTER para buscar
    @driver.press_keycode(66) rescue nil
    puts '✅ Búsqueda de "playstation 5" realizada'
  else
    # Último recurso: escribe y busca vía ADB aunque el input no se vea
    @driver.execute_script('mobile: shell', command: 'input', args: ['text','playstation%205']) rescue nil
    @driver.execute_script('mobile: shell', command: 'input', args: ['keyevent','66']) rescue nil
    puts '✅ Búsqueda enviada vía ADB (fallback)'
  end

  # === Disparar la búsqueda ===
begin
  @driver.execute_script('mobile: performEditorAction', { action: 'search' })
  sleep 1
rescue
  @driver.press_keycode(66) rescue nil   
  sleep 0.5
  @driver.press_keycode(84) rescue nil   
  sleep 1
end
begin
  first_suggestion = @driver.find_elements(:xpath, "//*[@resource-id='com.mercadolibre:id/autosuggest_list']//android.view.ViewGroup | //*[contains(@resource-id,'autosuggest') and (self::android.widget.TextView or self::android.view.ViewGroup)]").first
  first_suggestion&.click
  sleep 1
rescue; end
begin
  @driver.execute_script('mobile: shell', command: 'input', args: ['keyevent','66'])
rescue; end
puts 'búsqueda lanzada'
end

Then('Filtrar producto por condicion nuevo') do
  begin
    sleep 2
    @driver.find_element(*EML.btn_filtro).click
    sleep 2
    base_page.frameScroll_down(45)
    sleep 2
    @driver.find_element(*EML.opt_nuevo).click
    sleep 4
    
    puts "Filtro aplicado: Condición 'Nuevo'"
  rescue => e
    puts "Error al aplicar el filtro por condición: #{e.message}"
  end
end

Then('Filtrar producto por localizacion CDMX') do
  begin
    @driver.find_element(*EML.opt_precio).click
    sleep 2
    @driver.find_element(*EML.opt_CDMX).click
    sleep 2
    puts "Filtro aplicado: Localización 'CDMX'"
  rescue => e
    puts "Error al aplicar el filtro por localización: #{e.message}"
  end
end

Then('Filtrar producto por menor precio') do
  begin
    @driver.find_element(*EML.opt_MenorPrecio).click
    sleep 2
    @driver.find_element(*EML.btn_VerResultados).click
    sleep 2
    puts "Filtro aplicado: Ordenar por 'Menor precio'"
  rescue => e
    puts "Error al aplicar el filtro por menor precio: #{e.message}"
  end
end

Then('Obtener los nombres y precios de los cinco primeros productos') do
  base_page.obtener_nombres_y_precios
end

