#!/bin/bash
rm activerecord-dynamic-*.gem 2>/dev/null
gem build activerecord-dynamic.gemspec
gem install activerecord-dynamic-*.gem -- development
