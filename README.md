# inspec-log4j

This profile scans for vulnerable versions of Log4j Core JAR files directly on the file system, and embedded in WAR files.

## Running the profile locally

```
git clone https://github.com/trickyearlobe/inspec-log4j
inspec exec inspec-log4j
```

## Running the profile against a remote SSH target

Ensure you have SSH keys loaded for a privileged user (such as root) on the target.
Alternatively, check the [CLI docs](https://docs.chef.io/inspec/cli/) to see how to use Inspec with SUDO

```
git clone https://github.com/trickyearlobe/inspec-log4j
inspec exec inspec-log4j -t ssh://root@host
```

## Packaging the profile for upload to Chef Automate

```
git clone https://github.com/trickyearlobe/inspec-log4j
inspec archive inspec-log4j
```
