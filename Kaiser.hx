package;
import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.TextChannel;
import com.raidandfade.haxicord.types.MessageChannel;
import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.structs.Embed;
//import com.raidandfade.haxicord.types.structs.EmbedAuthor;
import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;
import MScript;
using StringTools;
using Ext;

class EmbedBuilder {
  public var data:Embed;

  public function new(?data:Embed){
	if (data != null){this.data = data;}else{this.data = {};}
  }
  
  public function addField(title:String, value:String, _inline:Bool = false):EmbedBuilder {
	if(this.data.fields == null) {this.data.fields = new Array<EmbedField>();}
	var field = {name: title, value: value, _inline: _inline};
	this.data.fields.push(field);
	
	return this;
  }
  
  public function setImage(img:String):EmbedBuilder {
	this.data.image = {url: img};
	return this;
  }
  
  public function setThumbnail(img:String):EmbedBuilder {
	this.data.thumbnail = {url: img};
	return this;
  }
  
  public function setTimestamp(dt:Date):EmbedBuilder {
	this.data.timestamp = dt;
	return this;
  }
  
  public function setFooter(footer:EmbedFooter):EmbedBuilder {
	// icon_url, text
	this.data.footer = footer;
	return this;
  }

  public function setProvider(provider:EmbedProvider):EmbedBuilder {
	// name, url
	this.data.provider = provider;
	return this;
  }
  
  public function setAuthor(author:EmbedAuthor):EmbedBuilder {
	// icon_url, url, name
	this.data.author = author;
	return this;
  }
  
  public function setAuthorFromUser(author:GuildMember):EmbedBuilder {
	this.data.author = {};
	if (author.displayName != null){this.data.author.name = author.displayName;}else{this.data.author.name = author.user.username;}
	return this;
  }

  public function setColour(c:Int):EmbedBuilder {
	this.data.color = c;
	return this;
  }
  
  public function setTitle(text:String):EmbedBuilder {
	this.data.title = text;
	return this;
  }
  public function setUrl(url:String):EmbedBuilder {
	this.data.url = url;
	return this;
  }
  
  public function setDescription(text:String):EmbedBuilder {
	this.data.description = text;
	return this;
  }

  public function toStruct():Embed {
	return this.data;
  }
}

class Memory {
  public var cache:Map<String, String>;
  public var path:String;

  public function new(path:String){
	this.cache = new Map<String, String>();
	this.path = path;
	read();
  }

  public function read(){
	var content:String = sys.io.File.getContent(this.path);
	trace(content);
	var unserializer = new Unserializer(content);
	this.cache = unserializer.unserialize();
  }

  public function write(){
	var serializer = new Serializer();
	serializer.serialize(this.cache);
	var content = serializer.toString();//haxe.Json.stringify(this.cache);
	
	sys.io.File.saveContent(this.path,content);
  }

  public function get(key:String, def:String = "null"):String{
	if (this.cache.exists(key)) {
	  return this.cache.get(key);
	} else {
	  return def;
	}
  }
  
  public function getInt(key:String, def:Int = 0):Int{
	if (this.cache.exists(key)) {
	  return Std.parseInt(this.cache.get(key));
	} else {
	  return def;
	}
  }

  public function getFloat(key:String, def:Float = 0):Float{
	if (this.cache.exists(key)) {
	  return Std.parseFloat(this.cache.get(key));
	} else {
	  return def;
	}
  }
  
  public function set(key:String, value:String){
	trace(key);
	trace(value);
	this.cache[key] = value;
	write();
  }
}

class KUtil {
  
  public function new()  {}

