# Mima Healthcheck

A minimal Rails 6.1 application designed to test `jar-dependencies` with [Mima](https://github.com/jruby/jruby/pull/9515) on JRuby and WebLogic 12c. This app validates that the Mima-based dependency resolution integrates correctly with:
- JRuby 9.3.10.0 (Java 8 compatible)
- `jar-dependencies` 0.6.0.pre3 (Mima-based)
- Oracle Enhanced adapter over JDBC
- WebLogic 12c application server

Related issue: [jruby/jar-dependencies#90](https://github.com/jruby/jar-dependencies/issues/90)

## Purpose

This app exists to verify that:
1. Mima-based `jar-dependencies` resolves jar artifacts correctly at boot
2. The app can run in a WebLogic WAR without `ruby-maven` or Maven build extensions
3. Oracle connectivity via JDBC jars works end-to-end

The `/health` endpoint serves as a smoke test, returning the JRuby version, jar-dependencies version, and database adapter type.

## Requirements

- **JRuby 9.3.10.0** with Mima-patched `jar-dependencies` 0.6.0.pre3
- **Ruby 2.6.8** (via JRuby)
- **Bundler 2.4.10**
- **Oracle 21c+ JDBC driver** (`ojdbc8.jar` already in `lib/`)
- **Oracle database** (configured in `config/database.yml`)
- **WebLogic 12c** (for WAR deployment; optional for dev testing)

## Setup (Development/Local Testing)

### 1. Set the Ruby version

```bash
rvm use jruby-9.3.10.0
```

Or ensure your shell's `$PATH` has a Mima-patched JRuby 9.3.10.0 first.

### 2. Install dependencies

```bash
bundle install
```

### 3. Configure database (optional, for health endpoint to work)

Edit `config/database.yml` to point to an accessible Oracle database. Example (production env):

```yaml
production:
  adapter: oracle_enhanced
  database: (DESCRIPTION=...)  # Your TNS connection string
  username: your_user
  password: your_pass
  pool: 5
```

### 4. Test locally

```bash
bundle exec rails s
```

Then:

```bash
curl http://localhost:3000/health
```

Expected output:
```
OK jruby=9.3.10.0 jar-dependencies=0.6.0.pre3 db=OracleEnhanced
```

## Deployment to WebLogic 12c

### 1. Build the WAR

```bash
bundle exec warble war
```

Produces `mima-healthcheck.war` (52 MB, embeds JRuby 9.3.10.0 and all gems).

### 2. Apply Mima overlay

The stock WAR bundles `jar-dependencies` 0.4.1 (legacy). To test Mima, overlay the Mima-patched version:

```bash
bash bin/mima_overlay.sh
```

Produces `mima-healthcheck-mima.war` (55.6 MB, Mima-patched). This script:
- Extracts the embedded `jruby-stdlib-9.3.10.0.jar`
- Replaces `stdlib/jars/` with Mima-based jar-deps files
- Updates `.jrubydir` manifests so JRuby's classloader finds the new files
- Swaps the old `jar-dependencies-0.4.1.gemspec` for `0.6.0.pre3-java.gemspec`
- Repacks and re-embeds the stdlib jar into the WAR

### 3. Deploy to WebLogic

1. **Admin Console** → Deployments → Install
2. **Upload** `mima-healthcheck-mima.war`
3. **Target** to your managed server (e.g., TDCID)
4. **Finish** → Wait for state = Active

### 4. Test

```bash
curl http://<weblogic-host>:7009/mima-healthcheck/health
```

Expected:
```
OK jruby=9.3.10.0 jar-dependencies=0.6.0.pre3 db=OracleEnhanced
```


## Testing Notes

### Local vs. WebLogic

- **Local (development)**: Runs against your shell's active JRuby (likely RVM-managed). Tests the app logic and controller.
- **WebLogic (production WAR)**: Runs against the embedded JRuby inside the WAR. Tests WAR classloader behavior, Mima integration, and app server interop.

The Mima overlay script ensures both the stock WAR and the Mima-patched WAR use the same underlying code; only the jar-dependencies version changes.

### Database connectivity

If the `/health` endpoint returns `db=OracleEnhanced` but queries fail, the issue is Oracle reachability, not jar-dependencies. The endpoint still proves:
1. JRuby booted
2. jar-dependencies loaded successfully
3. Rails initialized
4. The ActiveRecord adapter was recognized

### WebLogic deployment fails with "UnsupportedClassVersionError"

The WAR embeds JRuby 10.x (Java 21). WebLogic 12c runs Java 8. Solution: Rebuild the WAR with `jruby-jars` pinned to 9.3.10.0 (see `Gemfile`).

## References

- [Mima PR (jruby/jruby#9515)](https://github.com/jruby/jruby/pull/9515)
- [jar-dependencies issue #90](https://github.com/jruby/jar-dependencies/issues/90)
- [activerecord-oracle_enhanced-adapter](https://github.com/rsim/activerecord-oracle_enhanced)
- [Warbler](https://github.com/ruby-gradle/warbler)
