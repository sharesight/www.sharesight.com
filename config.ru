require 'rack'
require 'rack/contrib/try_static'
require 'rack-zippy'
require 'zippy_static_cache'

use ZippyStaticCache, :urls => ['/img', '/css', '/js', '/fonts']
use Rack::Zippy::AssetServer, 'build'
use Rack::TryStatic,
  root: 'build',
  urls: ['/'],
  try: ['.html', 'index.html', '/index.html']
