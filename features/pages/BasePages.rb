require 'appium_lib'

class BasePages
  def initialize(driver)
    @driver = driver
  end

  def swipe_down(driver, duration=800)
  size = driver.window_size
  width = size.width
  height = size.height

  start_x = (width / 2).to_i
  start_y = (height * 0.2).to_i
  end_y = (height * 0.8).to_i

  actions = [{
    type: 'pointer',
    id: 'finger1',
    parameters: { pointerType: 'touch' },
    actions: [
      { type: 'pointerMove', duration: 0, x: start_x, y: start_y },
      { type: 'pointerDown', button: 0 },
      { type: 'pause', duration: 100 },
      { type: 'pointerMove', duration: duration, x: start_x, y: end_y },
      { type: 'pointerUp', button: 0 }
    ]
  }]

  driver.perform_actions(actions)
  driver.release_actions
  end


  def frameScroll_down(percent)
  @driver.execute_script('mobile: scrollGesture', {
    left: 500,      # posición X de inicio
    top: 1000,      # posición Y de inicio
    width: 500,     # anchura
    height: 1000,   # altura
    direction: 'down',   # dirección (puede ser 'up', 'down', 'left', 'right')
    percent: percent 
  })
  end

  def scroll_to_text(texto)
  ui = 'new UiScrollable(new UiSelector().scrollable(true).instance(0))' \
       ".scrollIntoView(new UiSelector().textContains(\"#{texto}\").instance(0));"
  @driver.find_element(:android_uiautomator, ui)
 end


def obtener_nombres_y_precios
  nombres_elements = @driver.find_elements(:xpath, "//*[@id='sourceContainer']//span[contains(@text, '')]")
  precios_elements = @driver.find_elements(:id, 'com.mercadolibre:id/money_amount_text')

  if nombres_elements.empty? || precios_elements.empty?
    puts "No se encontraron productos o precios."
  else
    total = [nombres_elements.size, precios_elements.size, 5].min  # Limitar a 5 productos

    total.times do |i|
      nombre = nombres_elements[i].text
      precio = precios_elements[i].text
      puts "Producto ##{i + 1}: #{nombre} - Precio: #{precio}"
    end

    if total < 5
      puts "Solo se encontraron #{total} productos visibles."
    end
  end
end
end
