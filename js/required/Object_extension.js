// Transforme un Array qui contient des objects en object
// Typiquement utilisé avec serializeArray de jQuery
window.hash = function(object, k_key, k_value){
  if('undefined' == typeof k_key)   k_key   = 'name' ;
  if('undefined' == typeof k_value) k_value = 'value' ;
  var h = {}, sobj, key, val ;
  for(var i=0, len = object.length; i < len ; ++i){
    sobj = object[i] ;
    key  = sobj[k_key] ;
    val  = sobj[k_value] ;
    h[key] = val ;
  }
  return h ;
}