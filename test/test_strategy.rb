$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require 'test/unit'
require 'systemu'
require 'fileutils'
include FileUtils

class TestStrategy<Test::Unit::TestCase
  def setup
    @tmp='./tmp'
    rm_rf(@tmp) if File.exists?(@tmp)
    mkdir_p(@tmp)
    stdin=File.join(@tmp,'stdin')
    stdout=File.join(@tmp,'stdout')
    stderr=File.join(@tmp,'stderr')
    @sys=SystemUniversal.new(['echo','check'])
    @c={'argv'=>['echo','check'],'env'=>nil,'cwd'=>nil,'stdin'=>stdin,'stdout'=>stdout,'stderr'=>stderr}
  end
  def test_inspect
    assert_equal("      argv = [\"echo\", \"check\"]\n      env = nil\n      cwd = nil\n      stdin = \"./tmp/stdin\"\n      stdout = \"./tmp/stdout\"\n      stderr = \"./tmp/stderr\"\n",@sys.serialization_snippet(@c,:inspect))
    
    assert_equal("      argv = [\"echo\", \"check\"]\n      env = nil\n      cwd = nil\n      stdin = \"./tmp/stdin\"\n      stdout = \"./tmp/stdout\"\n      stderr = \"./tmp/stderr\"\n",@sys.choose_serialization(@tmp,@c,:inspect))
  end
  
  def test_yaml
    cfg_file=File.join(@tmp,'config')
    assert_equal("      begin\n        require 'psych'\n      rescue LoadError\n      end\n      require 'yaml'\n      config = YAML.load(IO.read('./tmp/config'))\n      \n      argv = config['argv']\n      env = config['env']\n      cwd = config['cwd']\n      stdin = config['stdin']\n      stdout = config['stdout']\n      stderr = config['stderr']\n",@sys.serialization_snippet(cfg_file,:yaml))
    @sys.choose_serialization(@tmp,@c,:yaml)
    assert(File.exists?(cfg_file), "No config dump")
    cfg=nil
    assert_nothing_raised() { cfg=YAML.load(IO.read(cfg_file)) }
    assert_equal(@c, cfg)
  end
  
  def test_marshal
    cfg_file=File.join(@tmp,'config')
    assert_equal("      config = Marshal.load(IO.read('./tmp/config'))\n      \n      argv = config['argv']\n      env = config['env']\n      cwd = config['cwd']\n      stdin = config['stdin']\n      stdout = config['stdout']\n      stderr = config['stderr']\n",@sys.serialization_snippet(cfg_file,:marshal))
    @sys.choose_serialization(@tmp,@c,:marshal)
    assert(File.exists?(cfg_file), "No config dump")
    cfg=nil
    assert_nothing_raised() { cfg=Marshal.load(IO.read(cfg_file)) }
    assert_equal(@c, cfg)
  end
end