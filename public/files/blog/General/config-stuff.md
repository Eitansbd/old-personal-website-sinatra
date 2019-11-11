A Collection of random configuration code that i've needed to use to get around problems with languages, libraries, cloud environments, deployments, and everything else that needs configuration

1) Rails Server on Cloud 9 
```
rails server -b $IP -p $PORT
```

2) Specifying rails version for a project without the headache
source: https://stackoverflow.com/questions/379141/specifying-rails-version-to-use-when-creating-a-new-application
```
mkdir myapp
cd myapp
echo "source 'https://rubygems.org'" > Gemfile
echo "gem 'rails', '<rails version you want>'" > Gemfile
bundle install

bundle exec rails new . --force --skip-bundle
bundle update
```

3) Specifying sqlite3 version when the Rails breaks and says it's not installed even though it is. 

Specified 'sqlite3' for database adapter, but the gem is not loaded. Add `gem 'sqlite3'` to your Gemfile (and ensure its version is at the minimum required by ActiveRecord).

```
specify sqlite3 version
gem 'sqlite3', '~> 1.3', '< 1.4'
```

4) Precompling assets for rails

When you get an error trying to load css files that assets not precompiled

https://stackoverflow.com/questions/42550603/rails-5-how-to-resolve-asset-was-not-declared-to-be-precompiled-in-production

```
# config/initializers/assets.rb

Rails.application.config.assets.precompile += %w( <filename> )

```