APP_DOMAINS = {
  "production" => "payps.co",
  "qa" => "qa.slytrade.com",
  "development" => "localhost:3000",
  "test" => "localhost:3000"
}

APP_DOMAIN = APP_DOMAINS[Rails.env]
