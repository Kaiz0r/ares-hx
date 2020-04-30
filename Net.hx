import Kaiser.Context;
import Kaiser.Command;
import Utils;
import haxe.Http;
import haxe.Json;
using StringTools;
using Ext;
import com.raidandfade.haxicord.utils.DPERMS;
import com.raidandfade.haxicord.types.*;
import com.raidandfade.haxicord.types.structs.Embed;

class NetCommands {
  public function new(manager:Dynamic){
	
	manager.registerCommand("tri", function(ctx:Context){
		var url:String = "http://333networks.com/json/"+ctx.argsRaw;
		  
		function sendOut(data:String){
		  Sys.println(data);
		  var e = new EmbedBuilder();
		  var j = haxe.Json.parse(data);

		  if(url.contains("/")){ //Server mode
			e.addField(j.hostname, 'Host: ${j.ip}:${j.hostport}\nGame: ${j.gametype}\nAdmin: ${j.adminname} (${j.adminemail})\nMap: ${j.mapname} (${j.maptitle})\nPlayers: ${j.numplayers}/${j.maxplayers}');
		  }else{ //MS-List mode
			//var list = j[0];
			trace(j.hostname);
			e.addField("test", "ignore");
			/*for(server in list){
			  e.addField('[${j.country}] ${j.hostname} (${j.ip}:${j.hostport})', 'Players: ${j.numplayers}/${j.maxplayers} | Map: ${j.mapname} | Game: ${j.gametype}');
			  }*/

		  }
		  
		  ctx.sendEmbed(e.toStruct());
		}
		var http = new haxe.Http(url);

		http.onData = sendOut;
		http.onError = function (error) { trace('error: $error'); }
		http.request();
	  }).setAliases(["list", "dx"]).setGroup("api").addTag("$disabled");

	manager.registerCommand("query", function(ctx:Context){
		var url:String = "https://api.wolframalpha.com/v1/simple?i="+ctx.args.join('%20').replace('?', '%3F')+"&appid="+ctx.config.get("wolfram");
		  
		function sendOut(data:Dynamic){
		  Sys.println(data);
		  //WriteAllText("wolfram.gif", data);
		  sys.io.File.saveBytes('wolfram.gif',data);
		  var r = new sys.io.Process("curl -i -F name=wolfram.gif -F file=@wolfram.gif https://uguu.se/api.php?d=upload-tool >> out.txt");
		  var content:String = sys.io.File.getContent('out.txt').split("\n").pop();
		  
		  ctx.send(content);
		}
		var http = new haxe.Http(url);

		http.onBytes = sendOut;
		http.onError = function (error) { trace('error: $error'); }
		http.request();
	  }).setAliases(["wq"]).setGroup("api");
		
	manager.registerCommand("wolfram", function(ctx:Context){
		var url:String = "https://api.wolframalpha.com/v1/result?i="+ctx.args.join('%20').replace('?', '%3F')+"&appid="+ctx.config.get("wolfram");

		function sendOut(data){
		  ctx.send(data);
		}
		var http = new haxe.Http(url);

		http.onData = sendOut;
		http.onError = function(err){ctx.send("No response.");};
		http.request();
 
	  }).setAliases(["wr"]).setGroup("api");
  }
}