  public function KPrint() {
    Sys.println("Hello from Kaiser!");
  }
}

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

  public function send(content:String){
	this.channel.sendMessage({content: content});
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
	
	registerCommand("test", function(ctx:Context){
		Sys.println("Test was tested.");
		ctx.channel.sendMessage({content: "This was tested."});
	  }).setAliases(["bork"]);
	
  	registerCommand("echo", function(ctx:Context){
		ctx.send(ctx.argsRaw);
	  }).setBrief("I repeat, echo.").setUsage("[msg]");
	
	registerCommand("set", function(ctx:Context){
		var key = ctx.args.shift();
		var value = ctx.args.join(" ");
		cfg.set(key, value);
		ctx.channel.sendMessage({content: 'Will set $key to $value'});
	  }).setGroup("admin").setBrief("Sets a config variable").setUsage("[key] [value]").setHelp("Data is cerealized after parsing in to a delicious bowl of Golden Grahams... wait, I mean serialized in to a string format.... far less delicious.");
	
  	registerCommand("get", function(ctx:Context){
		var key = ctx.args.shift();
		var value = cfg.get(key);
		ctx.channel.sendMessage({content: '$key = $value'});
	  }).setGroup("admin");
	
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
			out = out+"```";
			ctx.send(out);
		  }else if (this.gIndex.exists(ctx.args[0])){
			var grp = this.gIndex[ctx.args[0]];
			var out = "```hx\n# "+ctx.args[0]+"\n";

			for (command in grp){
			  var c = getCommand(command);
			  out = out+"// "+c.name+"\n";
			  if(c.brief != null){out = out+"\t\""+c.brief+"\"\n";}
			}

			out = out+"\n```";
			ctx.send(out);
		  }else{
			ctx.send("Command or group `"+ctx.args[0]+"` not found.");
		  }
		  
		}else{
		  var out:String = "```hx\n@: Ares.hx (Haxe->HashLink) "+cfg.get('version')+"\n";

		  for (group in this.gIndex.keys()){
			out = out+"\n#"+group+"\n";
			for (command in this.gIndex[group]){
			  var c = this.getCommand(command);					
			  out = out+"// "+c.name+"\n";
			  if(c.brief != null){out = out+"\t\""+c.brief+"\"\n";}
			}
		  }
		
		  out = out + "\n\n@: "+this.prefix+"help <command> for detailed information.```";
		
		  ctx.send(out);

		}
	  });

	new OtherCommands(this);
  }

  public function getCommand(name:String):Command {
	return this.commands.get(name);
  }

  public function registerCommand(name, fn:Context->Void) {
    commands[name] = new Command(this, name, fn);
	return commands[name];
  }

  public function processCommands(client:DiscordClient, input:Message){
	if(input.getMember() != null){
	  Sys.println('> ${input.getMember().displayName}: ${input.content}');
	}else{
	  Sys.println('> ${input.author.username}: ${input.content}');
	}

	if(input.content.startsWith(this.prefix)){
	  var newContext = new Context(client, input);
	  newContext.commandName = newContext.commandNameRaw.replace(this.prefix, '');
	  newContext.config = cfg;
	  newContext.commandManager = this;
	  
	  for (command in commands){
		//trace(command.aliases);
		//trace(newContext.commandName);
		//trace(command.aliases.indexOf(newContext.commandName));
		
		if(command.name == newContext.commandName || command.aliases.indexOf(newContext.commandName) != -1){
		  newContext.command = command;
		  command.execute(newContext);
		  return;
		}
	  }
		
	}
  }
}

class OtherCommands {
  public var golem:GolemParser;
  
  public function new(manager:Dynamic){
	this.golem = new MScript.GolemParser();
	
	manager.registerCommand("embed", function(ctx:Context){
		var embed = new EmbedBuilder().setDescription("this is a test").setAuthor({name: "Borker"}).setColour(0xFF0000).addField("field one", "is a field").addField("field two", "in theory, is also a field").setImage("https://cdn.discordapp.com/attachments/534070361155829796/687700372642332727/shut.jpg").setTimestamp(Date.now()).toStruct();
		ctx.channel.sendMessage({embed: embed});
		  
	  }).setAliases(["e"]);
	
	manager.registerCommand("choice", function(ctx:Context){
		var opt:Array<String> = [];
		if(ctx.argsRaw.contains(",")){
		  opt = ctx.argsRaw.split(",");
		}else if(ctx.argsRaw.contains("|")){
		  opt = ctx.argsRaw.split("|");
		}
		ctx.send(opt.choice());
	  }).setAliases(["choose"]);
	
	manager.registerCommand("random", function(ctx:Context){
		var limit = 100;
		if (ctx.args.length > 0){limit = ctx.args[0].toInt();}
		ctx.send('(0 - $limit) -> ${Std.random(limit)}');
	  }).setAliases(["rand", "roll"]);
	

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
		
	  }).setAliases(["g"]);
	
  }
}