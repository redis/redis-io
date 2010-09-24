require File.expand_path("app", File.dirname(__FILE__))

use Rack::Session::Cookie
use Rack::OpenID

run Cuba
