Gem::Specification.new do |s|
  s.name = "cget"
  s.version = "0.0.1"
  s.summary = "parallel downloader over ssh"
  s.description = "a parallel downloader using ssh as a control connection"

  s.author = "Charlie Somerville"
  s.email = "charlie@charliesomerville.com"
  s.homepage = "https://github.com/charliesome/cget"

  s.license = "MIT"
  s.files = `git ls-files`.lines.map(&:chomp)
end
