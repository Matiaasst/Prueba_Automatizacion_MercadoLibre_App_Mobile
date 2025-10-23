
module EML
  BUSCADOR            = [:id,    'com.mercadolibre:id/ui_components_toolbar_search_field']
  BUSCADOR_INPUT      = [:id,    'com.mercadolibre:id/autosuggest_input_search']
  BTN_FILTRO          = [:xpath, '(//android.widget.LinearLayout[@resource-id="com.mercadolibre:id/appbar_content_layout"])[1]/android.widget.LinearLayout']
  OPT_NUEVO           = [:xpath, "//android.widget.ToggleButton[@text='Nuevo']"]
  OPT_PRECIO          = [:xpath, "//android.view.View[@content-desc='Precio']"]
  OPT_CDMX            = [:xpath, "//android.widget.ToggleButton[@resource-id='SHIPPING_ORIGIN-10215068']"]
  OPT_MENOR_PRECIO    = [:xpath, "//android.widget.ToggleButton[@resource-id='price-*-10000']"]
  BTN_VER_RESULTADOS  = [:xpath, "//android.widget.Button[@resource-id=':r3:']"]
  FIRST_PRODUCT_NAME  = [:xpath, "(//android.widget.RelativeLayout[@resource-id='com.mercadolibre:id/search_cell_core_list'])[1]//android.widget.TextView[@resource-id='com.mercadolibre:id/search_cell_title_text_view']"]
  FIRST_PRODUCT_PRICE = [:id,    'com.mercadolibre:id/search_cell_pds_qty_price_view']

  class << self
    def buscador            = BUSCADOR
    def buscador_input      = BUSCADOR_INPUT
    def btn_filtro          = BTN_FILTRO
    def opt_nuevo           = OPT_NUEVO
    def opt_precio          = OPT_PRECIO
    def opt_CDMX            = OPT_CDMX
    def opt_MenorPrecio     = OPT_MENOR_PRECIO
    def btn_VerResultados   = BTN_VER_RESULTADOS
    def first_product_name  = FIRST_PRODUCT_NAME
    def first_product_price = FIRST_PRODUCT_PRICE
  end
end