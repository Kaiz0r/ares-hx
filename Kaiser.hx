package;
import com.raidandfade.haxicord.DiscordClient;
//import com.raidandfade.haxicord.types.Message;
//import com.raidandfade.haxicord.types.User;
//import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.*;
//import com.raidandfade.haxicord.types.MessageChannel;
//import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.structs.Embed;
//import com.raidandfade.haxicord.types.structs.EmbedAuthor;
import haxe.Json;
//import haxe.Exception;
import com.raidandfade.haxicord.utils.DPERMS;
import MScript;
import Utils;
import hscript.Parser;
import hscript.Expr;
import hscript.Interp;
import Console;
using StringTools;
using Ext;

import Commands;
import Net;

class Context {
  public var message:Message;
  public var channel:MessageChannel;
  public var user:GuildMember;
  public var member:GuildMember;
  public var guild:Guild;
  public var client:DiscordClient;
  public var args:Array<String>;
  public var argsRaw:String;
  public var commandNameRaw:String;
  public var commandName:String;
  public var command:Command;
  public var config:Memory;
  public var commandManager:CommandManager;
  
  public function new(client, message) {
	this.client = client;
	this.message = message;
	this.channel = message.getChannel();
	this.user = message.getMember();
	this.member = message.getMember();
	this.guild = message.getGuild();
	var s = message.content.split(" ");
	this.commandNameRaw = s.shift();
	this.args = s;
	this.argsRaw = this.args.join(" ");
  }

  public function code(content:String, lang:String = ""){
	this.channel.sendMessage({content: "```"+lang+"\n"+content+"\n```"});
  }
  public function send(content:String){
	this.channel.sendMessage({content: content});
  }
  public function sendEmbed(embed:Embed){
	this.channel.sendMessage({embed: embed});
  }
}

class Command {
  public var name:String;
  public var brief:String;
  public var usage:String = "";
  public var help:String;
  public var aliases:Array<String> = [];
  public var tags:Array<String> = [];
  public var execute:Context->Void;
  public var group:String = "default";
  public var manager:CommandManager;
  
  public function new(manager, name, fn:Context->Void) {
	this.execute = fn;
	this.name = name;
	this.manager = manager;
	this.manager.gIndex["default"].push(this.name);
  }

  public function setHelp(hs:String){
	this.help = hs;
	return this;
  }
  
  public function setBrief(s:String){
	this.brief = s;
	return this;
  }

  public function setUsage(s:String){
	this.usage = s;
	return this;
  }

  public function setGroup(s:String){
	if(!this.manager.gIndex.exists(s)){
	  this.manager.gIndex[s] = [];
	}
	this.manager.gIndex[this.group].remove(this.name);
	this.manager.gIndex[s].push(this.name);
	this.group = s;
	return this;
  }
  public function setTags(s:Array<String>){
	this.tags = s;
	return this;
  }
  
  public function removeTag(s:String){
	if(!this.hasTag(s)){return this;}
	this.tags.remove(s);
	return this;
  }
  
  public function addTag(s:String){
	this.tags.push(s);
	return this;
  }

  public function hasTag(s:String):Bool{
	if(this.tags.indexOf(s) != -1){
	  return true;
	}
	return false;
  }

  public function setAliases(s:Array<String>){
	this.aliases = s;
	return this;
  } 
}

class CommandManager {
  public var store = new Map<String, Dynamic>();
  public var commands = new Map<String, Command>();
  public var gIndex = new Map<String, Array<String>>();
  public var cfg = new Memory("config");
  public var prefix:String;

