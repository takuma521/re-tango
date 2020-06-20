set :output, {:error => 'log/error.log', :standard => 'log/cron.log'}
set :job_template, "/bin/zsh -l -c ':job'"
ENV['RAILS_ENV'] ||= 'development'
set :environment, ENV['RAILS_ENV']

every 1.minutes do
  rake 'test:task'
end
