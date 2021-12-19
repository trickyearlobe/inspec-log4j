# Scan for .jar/.war in combined operation to prevent multiple scans
if os[:platform][:family] == 'windows'
  files_to_scan = command('[System.IO.DriveInfo]::GetDrives() | Where-Object -Property DriveType -eq Fixed | foreach { (Get-ChildItem $_.Name -Include "log4j-core*.jar", "*.war" -Recurse -ErrorAction SilentlyContinue).FullName }').stdout.split(/\r?\n/)
else
  files_to_scan = command("df -lP | awk {'if (NR!=1) print $6'} | xargs -I FILESYSTEM find FILESYSTEM -xdev -name 'log4j-core*.jar' -o -name '*.war'").stdout.split(/\r?\n/)
end

jars_to_scan = files_to_scan.select{|e| File.extname(e)=='.jar'}.uniq
wars_to_scan = files_to_scan.select{|e| File.extname(e)=='.war'}.uniq

control 'log4j-core-versions' do
  impact 0.5
  title 'Log4j Core JARs should be 2.16.0 or higher'
  desc 'Versions of Apache Log4j older than 2.16.0 may be vulnerable to CVE-2021-44228 and CVE-2021-45046 which allow exploitation JNDI lookups to inject malicious code'

  tag cve: 'CVE-2021-44228'
  ref 'CVE-2021-44228', url: 'https://logging.apache.org/log4j/2.x/security.html'

  jars_to_scan.each do |path|
    describe jar_file(path: path) do
      its('version') { should be >= JarVersion.new('2.16.0') }
    end
  end
end

control 'log4j-core-jar-patching' do
  impact 1.0
  title 'Log4j Core JARs should not contain JndiLookup.class'
  desc 'Versions of Apache Log4j older than 2.16.0 can be patched against CVE-2021-44228 and CVE-2021-45046 by removing their JndiLookup.class'

  tag cve: 'CVE-2021-44228'
  ref 'CVE-2021-44228', url: 'https://logging.apache.org/log4j/2.x/security.html'

  jars_to_scan.each do |path|
    describe jar_file(path: path) do
      its('classes') { should_not include 'JndiLookup.class' }
    end
  end
end

control 'log4j-war-files' do
  impact 1.0
  title 'Log4j Core JARs embedded in WAR files'
  desc 'Log4j Core JARs vulnerable to CVE-2021-44228 and CVE-2021-45046 may be packaged in WAR files. Vulnerable versions are defined as older than 2.16.0'

  tag cve: 'CVE-2021-44228'
  ref 'CVE-2021-44228', url: 'https://logging.apache.org/log4j/2.x/security.html'

  wars_to_scan.each do |path|
    describe war_file_jar(path: path, jar: 'log4j-core') do
      if described_class.jar
        its('jar.version') { should be >= JarVersion.new('2.16.0') }
        its('jar.classes') { should_not include "JndiLookup.class" }
      else
        its('jar') { should be nil }
      end
    end
  end
end
