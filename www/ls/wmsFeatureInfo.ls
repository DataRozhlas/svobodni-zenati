# adapted from https://gist.github.com/rclark/6908938#file-l-tilelayer-betterwms-js-L33

L.TileLayer.BetterWMS = L.TileLayer.WMS.extend do
  getFeatureInfoUrl: (latlng) ->
    point = this._map.latLngToContainerPoint(latlng, this._map.getZoom())
    size = this._map.getSize()

    params = {
      request: 'GetFeatureInfo',
      service: 'WMS',
      srs: 'EPSG:4326',
      styles: this.wmsParams.styles,
      transparent: this.wmsParams.transparent,
      version: this.wmsParams.version,
      format: this.wmsParams.format,
      bbox: this._map.getBounds().toBBoxString(),
      height: size.y,
      width: size.x,
      layers: this.wmsParams.layers,
      query_layers: this.wmsParams.layers,
      info_format: 'application/json'
    };

    params[if params.version == '1.3.0' then 'i' else 'x'] = point.x;
    params[if params.version == '1.3.0' then 'j' else 'y'] = point.y;

    this._url + L.Util.getParamString(params, this._url, true);


L.tileLayer.betterWms = (url, options) ->
  new L.TileLayer.BetterWMS(url, options)