  public function new(prefix:String)  {
	this.prefix = prefix;
	if (this.prefix == null){this.prefix = ".";}
	gIndex["default"] = [];
	
  	registerCommand("echo", function(ctx:Context){
		ctx.send(ctx.argsRaw);
		ctx.message.react("<:gag:684503354323501116>");
	  }).setBrief("I repeat, echo.").setUsage("[msg]");
	
  	registerCommand("kill", function(ctx:Context){
		ctx.send("Goodbye.");
		Sys.exit(0);
	  }).setGroup("internal").setTags(["$owner"]).setAliases(['die', "shutdown", "exit", "quit"]);
	
  	registerCommand("eval", function(ctx:Context){
		var script = ctx.argsRaw;
		var parser = new hscript.Parser();
		parser.allowTypes = true;

		//try {
		var program = parser.parseString(script);// }catch(e:Any){ctx.send(Std.string(e));}
		
		//try {
		var interp = new hscript.Interp();// }catch(e:Any){ctx.send(Std.string(e));}
		interp.variables.set("Math",Math); // share the Math class
		interp.variables.set("ext",this);
		interp.variables.set("ctx",ctx);
		interp.variables.set("Sys",Sys);
		interp.variables.set("echo",function(message:String){ctx.send(message);});
		interp.variables.set("client",ctx.client);
		interp.variables.set("message",ctx.message);
		interp.variables.set("guild",ctx.guild);
		interp.variables.set("channel",ctx.channel);
		interp.variables.set("code",ctx.code);
		interp.variables.set("sendEmbed",ctx.sendEmbed);
		interp.variables.set("EmbedBuilder",Utils.EmbedBuilder.new);
		//interp.variables.set("Embed",Embed);
		try {
		  var out = interp.execute(program);

		  if(out != null){
			ctx.send(out);
		  }
		} catch(e:Any) {
		  //All exceptions will be caught here
		  ctx.send("`"+Std.string(e)+"`");
		}

	  }).setBrief("Eval Haxe code.").setUsage("[msg]").setTags(["$owner"]);
	
	registerCommand("set", function(ctx:Context){
		var key = ctx.args.shift();
		var value = ctx.args.join(" ");
		cfg.set(key, value);
		ctx.channel.sendMessage({content: 'Will set $key to $value'});
	  }).setGroup("admin").setUsage("[key] [value]").setHelp("Data is cerealized after parsing in to a delicious bowl of Golden Grahams... wait, I mean serialized in to a string format.... far less delicious.").addTag("$owner");
	
  	registerCommand("get", function(ctx:Context){
		var key = ctx.args.shift();
		var value = cfg.get(key);
		ctx.channel.sendMessage({content: '$key = $value'});
	  }).setGroup("admin").addTag("$owner").setUsage("[key]");
	
	registerCommand("enable", function(ctx:Context){
		if (this.commands.exists(ctx.args[0])){
		  if(this.commands[ctx.args[0]].hasTag("$disabled")){
			this.commands[ctx.args[0]].removeTag("$disabled");
			ctx.send("Command enabled.");
		  }else{
			ctx.send("Command is already enabled.");
		  }
		}
	  }).setGroup("admin").addTag("$owner").setUsage("[command]");
	
	registerCommand("disable", function(ctx:Context){
		if (this.commands.exists(ctx.args[0])){
		  if(!this.commands[ctx.args[0]].hasTag("$disabled")){
			this.commands[ctx.args[0]].addTag("$disabled");
			ctx.send("Command disabled.");
		  }else{
			ctx.send("Command is already disabled.");
		  }
		}
	  }).setGroup("admin").addTag("$owner").setUsage("[command]");
	
  	registerCommand("help", function(ctx:Context){
		if(ctx.args.length != 0){
		  if (this.commands.exists(ctx.args[0])){
			var c = this.commands[ctx.args[0]];
			var out = "```hx\n";
			var name:String = c.name;
			
			if (c.aliases.length > 0){
			  name = "["+c.name+"|"+c.aliases.join("|")+"]";
			}
			  
		    out = out+"# "+this.prefix+name+" "+c.usage;
			if(c.help != null){
			  out = out+"\n\t"+c.help+"\n";
			}

			if(c.tags.length > 0){out = out + "\nTags: " + c.tags.join(" ");}
			out = out+"```";
			ctx.send(out);
		  }else if (this.gIndex.exists(ctx.args[0])){
			var grp = this.gIndex[ctx.args[0]];
			var out = "```hx\n# "+ctx.args[0]+"\n";

			for (command in grp){
			  var c = getCommand(command);
			  if(!c.hasTag("$hidden")){
				
				out = out+"// "+c.name+"\n";
				if(c.brief != null){out = out+"\t\""+c.brief+"\"\n";}
			  }
			}

			out = out+"\n```";
			ctx.send(out);
		  }else{
			ctx.send("Command or group `"+ctx.args[0]+"` not found.");
		  }
		  
		}else{
		  var out:String = "```hx\n@: Ares.hx (Haxe->HashLink) "+cfg.get('version')+"\n";

		  for (group in this.gIndex.keys()){
			if(group == "internal"){continue;}
			var commands:Int = 0;
			var cmdStr:String = "";
			for (command in this.gIndex[group]){
			  var c = this.getCommand(command);
			  if(!c.hasTag("$hidden")){
				commands = commands + 1;
				cmdStr = cmdStr+"// "+c.name+"\n";
				if(c.brief != null){cmdStr = cmdStr+"\t\""+c.brief+"\"\n";}
			  }
			}
			if (commands > 0){	out = out+"\n#"+group+"\n";out = out+cmdStr;}
		  }
		
		  out = out + "\n\n@: "+this.prefix+"help <command> for detailed information.```";
		
		  ctx.send(out);

		}
	  }).setGroup("internal").addTag("$hidden");

	new OtherCommands(this);
	new NetCommands(this);
  }

