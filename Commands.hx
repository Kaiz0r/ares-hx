import MScript;
import Kaiser.Context;
import Kaiser.Command;
import Utils;
import haxe.Http;
import haxe.Json;
using StringTools;
using Ext;
import com.raidandfade.haxicord.utils.DPERMS;
import com.raidandfade.haxicord.types.*;
//import com.raidandfade.haxicord.types.MessageChannel;
//import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.structs.Embed;

class OtherCommands {
  public var golem:GolemParser;
  
  public function new(manager:Dynamic){
	this.golem = new MScript.GolemParser();
	
	manager.registerCommand("embed", function(ctx:Context){
		var embed = new EmbedBuilder().setDescription("this is a test").setAuthor({name: "Borker"}).setColour(0xFF0000).addField("field one", "is a field").addField("field two", "in theory, is also a field").setImage("https://cdn.discordapp.com/attachments/534070361155829796/687700372642332727/shut.jpg").setTimestamp(Date.now()).toStruct();
		ctx.channel.sendMessage({embed: embed});
		  
	  }).setAliases(["e"]).setGroup("internal");
	
	manager.registerCommand("choice", function(ctx:Context){
		var opt:Array<String> = [];
		if(ctx.argsRaw.contains(",")){
		  opt = ctx.argsRaw.split(",");
		}else if(ctx.argsRaw.contains("|")){
		  opt = ctx.argsRaw.split("|");
		}
		ctx.send(opt.choice());
	  }).setAliases(["choose"]).setUsage("[opt 1 (| or ,) opt 2 ...]");
	
	manager.registerCommand("dice", function(ctx:Context){
		var result = Dice.roll(ctx.argsRaw);
		ctx.send(result.result);
	  }).setAliases(["rand", "roll"]).setUsage("[optional number: max limit] = default 100");

	manager.registerCommand("8ball", function(ctx:Context){
		
	  }).setAliases(["8", "8b"]).setUsage("[prompt]");

	manager.registerCommand("coin", function(ctx:Context){

	  }).setAliases(["flip"]);
			
	manager.registerCommand("random", function(ctx:Context){
		var limit = 100;
		if (ctx.args.length > 0){
		  if(Std.parseInt(ctx.args[0]) != null){
			ctx.send("Value should be a number.");
			return;
		  }
		  limit = ctx.args[0].toInt();
		}
		ctx.send('(0 - $limit) -> ${Std.random(limit)}');
	  }).setAliases(["rand", "roll"]).setUsage("[optional number: max limit] = default 100");
	

	manager.registerCommand("golem", function(ctx:Context){
		this.golem.registerFn("discord", function(message){
			ctx.send(message);
		  });
		
		this.golem.registerFn("restart", function(message){
			this.golem.output("Restarting object...");
			var out = this.golem.buffer;
			this.golem = new MScript.GolemParser();
			this.golem.buffer = out;
		  });
		
		this.golem.parse(ctx.argsRaw);  
		if (this.golem.buffer.length > 0) {
		  ctx.send(this.golem.buffer.join("\n"));this.golem.buffer = [];
		}
		
	  }).setAliases(["g"]).setGroup("experiments").setBrief("Line-by-Line subscript parser").setHelp("A simple subscript that parses commands. Currently does not do anything really.");
	
  }
}