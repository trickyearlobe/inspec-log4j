require 'zip'

class WarFileJar < Inspec.resource(1)
  name 'war_file_jar'
  desc 'Java JAR file contained in a WAR file'

  def initialize(opts={})
    @opts = opts
    raise "war_file_jar: Must supply path:" unless @opts[:path]
    raise "war_file_jar: Must supply jar:" unless @opts[:jar]
    @warfile = Zip::File.open(@opts[:path])
  end

  def war_file_names
    @warfile.entries.map{|e| e.name}
  end

  def jarfiles
    war_file_names.select{|e| File.extname(e)=='.jar'}
  end

  def jar_file_name
    jarfiles.select{|e| e.match @opts[:jar]}.first
  end

  def jar
    if jar_file_name
      inspec.jar_file(buffer: @warfile.read(jar_file_name))
    else
      nil
    end
  end

  def to_s
    "WAR File #{@opts[:path]} #{@opts[:jar]}"
  end
end