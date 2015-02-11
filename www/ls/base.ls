container = d3.select ig.containers.base
mapElement = container.append \div
  ..attr \id \map
map = L.map do
  * mapElement.node!
  * minZoom: 6,
    maxZoom: 14,
    zoom: 7,
    center: [49.78, 15.5]
    maxBounds: [[48.3,11.6], [51.3,19.1]]

baseLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
  * zIndex: 1
    opacity: 1
    attribution: 'mapová data &copy; přispěvatelé <a target="_blank" href="http://osm.org">OpenStreetMap</a>, obrazový podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

labelLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_l1/{z}/{x}/{y}.png"
  * zIndex: 3
    opacity: 0.75

layers =
  ["snatky_svobodni" "Svobodní" "svobodných" "u112103002"]
  ["snatky_sezdani"  "Sezdaní" "sezdaných" "u112103102"]
  ["snatky_rozvedeni" "Rozvedení" "rozvedených" "u112103202"]
  ["snatky_ovdoveli" "Ovdovělí" "ovdovělých" "u112103302"]
  ["snatky_vek"      "Průměrný věk" "průměrný věk" "u112102801"]
  # ["snatky_verici"   "Věřící" "vozidel" "celkem"]


layers_assoc = {}
layer_meta = {}
for [id, name, plural, property]:meta in layers
  layer = L.tileLayer.betterWms do
    * "https://samizdat.cz/proxy/smz_map/wms"
    * layers: 'opengeo:snatky_demo_webmrc'
      format: 'image/png'
      styles: id
      zIndex: 2
      opacity: 0.8
  layers_assoc[name] = layer
  layer_meta[name] = meta

layerControl = L.control.layers do
  layers_assoc
  {}
  collapsed: no
  autoZIndex: no


layerControl
  ..addTo map
currentMeta = null
currentLayer = null
map.on \baselayerchange (layer) ->
  currentLayer := layer.layer
  currentMeta := layer_meta[layer.name]

map
  ..addLayer baseLayer
  ..addLayer layers_assoc["Svobodní"]
  ..addLayer labelLayer
popup = L.popup!
map.on \click (evt) ->
  url = currentLayer.getFeatureInfoUrl evt.latlng
  (err, data) <~ d3.json url
  return if err
  return unless data.features.length
  {properties} = data.features.0
  console.log currentLayer
  total = properties['u111100101']
  rate = properties[currentMeta.3]
  num = Math.round rate / 100 * total

  text = "<b>#{properties.nazob}</b><br>"
  if currentMeta.0 == "snatky_vek"
    text += "Průměrný věk v této obci je <b>#{ig.utils.formatNumber rate, 2} let"
  else
    text += "V této obci žije <b>#{ig.utils.formatNumber rate, 2} % #{currentMeta.2}</b><br>(#{num} z #{ig.utils.formatNumber total}</b> obyvatel)"
  popup
    ..setLatLng evt.latlng
    ..setContent text
    ..openOn map


geocoder = new ig.Geocoder ig.containers.base
  ..on \latLng (latlng) ->
    map.setView latlng, 12
