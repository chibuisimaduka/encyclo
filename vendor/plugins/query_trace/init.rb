require 'query_trace'

if false
  if Rails.env.development? || Rails.env.test?
    class ::ActiveRecord::LogSubscriber
      include QueryTrace
    end
  end
end
