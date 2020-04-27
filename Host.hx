// Host.hx
class Host {
  static public function main():Void {
    trace('Hello from cppia HOST');
    var scriptname = 'bin/script.cppia';             
    cpp.cppia.Host.runFile(scriptname);  // <- load and execute the .cppia script file 
  }
}
