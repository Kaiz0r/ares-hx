package;
import com.raidandfade.haxicord.websocket.WebSocketConnection;
import haxe.Json;
import haxe.Timer;
import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.structs.*;
import Kaiser;

class Ares {
  static var client:DiscordClient;
  static var cmd:CommandManager;
  
  static function main() {
	client = new DiscordClient(Sys.getEnv("BOT_TOKEN"));
	cmd = new CommandManager(Sys.getEnv("BOT_PREFIX"));
	
	client.onMessage = function(msg){cmd.processCommands(client,msg);}
	//kaiser = new KUtil();
	//kaiser.KPrint();
	client.onReady = function(){client.setActivity({name:"Haxe", type:0});}

  }
  
  public static function onMessage(msg:Message){
	if(msg.content != "" && msg.content != null){
	  Sys.println('${msg.content}');
	}
  }
}