  public function getCommand(name:String):Command {
	return this.commands.get(name);
  }

  public function registerCommand(name, fn:Context->Void) {
    commands[name] = new Command(this, name, fn);
	return commands[name];
  }

  public function processCommands(client:DiscordClient, input:Message){
	var name:String = "";
	var fm:String = "";
	
	if(input.content != "" && input.content != null){
	  if(input.getMember() != null){
		if(input.getMember().displayName != null){
		  name = input.getMember().displayName;
		}else{
		  name = input.author.username;
		}
		var c:String = Reflect.field(input.getChannel(), "name");
		fm = '${name} <i,light_blue>(${c}.${input.getGuild().name})';
	  }else{
		name = input.author.username;
		fm = '${name}';
	  }

	  if(input.getMember().user.bot){
		Console.log('🤖 <blue>${fm}<reset>: ${input.content}');
	  }else if(input.getMember().hasPermissions(DPERMS.ADMINISTRATOR)){
		Console.log('🔨 <red>${fm}<reset>: ${input.content}');
	  }else if(Checks.isModerator(input.getMember())){
		Console.log('🛡 <red>${fm}<reset>: ${input.content}');
	  }else{
		Console.log('<green>${fm}<reset>: ${input.content}');
	  }
	}

	if(input.content.startsWith(this.prefix)){
	  var newContext = new Context(client, input);
	  newContext.commandName = newContext.commandNameRaw.replace(this.prefix, '');
	  newContext.config = cfg;
	  newContext.commandManager = this;
	  
	  for (command in commands){
		if(command.name == newContext.commandName || command.aliases.indexOf(newContext.commandName) != -1){
		  if(command.hasTag("$disabled")){
			var em = new EmbedBuilder().setDescription("Command unavailable.").setColour(0xFF0000).toStruct();
			newContext.sendEmbed(em);
			return;
		  }
		  
		  if(command.hasTag("$admin") && !input.getMember().hasPermissions(DPERMS.ADMINISTRATOR)){
			var em = new EmbedBuilder().setDescription("You do not have the permissions for this command.").setColour(0xFF0000).toStruct();
			newContext.sendEmbed(em);
			return;
		  }
		  
		  if(command.hasTag("$owner") && input.getMember().user.id.toString() != "206903283090980864"){
			var em = new EmbedBuilder().setDescription("You do not have the permissions for this command.").setColour(0xFF0000).toStruct();
			newContext.sendEmbed(em);
			return;
		  }
		  
		  newContext.command = command;
		  command.execute(newContext);
		  return;
		}
	  }
		
	}
  }
}

