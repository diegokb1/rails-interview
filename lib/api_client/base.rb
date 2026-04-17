module ApiClient
  class Base
    include HTTParty
    base_uri "/localhost/api/"

    def self.headers
      { 'Content-Type' => 'application/json' }
    end
  end
end
