import haxe.Json;
import haxe.Http;

class Trinet {
  public var servers:Array<Dynamic>;
  public var baseURL:String;

  public function new(baseURL:String = "http://333networks.com/json/"){
	this.servers = new Array<Dynamic>();
	this.baseURL = baseURL;
  }

  function sortCache(data:String){
	var result = haxe.Json.parse(data);
  }
  
  public function getGame(game:String){
	this.servers = new Array<Server>();
	var http = new haxe.Http(this.baseURL+game);
	http.onData = sortCache;
	http.onError = function (error) {trace('error: $error');}
	http.request();
  }
  
  public function getServer(gamehost:String){
	this.servers = new Array<Server>();
	var http = new haxe.Http(this.baseURL+gamehost);
	http.onData = sortCache;
	http.onError = function (error) {trace('error: $error');}
	http.request();
  }  
}