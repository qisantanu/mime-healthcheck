#!/bin/bash
set -euo pipefail

WAR_ORIG=/home/in-lt-89/dev/mima-healthcheck/mima-healthcheck.war
WAR_NEW=/home/in-lt-89/dev/mima-healthcheck/mima-healthcheck-mima.war
STDLIB_ENTRY=WEB-INF/lib/jruby-stdlib-9.3.10.0.jar
STDLIB_NAME=jruby-stdlib-9.3.10.0.jar
RVM=/home/in-lt-89/.rvm/rubies/jruby-9.3.10.0
WORK=/tmp/mima_war_overlay

rm -rf $WORK && mkdir -p $WORK && cd $WORK

echo "==> clone WAR"
cp "$WAR_ORIG" "$WAR_NEW"

echo "==> explode stdlib jar"
mkdir a && (cd a && unzip -q "$WAR_NEW" "$STDLIB_ENTRY")
mkdir b && (cd b && unzip -q "../a/$STDLIB_ENTRY")

ROOT=$WORK/b/META-INF/jruby.home/lib/ruby

echo "==> overlay stdlib/jars"
rm -rf "$ROOT/stdlib/jars"
cp -a "$RVM/lib/ruby/stdlib/jars" "$ROOT/stdlib/jars"

echo "==> swap default gemspec"
SPECS=$ROOT/gems/shared/specifications/default
rm -f "$SPECS"/jar-dependencies-*.gemspec
cp "$RVM/lib/ruby/gems/shared/specifications/default/jar-dependencies-0.6.0.pre3-java.gemspec" "$SPECS/"

echo "==> replace gems/jar-dependencies-*"
rm -rf "$ROOT/gems/shared/gems"/jar-dependencies-*
cp -a "$RVM/lib/ruby/gems/shared/gems/jar-dependencies-0.6.0.pre3" "$ROOT/gems/shared/gems/"

echo "==> patch .jrubydir files"
sed -i 's|^jar-dependencies-[0-9].*\.gemspec$|jar-dependencies-0.6.0.pre3-java.gemspec|' "$SPECS/.jrubydir"
sed -i 's|^jar-dependencies-[0-9][^ ]*$|jar-dependencies-0.6.0.pre3|' "$ROOT/gems/shared/gems/.jrubydir"

new_jrubydir () {
  local d=$1
  { echo ".."; echo "."; (cd "$d" && ls -A | grep -v '^\.jrubydir$'); } > "$d/.jrubydir"
}
new_jrubydir "$ROOT/stdlib/jars"
new_jrubydir "$ROOT/stdlib/jars/mima"
new_jrubydir "$ROOT/gems/shared/gems/jar-dependencies-0.6.0.pre3"
new_jrubydir "$ROOT/gems/shared/gems/jar-dependencies-0.6.0.pre3/bin"

echo "==> repack stdlib jar"
(cd b && zip -qr "$WORK/$STDLIB_NAME" .)

echo "==> swap into WAR"
mkdir -p c/WEB-INF/lib && cp "$WORK/$STDLIB_NAME" c/WEB-INF/lib/
zip -d "$WAR_NEW" "$STDLIB_ENTRY" > /dev/null
(cd c && zip -q "$WAR_NEW" "$STDLIB_ENTRY")

echo "==> verify"
mkdir v && (cd v && unzip -oq "$WAR_NEW" "$STDLIB_ENTRY")
echo "-- Jars::VERSION inside patched WAR --"
unzip -p "v/$STDLIB_ENTRY" META-INF/jruby.home/lib/ruby/stdlib/jars/version.rb
echo "-- WAR --"; ls -la "$WAR_NEW"
echo "==> DONE"
