Gem::Specification.new do |s|
  s.name        = 'wgit'
  s.version     = '0.1.0'
  s.date        = '2016-03-07'
  s.summary     = "Wgit is wget on steroids with an easy to use API."
  s.description = "Wgit is a WWW indexer or 'spider' which crawls URL's and retrieves their page contents for later use. Also included in this package is a means to search indexed documents stored in a database. Therefore this library provides the main components of a WWW search engine. You can also use Wgit to copy entire websites or web page's HTML."
  s.authors     = ["Michael Telford"]
  s.email       = "michael.telford@live.com"
  s.files       = Dir["./lib/**/*.rb"]
  #s.executables << "wgit"
  s.homepage    = 'http://rubygems.org/gems/wgit'
  s.license     = 'MIT'
end