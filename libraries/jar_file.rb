require 'zip'

class ::JarVersion < Gem::Version
end

class JarFile < Inspec.resource(1)
  name 'jar_file'
  desc 'Java JAR file'

  def initialize(opts={})
    @opts = opts
    raise "jar_file: Must supply either path: or buffer:" unless (@opts[:path] || @opts[:buffer])
    @jarfile = Zip::File.open_buffer(inspec.file(@opts[:path]).content) if @opts[:path]
    @jarfile = Zip::File.open_buffer(@opts[:buffer]) if @opts[:buffer]
  end

  def filenames
    @jarfile.entries.map{|e| e.name}
  end

  def classes
    filenames.select{|e| File.extname(e)=='.class'}.map{|e| File.basename(e)}
  end

  def version
    ver ||= version_from_pom_properties
    ver ||= version_from_manifest
    ver ||= version_from_filename
    ver ||= JarVersion.new('0.0.0')
  end

  def version_from_manifest
    if manifest_file = filenames.select{|f| f.match "META-INF/MANIFEST.MF"}.first
      manifest = @jarfile.read(manifest_file)
      if version_line = manifest.lines.map{|l| l.strip}.select{|l| l.match "^Bundle-Version:|Specification-Version:|Implementation-Version:"}.first
        Inspec::Log.info "Version found in #{manifest_file}"
        JarVersion.new(version_line.split.last)
      else
        nil
      end
    end
  end

  def version_from_pom_properties
    if pom_properties_file = filenames.select{|f| f.match "^META-INF/maven/.*/pom.properties$"}.first
      pom_properties = @jarfile.read(pom_properties_file)
      if version_line = pom_properties.lines.map{|l| l.strip}.select{|l| l.match "^version=.*"}.first
        Inspec::Log.info "Version found in #{pom_properties_file}"
        JarVersion.new(version_line.split('=').last)
      else
        nil
      end
    else
      nil
    end
  end

  def version_from_filename
    digits = @opts[:path].scan(/.*-([\d\.]+)\.jar/)
    digits.empty? ? nil : JarVersion.new(digits.dig(0).dig(0))
  end

  def to_s
    "JAR File #{@opts[:path]}"
  end
end