require 'sidekiq/web'

module Sidetiq
  module Web

    def self.registered(app)
      app.helpers do
        def find_template(view, *args, &block)
          path = File.expand_path(File.join('..', 'views'), __FILE__)
          super(path, *args, &block)
          super
        end
      end

      app.get "/sidetiq" do
        @schedules = Sidetiq::Clock.instance.schedules
        slim :sidetiq
      end

      app.get "/sidetiq/:name" do
        halt 404 unless (name = params[:name])

        schedules = Sidetiq::Clock.instance.schedules

        @worker, @schedule = schedules.select do |worker, schedule|
          worker.name == name
        end.flatten

        slim :sidetiq_details
      end
    end
  end
end

Sidekiq::Web.register(Sidetiq::Web)

if Sidekiq::Web.tabs.is_a?(Array)
  Sidekiq::Web.tabs << "sidetiq"
else
  Sidekiq::Web.tabs["Sidetiq"] = "sidetiq"
end

