import com.raidandfade.haxicord.types.structs.Embed;
import com.raidandfade.haxicord.types.*;
import haxe.Serializer;
import haxe.Unserializer;
import com.raidandfade.haxicord.utils.DPERMS;
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

class Checks {
  public static function isAdmin(member){ return member.hasPermissions(DPERMS.ADMINISTRATOR); }
  public static function isOwner(user){ return user.id.toString() == "206903283090980864"; }
  public static function isModerator(member){
	return (member.hasPermissions(DPERMS.BAN_MEMBERS) && member.hasPermissions(DPERMS.KICK_MEMBERS) && member.hasPermissions(DPERMS.MANAGE_MESSAGES));
  }
  public static function isGuild(ctx, guildname:String):Bool {return true;}
  public static function hasRole(ctx, rolename:String):Bool {return true;}
  public static function hasRoles(ctx, rolenames:Array<String>):Bool {return true;}
}



class Dice {
  public static function roll(notation:String):Dynamic{
	if(!notation.contains("d")){ return {result:"Invalid dice notation ((num)d(sides)[+(mod)])", rolls: new Array<Int>(), error: true, total: 0, sides: 0, mod: 0, dice: 0 }};
	var sides:Int = 0;
	var mod:Int = 0;
	var dice:Int = notation.split("d")[0].toInt();
	var total:Int = 0;
	var rolls:Int = 0;
	var rolledDice = new Array<Int>();

	if(notation.split("d")[1].contains("+")){
	  mod = notation.split("d")[1].split("+")[1].toInt();
	  sides = notation.split("d")[1].split("+")[0].toInt();
	}else{
	  sides = notation.split("d")[1].toInt(); 
	}
	if(dice < 1) { dice = 1; }
	if(sides < 2) { sides = 6; }
	
	while(rolls < dice){
	  var r = Std.random(sides) + 1;
	  total = total + r;
	  rolledDice.push(r);
	  rolls = rolls + 1;
	}

	return{result: 'Sides: $sides - Dice: $dice (+ $mod) = $total\n${rolledDice.join(" | ")}',  rolls: rolledDice, error: false, total: total, sides: sides, dice: dice, mod: mod};
  }
}
