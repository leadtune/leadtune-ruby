module CurbFu::Request::Base

  def build_with_timeout(*args)
    @timeout = 1
    build_without_timeout(*args)
  end

  alias_method :build_without_timeout, :build
  alias_method :build, :build_with_timeout

end
