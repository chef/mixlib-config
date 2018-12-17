<!-- usage documentation: http://expeditor-docs.es.chef.io/configuration/changelog/ -->
# Change Log

<!-- latest_release -->
<!-- latest_release -->

<!-- release_rollup -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v2.2.18](https://github.com/chef/mixlib-config/tree/v2.2.18) (2018-12-17)

#### Merged Pull Requests
- Add github issue and PR templates [#68](https://github.com/chef/mixlib-config/pull/68) ([tas50](https://github.com/tas50))
- Resolve chefstyle and expeditor issues [#69](https://github.com/chef/mixlib-config/pull/69) ([tas50](https://github.com/tas50))
- Expand ruby testing in Travis [#70](https://github.com/chef/mixlib-config/pull/70) ([tas50](https://github.com/tas50))
- Standardize the gemfile and rakefile [#71](https://github.com/chef/mixlib-config/pull/71) ([tas50](https://github.com/tas50))
- Only ship the required library files in the gem artifact [#72](https://github.com/chef/mixlib-config/pull/72) ([tas50](https://github.com/tas50))
<!-- latest_stable_release -->

## [v2.2.13](https://github.com/chef/mixlib-config/tree/v2.2.13) (2018-07-12)

#### Merged Pull Requests
- Avoid converting to text representation when parsing JSON/TOML/etc [#66](https://github.com/chef/mixlib-config/pull/66) ([lamont-granquist](https://github.com/lamont-granquist))

## [v2.2.12](https://github.com/chef/mixlib-config/tree/v2.2.12) (2018-07-06)

#### Merged Pull Requests
- add is_default? inspection method [#65](https://github.com/chef/mixlib-config/pull/65) ([lamont-granquist](https://github.com/lamont-granquist))

## [v2.2.11](https://github.com/chef/mixlib-config/tree/v2.2.11) (2018-07-02)

#### Merged Pull Requests
- key? and has_key? should find subcontexts [#64](https://github.com/chef/mixlib-config/pull/64) ([lamont-granquist](https://github.com/lamont-granquist))

## [v2.2.10](https://github.com/chef/mixlib-config/tree/v2.2.10) (2018-07-02)

#### Merged Pull Requests
- remove hashrocket syntax [#62](https://github.com/chef/mixlib-config/pull/62) ([lamont-granquist](https://github.com/lamont-granquist))
- add `#key?` alias to `#has_key?` [#63](https://github.com/chef/mixlib-config/pull/63) ([lamont-granquist](https://github.com/lamont-granquist))

## [v2.2.8](https://github.com/chef/mixlib-config/tree/v2.2.8) (2018-06-13)

#### Merged Pull Requests
- fix style warnings with latest rubocop [#60](https://github.com/chef/mixlib-config/pull/60) ([thommay](https://github.com/thommay))
- Fix config_context_list/hash in strict mode [#57](https://github.com/chef/mixlib-config/pull/57) ([elyscape](https://github.com/elyscape))

## [v2.2.6](https://github.com/chef/mixlib-config/tree/v2.2.6) (2018-03-22)

#### Merged Pull Requests
- Adding support for reading from TOML files [#55](https://github.com/chef/mixlib-config/pull/55) ([tyler-ball](https://github.com/tyler-ball))

## [v2.2.5](https://github.com/chef/mixlib-config/tree/v2.2.5) (2018-02-09)

#### Merged Pull Requests
- Add support for reading from JSON files [#53](https://github.com/chef/mixlib-config/pull/53) ([tduffield](https://github.com/tduffield))

## [2.2.4](https://github.com/chef/mixlib-config/tree/2.2.4) (2016-09-02)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.2.3...2.2.4)

**Merged pull requests:**

- Allow a config context to be set from another config context [\#42](https://github.com/chef/mixlib-config/pull/42) ([mwrock](https://github.com/mwrock))
- Allow configuring contexts via block [\#35](https://github.com/chef/mixlib-config/pull/35) ([KierranM](https://github.com/KierranM))

## [2.2.3](https://github.com/chef/mixlib-config/tree/2.2.3) (2016-08-30)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.2.2...2.2.3)

**Merged pull requests:**

- Dont reset state during restore [\#40](https://github.com/chef/mixlib-config/pull/40) ([mwrock](https://github.com/mwrock))
- Ignore Gemfile.lock [\#39](https://github.com/chef/mixlib-config/pull/39) ([tas50](https://github.com/tas50))
- Update specs for rspec 3.0 [\#38](https://github.com/chef/mixlib-config/pull/38) ([tas50](https://github.com/tas50))
- Bump version to 2.2.2 [\#37](https://github.com/chef/mixlib-config/pull/37) ([jkeiser](https://github.com/jkeiser))

## [2.2.2](https://github.com/chef/mixlib-config/tree/2.2.2) (2016-08-22)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.2.1...2.2.2)

**Merged pull requests:**

- chefstyle fixes [\#33](https://github.com/chef/mixlib-config/pull/33) ([lamont-granquist](https://github.com/lamont-granquist))
- Add gemspec files to allow bundler to run from the gem [\#32](https://github.com/chef/mixlib-config/pull/32) ([ksubrama](https://github.com/ksubrama))
- Fix ruby warnings [\#30](https://github.com/chef/mixlib-config/pull/30) ([danielsdeleo](https://github.com/danielsdeleo))

## [v2.2.1](https://github.com/chef/mixlib-config/tree/v2.2.1) (2015-05-12)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.2.0...v2.2.1)

**Merged pull requests:**

- Revert "Rename has\_key? -\> key? \(BC compatible\)" [\#28](https://github.com/chef/mixlib-config/pull/28) ([jaym](https://github.com/jaym))

## [v2.2.0](https://github.com/chef/mixlib-config/tree/v2.2.0) (2015-05-11)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.1.0...v2.2.0)

**Merged pull requests:**

- Add license to gemspec and update other fields for new company name. [\#27](https://github.com/chef/mixlib-config/pull/27) ([juliandunn](https://github.com/juliandunn))
- Revert "Fix README typos" [\#23](https://github.com/chef/mixlib-config/pull/23) ([mriddle](https://github.com/mriddle))
- Fix README typos [\#22](https://github.com/chef/mixlib-config/pull/22) ([mriddle](https://github.com/mriddle))
- Rename has\_key? -\> key? \(BC compatible\) [\#21](https://github.com/chef/mixlib-config/pull/21) ([sethvargo](https://github.com/sethvargo))
- Fix strict mode errors to actually print symbol [\#20](https://github.com/chef/mixlib-config/pull/20) ([jkeiser](https://github.com/jkeiser))
- New policy files. [\#19](https://github.com/chef/mixlib-config/pull/19) ([sersut](https://github.com/sersut))

## [v2.1.0](https://github.com/chef/mixlib-config/tree/v2.1.0) (2013-12-05)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.1.0.rc.1...v2.1.0)

## [v2.1.0.rc.1](https://github.com/chef/mixlib-config/tree/v2.1.0.rc.1) (2013-12-05)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.0.0...v2.1.0.rc.1)

**Merged pull requests:**

- Add save/reset, reopen config\_context, = {} for contexts [\#18](https://github.com/chef/mixlib-config/pull/18) ([jkeiser](https://github.com/jkeiser))

## [v2.0.0](https://github.com/chef/mixlib-config/tree/v2.0.0) (2013-09-25)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.0.0.rc.5...v2.0.0)

## [v2.0.0.rc.5](https://github.com/chef/mixlib-config/tree/v2.0.0.rc.5) (2013-09-17)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.0.0.rc.4...v2.0.0.rc.5)

**Merged pull requests:**

- Define explicit getter/setter methods for configurables instead of relyi... [\#17](https://github.com/chef/mixlib-config/pull/17) ([jkeiser](https://github.com/jkeiser))

## [v2.0.0.rc.4](https://github.com/chef/mixlib-config/tree/v2.0.0.rc.4) (2013-09-16)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.0.0.rc.3...v2.0.0.rc.4)

**Merged pull requests:**

- Fix issue with Config\['a'\] = b [\#16](https://github.com/chef/mixlib-config/pull/16) ([jkeiser](https://github.com/jkeiser))

## [v2.0.0.rc.3](https://github.com/chef/mixlib-config/tree/v2.0.0.rc.3) (2013-09-13)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.0.0.rc.2...v2.0.0.rc.3)

**Merged pull requests:**

- Jk/dup defaults [\#15](https://github.com/chef/mixlib-config/pull/15) ([jkeiser](https://github.com/jkeiser))

## [v2.0.0.rc.2](https://github.com/chef/mixlib-config/tree/v2.0.0.rc.2) (2013-09-11)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v2.0.0.rc.1...v2.0.0.rc.2)

**Merged pull requests:**

- Make config\_strict\_mode on by default [\#13](https://github.com/chef/mixlib-config/pull/13) ([jkeiser](https://github.com/jkeiser))

## [v2.0.0.rc.1](https://github.com/chef/mixlib-config/tree/v2.0.0.rc.1) (2013-09-11)
[Full Changelog](https://github.com/chef/mixlib-config/compare/beta-1...v2.0.0.rc.1)

**Merged pull requests:**

- Jk/version2 [\#12](https://github.com/chef/mixlib-config/pull/12) ([jkeiser](https://github.com/jkeiser))
- Jk/strict [\#11](https://github.com/chef/mixlib-config/pull/11) ([jkeiser](https://github.com/jkeiser))
- Add Travis config, basic Gemfile [\#10](https://github.com/chef/mixlib-config/pull/10) ([jkeiser](https://github.com/jkeiser))
- Add context\(\) DSL for config classes [\#9](https://github.com/chef/mixlib-config/pull/9) ([jkeiser](https://github.com/jkeiser))
- Jk/configurables [\#8](https://github.com/chef/mixlib-config/pull/8) ([jkeiser](https://github.com/jkeiser))
- Methods uber alles [\#6](https://github.com/chef/mixlib-config/pull/6) ([danielsdeleo](https://github.com/danielsdeleo))
- Modernize [\#5](https://github.com/chef/mixlib-config/pull/5) ([danielsdeleo](https://github.com/danielsdeleo))
- add require 'rspec' to spec/spec\_helper.rb [\#2](https://github.com/chef/mixlib-config/pull/2) ([pravi](https://github.com/pravi))

## [beta-1](https://github.com/chef/mixlib-config/tree/beta-1) (2010-06-21)
[Full Changelog](https://github.com/chef/mixlib-config/compare/1.1.2...beta-1)

## [1.1.2](https://github.com/chef/mixlib-config/tree/1.1.2) (2010-06-21)
[Full Changelog](https://github.com/chef/mixlib-config/compare/1.1.2.rc01...1.1.2)

## [1.1.2.rc01](https://github.com/chef/mixlib-config/tree/1.1.2.rc01) (2010-06-16)
[Full Changelog](https://github.com/chef/mixlib-config/compare/alpha_deploy_4...1.1.2.rc01)

## [alpha_deploy_4](https://github.com/chef/mixlib-config/tree/alpha_deploy_4) (2010-02-28)
[Full Changelog](https://github.com/chef/mixlib-config/compare/alpha_deploy_3...alpha_deploy_4)

## [alpha_deploy_3](https://github.com/chef/mixlib-config/tree/alpha_deploy_3) (2010-02-28)
[Full Changelog](https://github.com/chef/mixlib-config/compare/alpha_deploy_2...alpha_deploy_3)

## [alpha_deploy_2](https://github.com/chef/mixlib-config/tree/alpha_deploy_2) (2010-02-28)
[Full Changelog](https://github.com/chef/mixlib-config/compare/1.1.0...alpha_deploy_2)

## [1.1.0](https://github.com/chef/mixlib-config/tree/1.1.0) (2010-02-28)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v1.0.12...1.1.0)

## [v1.0.12](https://github.com/chef/mixlib-config/tree/v1.0.12) (2009-08-25)
[Full Changelog](https://github.com/chef/mixlib-config/compare/alpha_deploy_1...v1.0.12)

## [alpha_deploy_1](https://github.com/chef/mixlib-config/tree/alpha_deploy_1) (2009-08-25)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v1.0.11...alpha_deploy_1)

## [v1.0.11](https://github.com/chef/mixlib-config/tree/v1.0.11) (2009-08-23)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v1.0.9...v1.0.11)

## [v1.0.9](https://github.com/chef/mixlib-config/tree/v1.0.9) (2009-06-24)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v1.0.8...v1.0.9)

## [v1.0.8](https://github.com/chef/mixlib-config/tree/v1.0.8) (2009-06-24)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v1.0.7...v1.0.8)

## [v1.0.7](https://github.com/chef/mixlib-config/tree/v1.0.7) (2009-05-14)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v1.0.6...v1.0.7)

## [v1.0.6](https://github.com/chef/mixlib-config/tree/v1.0.6) (2009-05-12)
[Full Changelog](https://github.com/chef/mixlib-config/compare/v1.0.5...v1.0.6)

## [v1.0.5](https://github.com/chef/mixlib-config/tree/v1.0.5) (2009-05-12)