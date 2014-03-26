// open a single window
var win = Ti.UI.createWindow({
  backgroundColor:'white'
});
var btn = Ti.UI.createButton({
  title:'add',
  color:'#ff0000',
  height:47,
  top:30
});
win.add(btn);
var removeBtn = Ti.UI.createButton({
  title:'remove',
  color:'#ff0000',
  height:47,
  top:60
});
win.add(removeBtn);
win.open();

var DtectorGeoFencing = require('jp.dtector.geofencing');
Ti.API.info("module is => " + DtectorGeoFencing);

DtectorGeoFencing.addEventListener('enter', function(e) {
  Ti.API.debug("enter!: " + e.identifier);
  alert("enter into " + e.identifier + "!!");
});
DtectorGeoFencing.addEventListener('exit', function(e) {
  Ti.API.debug("exit!: " + e.identifier);
  Ti.API.debug("exited from " + e.identifier + "!!");
});
DtectorGeoFencing.addEventListener('monitor', function(e) {
  Ti.API.debug("monitoring: " + e.identifier);
});
DtectorGeoFencing.addEventListener('fail', function(e) {
  Ti.API.debug(JSON.stringify(e));
});
add = function(e) {
  DtectorGeoFencing.addRegion({
    identifier: 'shibuya station',
    latitude: 35.658693,
    longitude: 139.701535,
    radius: 100
  });
  console.log(JSON.stringify(DtectorGeoFencing.monitoredRegions()));
}
btn.addEventListener('click', add);
removeBtn.addEventListener('click', function() { DtectorGeoFencing.removeRegion('shibuya station'); });
