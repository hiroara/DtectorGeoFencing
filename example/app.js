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
var listBtn = Ti.UI.createButton({
  title:'list',
  color:'#ff0000',
  height:47,
  top:90
});
win.add(listBtn);
win.open();

var DtectorGeoFencing = require('jp.dtector.geofencing');
Ti.API.info("module is => " + DtectorGeoFencing);

DtectorGeoFencing.addEventListener('enter', function(e) {
  Ti.API.debug(JSON.stringify(e));
  alert("enter into " + e.identifier + "!!");
});
DtectorGeoFencing.addEventListener('exit', function(e) {
  Ti.API.debug(JSON.stringify(e));
  alert("exited from " + e.identifier + "!!");
});
DtectorGeoFencing.addEventListener('monitor', function(e) {
  Ti.API.debug(JSON.stringify(e));
  alert("monitoring " + e.identifier + "!!");
});
DtectorGeoFencing.addEventListener('fail', function(e) {
  Ti.API.debug(JSON.stringify(e));
  alert("failed to monitor " + e.identifier + "...");
});
add = function(e) {
  DtectorGeoFencing.addRegion({
    identifier: 'shibuya station',
    latitude: 35.658693,
    longitude: 139.701535,
    radius: 100
  });
}
btn.addEventListener('click', add);
removeBtn.addEventListener('click', function() {
  DtectorGeoFencing.removeRegion('shibuya station');
});
listBtn.addEventListener('click', function() {
  console.log(JSON.stringify(DtectorGeoFencing.monitoredRegions()));
});
