package;
import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.TextChannel;
import com.raidandfade.haxicord.types.MessageChannel;
import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.structs.Embed;

class Context {
  public var message:Message;
  public var channel:MessageChannel;
  public var user:GuildMember;
  public var guild:Guild;
  public var client:DiscordClient;
  public var args:Array<String>;
  public var argsRaw:String;
  public var commandNameRaw:String;
  public var commandName:String;
  public var command:Command;
  
  public function new(client, message) {
	this.client = client;
	this.message = message;
	this.channel = message.getChannel();
	this.user = message.getMember();
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
