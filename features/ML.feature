@MercadoLibre
Feature: Buscar en MercadoLibre

  Scenario: Buscar PlayStation 5 y filtrar resultados
    Given Abrir la app de MercadoLibre
    Then Buscar en la barra de busqueda playstation
    Then Filtrar producto por condicion nuevo
    Then Filtrar producto por localizacion CDMX
    Then Filtrar producto por menor precio
    And Obtener los nombres y precios de los cinco primeros productos
